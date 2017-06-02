package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.controls.floatings.BuildingImprovementFloating;
	import com.gerantech.towercraft.controls.floatings.FloatingTransitionData;
	import com.gerantech.towercraft.managers.net.ResponseSender;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.views.BattleFieldView;
	import com.gerantech.towercraft.views.PlaceView;
	import com.gt.towers.utils.PathFinder;
	import com.gt.towers.utils.lists.PlaceList;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.Room;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	import com.smartfoxserver.v2.requests.LeaveRoomRequest;
	
	import flash.geom.Point;
	
	import feathers.controls.StackScreenNavigator;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.animation.Transitions;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class BattleScreen extends BaseCustomScreen
	{
		private var sourceTowers:Vector.<PlaceView>;
		private var sfsConnection:SFSConnection;
		private var battleRoom:Room;
		private var timeoutId:uint;
		private var transitionInCompleted:Boolean;
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			
			sfsConnection = SFSConnection.instance;
			sfsConnection.addEventListener(SFSEvent.EXTENSION_RESPONSE,	sfsConnection_extensionResponseHandler);
			sfsConnection.addEventListener(SFSEvent.CONNECTION_LOST,	sfsConnection_connectionLostHandler);
			sfsConnection.sendExtensionRequest(SFSCommands.START_BATTLE);
			
			appModel.battleField = new BattleFieldView();
			appModel.battleField.mode = BattleFieldView.MODE_PLAY;
			appModel.battleField.layoutData = new AnchorLayoutData((stage.height - (stage.width/3)*4)/2,0,NaN,0);
			addChild(appModel.battleField);
			
			addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionInCompleteHandler);
		}
		
		private function transitionInCompleteHandler(event:Event):void
		{
			transitionInCompleted = true;
			removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionInCompleteHandler);
			startBattle();
		}		
		
		protected function sfsConnection_connectionLostHandler(event:SFSEvent):void
		{
			removeConnectionListeners();
		}
		protected function sfsConnection_extensionResponseHandler(event:SFSEvent):void
		{
			switch(event.params.cmd)
			{
				case SFSCommands.START_BATTLE:
					player.troopType = event.params.params.getInt("troopType");
					battleRoom = sfsConnection.getRoomById(event.params.params.getInt("roomId"));
					appModel.battleField.responseSender = new ResponseSender(battleRoom);
					startBattle();
					break;
				
				case SFSCommands.IMPROVE:
					appModel.battleField.places[event.params.params.getInt("i")].replaceBuilding(event.params.params.getInt("t"), event.params.params.getInt("l"));
					break;
			}
		}
		
		private function startBattle():void
		{
			if(battleRoom == null || !transitionInCompleted)
				return;
			
			appModel.battleField.createPlaces();
			updateTowersFromRoomVars();
			
			sfsConnection.addEventListener(SFSEvent.USER_EXIT_ROOM, sfsConnection_userExitRoomHandler);
			sfsConnection.addEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, sfsConnection_roomVariablesUpdateHandler);
			addEventListener(TouchEvent.TOUCH, touchHandler);
		}
		
		protected function sfsConnection_userExitRoomHandler(event:SFSEvent):void
		{
			if(event.params.user.isItMe || owner == null)
				return;
			StackScreenNavigator(owner).popScreen();
		}
		
		
		protected function sfsConnection_roomVariablesUpdateHandler(event:SFSEvent):void
		{
			if(event.params.changedVars.indexOf("towers") > -1 )
				updateTowersFromRoomVars();
			
			if(event.params.changedVars.indexOf("s") > -1 && event.params.changedVars.indexOf("d") > -1 )
			{
				var towers:SFSArray = battleRoom.getVariable("s").getValue() as SFSArray;
				var destination:int = battleRoom.getVariable("d").getValue();
				
				for(var i:int=0; i<towers.size(); i++)
					appModel.battleField.places[towers.getInt(i)].fight(appModel.battleField.places[destination].place);
			}
		}
		
		private function updateTowersFromRoomVars():void
		{
			if(!battleRoom.containsVariable("towers"))
				return;
			
			var towers:SFSArray = battleRoom.getVariable("towers").getValue() as SFSArray;
			for(var i:int=0; i<towers.size(); i++)
			{
				var t:Array = towers.getText(i).split(",");//trace(t)
				appModel.battleField.places[t[0]].update(t[1], t[2]);
			}			
		}		
		
		private function touchHandler(event:TouchEvent):void
		{
			var tp:PlaceView; 
			var touch:Touch = event.getTouch(this);
			if(touch == null)
				return;
			
			if(touch.phase == TouchPhase.BEGAN)
			{
				sourceTowers = new Vector.<PlaceView>();
				//trace("BEGAN", touch.target, touch.target.parent);
				if(!(touch.target.parent is PlaceView))
					return;
				tp = touch.target.parent as PlaceView;
				
				if(tp.place.building.troopType != player.troopType)
					return;
				
				sourceTowers.push(tp);
			}
			else 
			{
				if(sourceTowers == null || sourceTowers.length == 0)
					return;
				
				if(touch.phase == TouchPhase.MOVED)
				{
					tp = appModel.battleField.dropTargets.contain(touch.globalX, touch.globalY) as PlaceView;
					if(tp != null)
					{
						// check next tower liked by selected towers
						if(sourceTowers.indexOf(tp)==-1 && tp.place.building.troopType == player.troopType)
							sourceTowers.push(tp);
					}
					
					for each(tp in sourceTowers)
					{
						tp.arrowContainer.visible = true;
						tp.arrowTo(touch.globalX-tp.x-appModel.battleField.x, touch.globalY-tp.y-appModel.battleField.y);
					}
				}
				else if(touch.phase == TouchPhase.ENDED)
				{
					var destination:PlaceView = appModel.battleField.dropTargets.contain(touch.globalX, touch.globalY) as PlaceView;
					if(destination == null)
					{
						clearSources(sourceTowers);
						return;
					}
				
					// remove destination from sources if exists
					var self:int = sourceTowers.indexOf(destination);
					if(self > -1)
					{
						if(sourceTowers.length == 1)
						{
							showImproveFloating(sourceTowers[0]);
						}
						
						clearSource(sourceTowers[self]);
						sourceTowers.removeAt(self);
					}
					
					// check sources has a path to destination
					var all:PlaceList = core.battleField.getAllTowers(-1);
					for (var i:int = sourceTowers.length-1; i>=0; i--)
					{
						if(sourceTowers[i].place.building.troopType != player.troopType || PathFinder.find(sourceTowers[i].place, destination.place, all) == null)
						{
							clearSource(sourceTowers[i]);
							sourceTowers.removeAt(i);
						}
					}
					
					// send fight data to room
					if(sourceTowers.length > 0)
						appModel.battleField.responseSender.fight(sourceTowers, destination);

					// clear swiping mode
					clearSources(sourceTowers);
				}
			}
		}

		
		private function clearSources(sourceTowers:Vector.<PlaceView>):void
		{
			for each(var tp:PlaceView in sourceTowers)
				clearSource(tp);
			sourceTowers = null;
		}
		private function clearSource(sourceTower:PlaceView):void
		{
			sourceTower.arrowContainer.visible = false;
		}
		
		
		private function showImproveFloating(placeDecorator:PlaceView):void
		{
			// create transition in data
			var ti:FloatingTransitionData = new FloatingTransitionData();
			ti.transition = Transitions.EASE_OUT_BACK;
			ti.sourceAlpha = 0;
			ti.sourcePosition = new Point(placeDecorator.x, placeDecorator.y);
			ti.destinationPosition = ti.sourcePosition;
			
			// create transition out data
			var to:FloatingTransitionData = new FloatingTransitionData();
			to.sourceAlpha = 1;
			to.sourcePosition = ti.sourcePosition;
			to.destinationPosition = ti.destinationPosition;
			
			var floating:BuildingImprovementFloating = new BuildingImprovementFloating();
			floating.placeDecorator = placeDecorator;
			floating.transitionIn = ti;
			floating.transitionOut = to;
			floating.addEventListener(Event.CLOSE, floating_closeHandler);
			floating.addEventListener(Event.SELECT, floating_selectHandler);
			addChild(floating);
			function floating_closeHandler():void
			{
				floating.removeEventListener(Event.CLOSE, floating_closeHandler);
				floating.removeEventListener(Event.SELECT, floating_selectHandler);
			}
			function floating_selectHandler(event:Event):void
			{
				appModel.battleField.responseSender.improveBuilding(event.data["index"], event.data["type"]);
			}
		}
		
		
		override protected function screen_removedFromStageHandler(event:Event):void
		{
			sfsConnection.send(new LeaveRoomRequest());
			super.screen_removedFromStageHandler(event);
			removeConnectionListeners();
		}
		
		private function removeConnectionListeners():void
		{
			removeEventListener(TouchEvent.TOUCH, touchHandler);
			sfsConnection.removeEventListener(SFSEvent.CONNECTION_LOST,	sfsConnection_connectionLostHandler);
			sfsConnection.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
			sfsConnection.removeEventListener(SFSEvent.USER_EXIT_ROOM, sfsConnection_userExitRoomHandler);
			sfsConnection.removeEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, sfsConnection_roomVariablesUpdateHandler);
		}
		
		override public function dispose():void
		{
			appModel.battleField.dispose();
			super.dispose();
		}
	}
}