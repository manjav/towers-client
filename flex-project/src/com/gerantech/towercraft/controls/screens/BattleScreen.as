package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.controls.BattleHUD;
	import com.gerantech.towercraft.controls.floatings.ImproveFloating;
	import com.gerantech.towercraft.controls.overlays.BattleOutcomeOverlay;
	import com.gerantech.towercraft.controls.overlays.TransitionData;
	import com.gerantech.towercraft.controls.overlays.WaitingOverlay;
	import com.gerantech.towercraft.controls.popups.ConfirmPopup;
	import com.gerantech.towercraft.events.GameEvent;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.tutorials.TutorialData;
	import com.gerantech.towercraft.models.tutorials.TutorialTask;
	import com.gerantech.towercraft.models.vo.BattleData;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	import com.gerantech.towercraft.views.BattleFieldView;
	import com.gerantech.towercraft.views.PlaceView;
	import com.gt.towers.battle.BattleField;
	import com.gt.towers.battle.fieldes.FieldData;
	import com.gt.towers.battle.fieldes.PlaceData;
	import com.gt.towers.constants.BuildingType;
	import com.gt.towers.utils.PathFinder;
	import com.gt.towers.utils.lists.PlaceDataList;
	import com.gt.towers.utils.lists.PlaceList;
	import com.gt.towers.utils.maps.IntIntMap;
	import com.marpies.ane.gameanalytics.GameAnalytics;
	import com.marpies.ane.gameanalytics.data.GAProgressionStatus;
	import com.marpies.ane.gameanalytics.data.GAResourceFlowType;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.ISFSArray;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.animation.Transitions;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class BattleScreen extends BaseCustomScreen
	{
		public var isFriendly:Boolean;
		public var requestField:FieldData;
		public var spectatedUser:String;
		public var waitingOverlay:WaitingOverlay;
		
		private var sourcePlaces:Vector.<PlaceView>;
		private var sfsConnection:SFSConnection;
		private var timeoutId:uint;
		private var transitionInCompleted:Boolean = true;

		private var hud:BattleHUD;
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			backgroundSkin = new Quad(1,1, BaseMetalWorksMobileTheme.CHROME_COLOR);
			
			var sfsObj:SFSObject = new SFSObject();
			sfsObj.putBool("q", requestField!=null&&requestField.isQuest);
			sfsObj.putInt("i", requestField!=null&&requestField.isQuest ? requestField.index : 0);
			if( spectatedUser != null && spectatedUser != "" )
				sfsObj.putText("su", spectatedUser);

			sfsConnection = SFSConnection.instance;
			sfsConnection.addEventListener(SFSEvent.EXTENSION_RESPONSE,	sfsConnection_extensionResponseHandler);
			sfsConnection.addEventListener(SFSEvent.CONNECTION_LOST,	sfsConnection_connectionLostHandler);
			if( !isFriendly )
				sfsConnection.sendExtensionRequest(SFSCommands.START_BATTLE, sfsObj);
			
			tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_tasksFinishHandler);
		}

		protected function sfsConnection_connectionLostHandler(event:SFSEvent):void
		{
			removeConnectionListeners();
		}
		protected function sfsConnection_extensionResponseHandler(event:SFSEvent):void
		{
			var data:SFSObject = event.params.params as SFSObject;
			switch(event.params.cmd)
			{
				case SFSCommands.START_BATTLE:
					var battleData:BattleData = new BattleData(data);
					appModel.battleFieldView = new BattleFieldView();
					addChild(appModel.battleFieldView);
					appModel.battleFieldView.createPlaces(battleData);
					startBattle();
					break;
				
				case SFSCommands.BUILDING_IMPROVE:
					appModel.battleFieldView.places[data.getInt("i")].replaceBuilding(data.getInt("t"), data.getInt("l"));
					appModel.sounds.addAndPlaySound("battle-improve");
					break;
				
				case SFSCommands.LEFT_BATTLE:
				case SFSCommands.REJOIN_BATTLE:
					//trace(event.params.cmd, data.getText("user"))
					appModel.navigator.addLog( loc(event.params.cmd+"_message", [data.getText("user")] ) );
					break;
				
				case SFSCommands.END_BATTLE:
					endBattle(data);
					break;
				
				case SFSCommands.SEND_STICKER:
					hud.showBubble(data.getInt("t"), false);
					break;
			}
//				trace(event.params.cmd, data.getDump());
		}
		
		// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- Start Battle _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
		private function startBattle():void
		{
			if( appModel.battleFieldView.battleData == null || appModel.battleFieldView.battleData.room == null )
				return;
			
			if( !waitingOverlay.ready )
			{
				waitingOverlay.addEventListener(Event.READY, waitingOverlay_readyHandler);
				function waitingOverlay_readyHandler():void
				{
					waitingOverlay.removeEventListener(Event.READY, waitingOverlay_readyHandler);
					startBattle();
				}
				return;
			}

			waitingOverlay.disappear();
			updateTowersFromRoomVars();
			
			var quest:FieldData = appModel.battleFieldView.battleData.battleField.map;
			//trace("battle screen -> start", quest.index, quest.isQuest, player.quests.get(quest.index));
			if( quest.isQuest && player.quests.get(quest.index) <= 2 )
			{
				// create tutorial steps
				var tutorialData:TutorialData = new TutorialData(SFSCommands.START_BATTLE);
				if(quest.hasIntro)
					tutorialData.tasks.push(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_quest_"+player.get_questIndex()+"_intro"));
				
				var places:PlaceDataList = quest.getSwipeTutorPlaces();
				if(places.size() > 0)
					tutorialData.tasks.push(new TutorialTask(TutorialTask.TYPE_SWIPE, null, places, 0, 3000));
					
				var place:PlaceData = quest.getImprovableTutorPlace()
				if(place != null)
				{
					places = new PlaceDataList();
					places.push(place);
					tutorialData.tasks.push(new TutorialTask(TutorialTask.TYPE_TOUCH, null, places, 0));
				}
				tutorials.show(this, tutorialData);
			}
			
			hud = new BattleHUD();
			hud.addEventListener(Event.CLOSE, backButtonHandler);
			hud.layoutData = new AnchorLayoutData(0,0,0,0);
			addChild(hud);
			
			sfsConnection.addEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, sfsConnection_roomVariablesUpdateHandler);
			
			if(appModel.loadingManager.inBattle)
			{
				appModel.battleFieldView.responseSender.resetAllVars();
				appModel.loadingManager.inBattle = false;
			}

			if( !sfsConnection.mySelf.isSpectator )
				addEventListener(TouchEvent.TOUCH, touchHandler);
			
			// play battle theme -_-_-_
			appModel.sounds.stopSound("main-theme");
			appModel.sounds.addSound("battle-theme", null,  themeLoaded);
			function themeLoaded():void { appModel.sounds.playSoundUnique("battle-theme", 0.8, 100); }
			
			//Game Analytic
			if(GameAnalytics.isInitialized)
			{
				if(AppModel.instance.game.player.inFriendlyBattle)
				{
					GameAnalytics.addProgressionEvent(GAProgressionStatus.START, quest.isQuest?"Quests":"Battles", "FriendlyBattle", quest.index.toString());
					if(sfsConnection.mySelf.isSpectator)
						GameAnalytics.addProgressionEvent(GAProgressionStatus.START, quest.isQuest?"Quests":"Battles", "FB-Spectator", quest.index.toString());
				}
				else
				{
					GameAnalytics.addProgressionEvent(GAProgressionStatus.START, quest.isQuest?"Quests":"Battles", quest.isQuest?"Quests":"Battles", quest.index.toString());
					if(sfsConnection.mySelf.isSpectator)
						GameAnalytics.addProgressionEvent(GAProgressionStatus.START, quest.isQuest?"Quests":"Battles", "Spectator", quest.index.toString());
				}
			}
		}
		
		// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- End Battle _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
		private function endBattle(data:SFSObject):void
		{
			removeChild(hud, true);
			appModel.battleFieldView.responseSender.actived = false;
			
			var youWin:Boolean = data.getBool("youWin");
			var score:int = data.getInt("score");
			var rewards:ISFSArray = data.getSFSArray("rewards");
			var quest:FieldData = appModel.battleFieldView.battleData.battleField.map;
			var tutorialMode:Boolean = quest.isQuest && quest.hasFinal && player.quests.get(quest.index)==0;
			
			// set quest score
			if ( quest.isQuest && player.quests.get( quest.index ) < score)
				player.quests.set(quest.index, score);
			
			// reduce player resources
			var outcomes:IntIntMap = new IntIntMap();
			for(var i:int=0; i<rewards.size(); i++)
				outcomes.set(rewards.getSFSObject(i).getInt("t"), rewards.getSFSObject(i).getInt("c"));
			player.addResources(outcomes);
			
			// show battle outcome overlay
			var battleOutcomeOverlay:BattleOutcomeOverlay = new BattleOutcomeOverlay(score, rewards, tutorialMode);
			battleOutcomeOverlay.addEventListener(Event.CLOSE, battleOutcomeOverlay_closeHandler);
			battleOutcomeOverlay.addEventListener(FeathersEventType.CLEAR, battleOutcomeOverlay_retryHandler);
			appModel.navigator.addOverlay(battleOutcomeOverlay);
			
			// Game Analytic
			if( GameAnalytics.isInitialized && !sfsConnection.mySelf.isSpectator)
			{
				if(AppModel.instance.game.player.inFriendlyBattle)
					GameAnalytics.addProgressionEvent((score>0)?GAProgressionStatus.COMPLETE:GAProgressionStatus.FAIL, quest.isQuest?"Quests":"Battles", "FriendlyBattle", quest.index.toString());
				else
					GameAnalytics.addProgressionEvent((score>0)?GAProgressionStatus.COMPLETE:GAProgressionStatus.FAIL, quest.isQuest?"Quests":"Battles", quest.isQuest?"Quests":"Battles", quest.index.toString(), score);
				for each (var k:int in outcomes.keys())
					GameAnalytics.addResourceEvent(GAResourceFlowType.SINK, k.toString(), outcomes.get(k), quest.isQuest?"Quests":"Battles", "BattleOutCome-reward");
				
			}
			
			appModel.sounds.stopSound("battle-theme");
			appModel.sounds.stopSound("battle-clock-ticking");
		}
		
		private function battleOutcomeOverlay_retryHandler(event:Event):void
		{
			event.currentTarget.removeEventListener(Event.CLOSE, battleOutcomeOverlay_closeHandler);
			event.currentTarget.removeEventListener(FeathersEventType.CLEAR, battleOutcomeOverlay_retryHandler);
			
			removeChild(appModel.battleFieldView, true);			
			sfsConnection.sendExtensionRequest(SFSCommands.START_BATTLE);
			
			appModel.battleFieldView = new BattleFieldView();
			addChild(appModel.battleFieldView);			
		}
		private function battleOutcomeOverlay_closeHandler(event:Event):void
		{
			var battleOutcomeOverlay:BattleOutcomeOverlay = event.currentTarget as BattleOutcomeOverlay;
			battleOutcomeOverlay.removeEventListener(Event.CLOSE, battleOutcomeOverlay_closeHandler);
			battleOutcomeOverlay.removeEventListener(FeathersEventType.CLEAR, battleOutcomeOverlay_retryHandler);
			
			// create tutorial steps
			var quest:FieldData = appModel.battleFieldView.battleData.battleField.map;
			if( battleOutcomeOverlay.tutorialMode && battleOutcomeOverlay.score > 0)
			{
				//trace("battle screen -> end", player.get_questIndex());
				var tutorialData:TutorialData = new TutorialData(SFSCommands.END_BATTLE);
				tutorialData.tasks.push(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_quest_"+(player.get_questIndex()-1)+"_final"));
				tutorials.show(this, tutorialData);
			}
			else
			{
				dispatchEventWith(Event.COMPLETE);
			}
		}
		
		
		private function tutorials_tasksFinishHandler(event:Event):void
		{
			var tutorial:TutorialData = event.data as TutorialData;
			if( tutorial.name == SFSCommands.END_BATTLE )
				dispatchEventWith(Event.COMPLETE);
		}
		
		protected function sfsConnection_roomVariablesUpdateHandler(event:SFSEvent):void
		{
			/*if( event.params.room == null || (event.params.room.groupId!="battles"&&event.params.room.groupId!="quests") )
				return;
				*/
			if( event.params.changedVars.indexOf("towers") > -1 )
				updateTowersFromRoomVars();
			
			if( event.params.changedVars.indexOf("s") > -1 && event.params.changedVars.indexOf("d") > -1 )
			{
				var towers:SFSArray = appModel.battleFieldView.battleData.room.getVariable("s").getValue() as SFSArray;
				var destination:int = appModel.battleFieldView.battleData.room.getVariable("d").getValue();
				
				for( var i:int=0; i<towers.size(); i++ )
					appModel.battleFieldView.places[towers.getInt(i)].fight(appModel.battleFieldView.places[destination].place);
			}
		}
		
		private function updateTowersFromRoomVars():void
		{
			if( !appModel.battleFieldView.battleData.room.containsVariable("towers") )
				return;
			var towers:SFSArray = appModel.battleFieldView.battleData.room.getVariable("towers").getValue() as SFSArray;
			for(var i:int=0; i<towers.size(); i++)
			{
				var t:Array = towers.getText(i).split(",");//trace(t)
				appModel.battleFieldView.places[t[0]].update(t[1], t[2]);
			}			
		}

		
		// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- Touch Handler _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
		private function touchHandler(event:TouchEvent):void
		{
			var tp:PlaceView;
			var touch:Touch = event.getTouch(this);
			if(touch == null)
				return;
			
			if(touch.phase == TouchPhase.BEGAN)
			{
				sourcePlaces = new Vector.<PlaceView>();
				//trace("BEGAN", touch.target, touch.target.parent);
				if(!(touch.target.parent is PlaceView))
					return;
				tp = touch.target.parent as PlaceView;
				
				if(tp.place.building.troopType != player.troopType)
					return;
				
				sourcePlaces.push(tp);
			}
			else 
			{
				if(sourcePlaces == null || sourcePlaces.length == 0)
					return;
				
				if(touch.phase == TouchPhase.MOVED)
				{
					tp = appModel.battleFieldView.dropTargets.contain(touch.globalX, touch.globalY) as PlaceView;
					if(tp != null)
					{
						// check next tower liked by selected places
						if(sourcePlaces.indexOf(tp)==-1 && tp.place.building.troopType == player.troopType)
							sourcePlaces.push(tp);
					}
					
					for each(tp in sourcePlaces)
					{
						tp.arrowContainer.visible = true;
						tp.arrowTo(touch.globalX-tp.x-appModel.battleFieldView.x, touch.globalY-tp.y-appModel.battleFieldView.y);
					}
				}
				else if(touch.phase == TouchPhase.ENDED)
				{
					var destination:PlaceView = appModel.battleFieldView.dropTargets.contain(touch.globalX, touch.globalY) as PlaceView;
					if(destination == null)
					{
						clearSources(sourcePlaces);
						return;
					}
				
					// remove destination from sources if exists
					var self:int = sourcePlaces.indexOf(destination);
					if(self > -1)
					{
						if(sourcePlaces.length == 1)
						{
							sourcePlaces[0].dispatchEventWith(Event.SELECT);
							showImproveFloating(sourcePlaces[0]);
						}
						
						clearSource(sourcePlaces[self]);
						sourcePlaces.removeAt(self);
					}
					
					// force improve in tutorial mode
					var bf:BattleField = appModel.battleFieldView.battleData.battleField; 
					var improvable:PlaceData = bf.map.getImprovableTutorPlace();
					if( bf.map.isQuest && improvable!= null && bf.places.get(improvable.index).building.type == BuildingType.B01_CAMP )
					{
						appModel.battleFieldView.places[improvable.index].decorator.improvablePanel.enabled = false;
						setTimeout(function():void{ appModel.battleFieldView.places[improvable.index].decorator.improvablePanel.enabled = true}, 500);
						clearSources(sourcePlaces);
						return;
					}

					// check sources has a path to destination
					var all:PlaceList = appModel.battleFieldView.battleData.battleField.getAllTowers(-1);
					for (var i:int = sourcePlaces.length-1; i>=0; i--)
					{
						if(sourcePlaces[i].place.building.troopType != player.troopType || PathFinder.find(sourcePlaces[i].place, destination.place, all) == null)
						{
							clearSource(sourcePlaces[i]);
							sourcePlaces.removeAt(i);
						}
					}
					
					// send fight data to room
					if(sourcePlaces.length > 0)
						appModel.battleFieldView.responseSender.fight(sourcePlaces, destination);

					// clear swiping mode
					clearSources(sourcePlaces);
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
		
		private function showImproveFloating(placeView:PlaceView):void
		{
			if( appModel.battleFieldView.battleData.battleField.map.isQuest && player.get_questIndex() < 2 )
				return;
			// create transition in data
			var ti:TransitionData = new TransitionData();
			ti.transition = Transitions.EASE_OUT_BACK;
			ti.sourceAlpha = 0;
			ti.sourcePosition = new Point(placeView.x, placeView.y-50*appModel.scale);
			ti.destinationPosition = ti.sourcePosition;
			
			// create transition out data
			var to:TransitionData = new TransitionData();
			to.sourceAlpha = 1;
			to.sourcePosition = ti.sourcePosition;
			to.destinationPosition = ti.destinationPosition;
			
			var floating:ImproveFloating = new ImproveFloating();
			floating.placeView = placeView;
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
				appModel.battleFieldView.responseSender.improveBuilding(event.data["index"], event.data["type"]);
			}
		}

		
		override protected function backButtonFunction():void
		{
			if( sfsConnection.mySelf.isSpectator )
			{
				appModel.battleFieldView.responseSender.leave();
				dispatchEventWith(Event.COMPLETE);
				return;
			}
			
			if( !appModel.battleFieldView.battleData.map.isQuest )
				return;
				
			var confirm:ConfirmPopup = new ConfirmPopup(loc("leave_battle_confirm_message"), loc("popup_exit_label"), loc("popup_continue_label"));
			confirm.acceptStyle = "danger";
			confirm.addEventListener(Event.SELECT, confirm_eventsHandler);
			appModel.navigator.addPopup(confirm);
			function confirm_eventsHandler():void {
				appModel.battleFieldView.responseSender.leave();
			}
		}
		
		override public function dispose():void
		{
			player.inFriendlyBattle = false;
			removeConnectionListeners();
			appModel.sounds.playSoundUnique("main-theme", 1, 100);
			appModel.battleFieldView.dispose();
			super.dispose();
		}
		
		private function removeConnectionListeners():void
		{
			removeEventListener(TouchEvent.TOUCH, touchHandler);
			sfsConnection.removeEventListener(SFSEvent.CONNECTION_LOST,	sfsConnection_connectionLostHandler);
			sfsConnection.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
			sfsConnection.removeEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, sfsConnection_roomVariablesUpdateHandler);
		}
	}

}
