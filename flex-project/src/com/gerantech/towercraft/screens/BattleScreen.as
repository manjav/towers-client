package com.gerantech.towercraft.screens
{
	import com.gerantech.towercraft.BattleField;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.Player;
	import com.gerantech.towercraft.models.TowerPlace;
	import com.gerantech.towercraft.models.vo.SFSBBattleObject;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.User;
	import com.smartfoxserver.v2.entities.data.ISFSArray;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	import com.smartfoxserver.v2.entities.variables.SFSUserVariable;
	import com.smartfoxserver.v2.requests.LeaveRoomRequest;
	import com.smartfoxserver.v2.requests.SetUserVariablesRequest;
	
	import feathers.controls.StackScreenNavigator;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class BattleScreen extends BaseCustomScreen
	{
		private var battleField:BattleField;
		private var sourceTowers:Vector.<TowerPlace>;
		//private var rtmpConnector:RTMFPConnector;
		private var sfsConnection:SFSConnection;
		
		override protected function initialize():void
		{
			super.initialize();
			alpha = 0.3;
			layout = new AnchorLayout();
			
			var myTowers:Vector.<int> = new Vector.<int>();
			for(var i:uint=0; i<6; i++)
				myTowers.push(Player.instance.towerPlaces[i]);
			
			sfsConnection = SFSConnection.getInstance();
			sfsConnection.addEventListener(SFSEvent.EXTENSION_RESPONSE,	sfsConnection_extensionResponseHandler);
			sfsConnection.addEventListener(SFSEvent.CONNECTION_LOST,	sfsConnection_connectionLostHandler);
			sfsConnection.sendExtensionRequest(SFSCommands.START_BATTLE, new SFSBBattleObject(myTowers, -1).toSFS());//
			
			sfsConnection.addEventListener(SFSEvent.USER_EXIT_ROOM, sfsConnection_userExitRoomHandler);
			sfsConnection.addEventListener(SFSEvent.USER_VARIABLES_UPDATE, sfsConnection_userVariablesUpdateHandler);
			
			battleField = new BattleField();
			battleField.mode = BattleField.MODE_PLAY;
			battleField.layoutData = new AnchorLayoutData(stage.width/3,0,NaN,0);
			addChild(battleField);
		}
		
		protected function sfsConnection_userExitRoomHandler(event:SFSEvent):void
		{
			if(event.params.user.isItMe || owner == null)
				return;
			StackScreenNavigator(owner).popScreen();
		}
				
		protected function sfsConnection_userVariablesUpdateHandler(event:SFSEvent):void
		{
			var user:User = event.params.user as User;
			//trace("sfsConnection_userVariablesUpdateHandler", user.isItMe);
			var source:Array = new Array;
			var destination:int ;
			var sources:ISFSArray;

			for each (var i:String in event.params.changedVars)
			{
				if(i == "s")
				{
					sources = user.getVariable(i).getSFSArrayValue();
					//for(var s:int=0; s<user.getVariable(i).getSFSArrayValue().size(); s++)
					//	source.push(user.getVariable(i).getSFSArrayValue().getInt(s));					
				}
				else if(i == "d")
				{
					destination = user.getVariable(i).getIntValue();
				}
			}
			syncTowers(sources, destination, user.isItMe);
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
					startBattle(event.params.params.getIntArray("s"));
					break;
			}
		}
		
		private function syncTowers(_sources:ISFSArray, _destination:int, isItMe:Boolean):void
		{
			var destination:TowerPlace = battleField.getTower(isItMe?_destination:(14-_destination));
			var sourceLen:uint = _sources.size();
			for(var i:uint=0; i<sourceLen; i++)
				battleField.getTower(isItMe?_sources.getInt(i):(14-_sources.getInt(i))).fight(destination, battleField.getAllTowers(-1));
		}

		private function startBattle(towers:Array):void
		{
			for(var i:uint=0; i<towers.length; i++)
				Player.instance.towerPlaces[14-i] = towers[i];
				
			alpha = 1;
			battleField.addDrops();
			battleField.readyForBattle();
			addEventListener(TouchEvent.TOUCH, touchHandler);
		}

		private function touchHandler(event:TouchEvent):void
		{
			var tp:TowerPlace; 
			var touch:Touch = event.getTouch(this);
			if(touch == null)
				return;
			
			if(touch.phase == TouchPhase.BEGAN)
			{
				//trace("BEGAN", touch.target, touch.target.parent);
				if(!(touch.target.parent is TowerPlace))
					return;
				tp = touch.target.parent as TowerPlace;
				
				if(tp.tower.troopType != Player.instance.troopType)
					return;
				
				sourceTowers = new Vector.<TowerPlace>();
				sourceTowers.push(tp);
			}
			else 
			{
				if(sourceTowers == null || sourceTowers.length==0)
					return;
				
				if(touch.phase == TouchPhase.MOVED)
				{
					var dest:DisplayObject = battleField.dropTargets.contain(touch.globalX, touch.globalY);
					//trace("MOVED", dest)
					if(dest!=null && dest is TowerPlace)
					{
						tp = dest as TowerPlace;
						if(sourceTowers.indexOf(tp)==-1 && tp.tower.troopType == sourceTowers[0].tower.troopType)
							sourceTowers.push(tp);
					}
					
					for each(tp in sourceTowers)
					{
						tp.arrowContainer.visible = true;
						tp.arrowTo(touch.globalX-tp.x-battleField.x, touch.globalY-tp.y-battleField.y);
					}
				}
				else if(touch.phase == TouchPhase.ENDED)
				{
					dest = battleField.dropTargets.contain(touch.globalX, touch.globalY);
					//trace("ENDED", dest)
					if(dest is TowerPlace)
					{
						var destination:TowerPlace = dest as TowerPlace;
						var lastPoint:TowerPlace;
					
						// check destination is neighbor of our towers 
						var all:Vector.<TowerPlace> = battleField.getAllTowers(sourceTowers[0].tower.troopType);
						for each(tp in all)
						{
							if(destination.links.indexOf(tp) > -1)
							{
								lastPoint = tp;
								break;
							}
						}
						// get allllllll
						if(lastPoint != null)
						{
							all = battleField.getAllTowers(-1);
							var self:int = sourceTowers.indexOf(destination);
							if(self>-1)
								sourceTowers.slice(self, 1);
							
							var sources:SFSArray = new SFSArray();
							for each(tp in sourceTowers)
							{
							//	tp.fight(destination, all);
								sources.addInt(tp.index);
							}
							
							var userVars:Array = [];
							userVars.push(new SFSUserVariable("s", sources));
							userVars.push(new SFSUserVariable("d", destination.index));
							sfsConnection.send(new SetUserVariablesRequest(userVars));
							
							//sfsConnection.send(SFSCommands.FIGHT, new SFSBBattleObject(sources, destination.index).toSFS());
							//rtmpConnector.send(sources, destination.index);
						}
					}
					for each(tp in sourceTowers)
						tp.arrowContainer.visible = false;
					
					sourceTowers = null;
				}
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
		}		

	}
}