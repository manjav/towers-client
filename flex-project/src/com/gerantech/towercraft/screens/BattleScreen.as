package com.gerantech.towercraft.screens
{
	import com.gerantech.towercraft.BattleField;
	import com.gerantech.towercraft.managers.PathFinder;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.Player;
	import com.gerantech.towercraft.models.TowerPlace;
	import com.gerantech.towercraft.models.towers.Tower;
	import com.gerantech.towercraft.models.vo.SFSBBattleObject;
	import com.gerantech.towercraft.models.vo.Troop;
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
	
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class BattleScreen extends BaseCustomScreen
	{
		private var battleField:BattleField;
		private var sourceTowers:Vector.<TowerPlace>;
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
			
			battleField.layoutData = new AnchorLayoutData((stage.height - (stage.width/3)*4)/2,0,NaN,0);
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
			if(event.params.changedVars.indexOf("c") > -1)
			{
				//trace(user.isItMe, user.getVariable("c").getIntValue());
				if(!user.isItMe)
					battleField.getTower(14 - user.getVariable("c").getIntValue()).tower.forceOccupy();
				return;
			}
			
			var source:Array = new Array;
			var destination:int ;
			var sources:ISFSArray;
			
			for each (var i:String in event.params.changedVars)
			{
				if(i == "s")
					sources = user.getVariable(i).getSFSArrayValue();
				else if(i == "d")
					destination = user.getVariable(i).getIntValue();
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
					//trace(event.params.params.getLong("time")- new Date().time);//1495019157057
					startBattle(event.params.params.getIntArray("towers"));
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
			
			for each(var t:TowerPlace in battleField.getAllTowers(-1))
				t.tower.addEventListener(Event.UPDATE, tower_updateHandler);
		}
		
		private function tower_updateHandler(event:Event):void
		{
			if(!event.data)
				return;
			
			var tower:Tower = event.currentTarget as Tower;
			if(tower.troopType != Troop.TYPE_BLUE)
				return;
				
			var userVars:Array = [];
			userVars.push(new SFSUserVariable("c", tower.index));
			sfsConnection.send(new SetUserVariablesRequest(userVars));				
		}
		
		private function touchHandler(event:TouchEvent):void
		{
			var tp:TowerPlace; 
			var touch:Touch = event.getTouch(this);
			if(touch == null)
				return;
			
			if(touch.phase == TouchPhase.BEGAN)
			{
				sourceTowers = new Vector.<TowerPlace>();
				//trace("BEGAN", touch.target, touch.target.parent);
				if(!(touch.target.parent is TowerPlace))
					return;
				tp = touch.target.parent as TowerPlace;
				
				if(tp.tower.troopType != Player.instance.troopType)
					return;
				
				sourceTowers.push(tp);
			}
			else 
			{
				if(sourceTowers == null || sourceTowers.length==0)
					return;
				
				if(touch.phase == TouchPhase.MOVED)
				{
					tp = battleField.dropTargets.contain(touch.globalX, touch.globalY) as TowerPlace;
					if(tp != null)
					{
						// check next tower liked by selected towers
						if(sourceTowers.indexOf(tp)==-1 && tp.tower.troopType == Player.instance.troopType)
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
					var destination:TowerPlace = battleField.dropTargets.contain(touch.globalX, touch.globalY) as TowerPlace;
					if(destination == null)
					{
						clearSources(sourceTowers);
						return;
					}
				
					// remove destination from sources if exists
					var self:int = sourceTowers.indexOf(destination);
					if(self > -1)
					{
						clearSource(sourceTowers[self]);
						sourceTowers.removeAt(self);
					}
					
					// check sources has a path to destination
					var all:Vector.<TowerPlace> = battleField.getAllTowers(-1);
					for (var i:int = sourceTowers.length-1; i>=0; i--)
					{
						if(sourceTowers[i].tower.troopType != Player.instance.troopType || PathFinder.find(sourceTowers[i], destination, all) == null)
						{
							clearSource(sourceTowers[i]);
							sourceTowers.removeAt(i);
						}
					}
					
					// send fight data to room
					if(sourceTowers.length > 0)
					{
						var sources:SFSArray = new SFSArray();
						for each(tp in sourceTowers)
							sources.addInt(tp.index);
						
						var userVars:Array = [];
						userVars.push(new SFSUserVariable("s", sources));
						userVars.push(new SFSUserVariable("d", destination.index));
						sfsConnection.send(new SetUserVariablesRequest(userVars));
						//trace("SetUserVariablesRequest");
					}

					// clear swiping mode
					clearSources(sourceTowers);
				}
			}
		}
		
		private function clearSources(sourceTowers:Vector.<TowerPlace>):void
		{
			for each(var tp:TowerPlace in sourceTowers)
				clearSource(tp);
			sourceTowers = null;
		}
		
		private function clearSource(sourceTower:TowerPlace):void
		{
			sourceTower.arrowContainer.visible = false;
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