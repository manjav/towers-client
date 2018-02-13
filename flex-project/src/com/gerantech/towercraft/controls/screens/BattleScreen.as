package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.controls.BattleHUD;
	import com.gerantech.towercraft.controls.buttons.ImproveButton;
	import com.gerantech.towercraft.controls.floatings.ImproveFloating;
	import com.gerantech.towercraft.controls.overlays.BattleStartOverlay;
	import com.gerantech.towercraft.controls.overlays.EndBattleOverlay;
	import com.gerantech.towercraft.controls.overlays.EndOverlay;
	import com.gerantech.towercraft.controls.overlays.EndQuestOverlay;
	import com.gerantech.towercraft.controls.overlays.FactionChangeOverlay;
	import com.gerantech.towercraft.controls.overlays.TransitionData;
	import com.gerantech.towercraft.controls.popups.ConfirmPopup;
	import com.gerantech.towercraft.controls.popups.UnderMaintenancePopup;
	import com.gerantech.towercraft.events.GameEvent;
	import com.gerantech.towercraft.managers.SoundManager;
	import com.gerantech.towercraft.managers.VideoAdsManager;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.tutorials.TutorialData;
	import com.gerantech.towercraft.models.tutorials.TutorialTask;
	import com.gerantech.towercraft.models.vo.BattleData;
	import com.gerantech.towercraft.models.vo.UserData;
	import com.gerantech.towercraft.models.vo.VideoAd;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	import com.gerantech.towercraft.views.BattleFieldView;
	import com.gerantech.towercraft.views.PlaceView;
	import com.gt.towers.battle.BattleField;
	import com.gt.towers.battle.fieldes.FieldData;
	import com.gt.towers.battle.fieldes.PlaceData;
	import com.gt.towers.constants.BuildingType;
	import com.gt.towers.constants.ExchangeType;
	import com.gt.towers.constants.PrefsTypes;
	import com.gt.towers.constants.ResourceType;
	import com.gt.towers.constants.TroopType;
	import com.gt.towers.utils.PathFinder;
	import com.gt.towers.utils.lists.PlaceDataList;
	import com.gt.towers.utils.lists.PlaceList;
	import com.gt.towers.utils.maps.IntIntMap;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.ISFSArray;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
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
		public var waitingOverlay:BattleStartOverlay;
		
		private var hud:BattleHUD;
		
		private var endPoint:Point = new Point();
		private var sourcePlaces:Vector.<PlaceView>;
		private var allPlacesInTouch:PlaceList;
		
		private var sfsConnection:SFSConnection;
		private var timeoutId:uint;
		private var transitionInCompleted:Boolean = true;

		private var state:int = 0;
		private static const STATE_CREATED:int = 0;
		private static const STATE_STARTED:int = 1;
		
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
					if( data.containsKey("umt") )
					{
						showUMPopup(data);
						return;
					}	
					
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
				
				case SFSCommands.RESET_ALL:
					resetAll(data);
					break;
				
				/*case SFSCommands.LEFT_BATTLE:
				case SFSCommands.REJOIN_BATTLE:
					appModel.navigator.addLog( loc(event.params.cmd+"_message", [data.getText("user")] ) );
					break;*/
				
				case SFSCommands.END_BATTLE:
					endBattle(data);
					break;
				
				case SFSCommands.SEND_STICKER:
					hud.showBubble(data.getInt("t"), false);
					break;
			}
//				trace(event.params.cmd, data.getDump());
		}
		
		private function showUMPopup(data:SFSObject):void
		{
			if( !waitingOverlay.ready )
			{
				waitingOverlay.addEventListener(Event.READY, waitingOverlay_readyHandler);
				function waitingOverlay_readyHandler():void {
					showUMPopup(data);
				}
				return;
			}
			appModel.navigator.addPopup(new UnderMaintenancePopup(data.getInt("umt"), false));
			waitingOverlay.disappear();
			dispatchEventWith(Event.COMPLETE);
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

			waitingOverlay.setData(appModel.battleFieldView.battleData);
			//waitingOverlay.disappear();
			updateTowersFromRoomVars();
			
			var quest:FieldData = appModel.battleFieldView.battleData.battleField.map;
			//trace("battle screen -> start", quest.index, quest.isQuest, player.quests.get(quest.index));
			if( quest.isQuest )
			{
				// create tutorial steps
				var tutorialData:TutorialData = new TutorialData(quest.name+"_start");

				//quest start
				var tuteMessage:String = "";
				for (var i:int=0 ; i < quest.startNum.size() ; i++) 
				{
					tuteMessage = "tutor_quest_" + quest.index + "_start_";
					if( quest.index == 2 )
						tuteMessage += (player.isHardMode()?"first_":"second_");
					tuteMessage += quest.startNum.get(i);
					trace("tuteMessage:", tuteMessage);
					tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, tuteMessage, null, 1000, 1000, quest.startNum.get(i)));
				}

				if( !player.hardMode )
				{
					var places:PlaceDataList = quest.getSwipeTutorPlaces();
					if( places.size() > 0 )
						tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_SWIPE, null, places, 0, 3500));
				
					var place:PlaceData = quest.getImprovableTutorPlace()
					if( place != null )
					{
						places = new PlaceDataList();
						places.push(place);
						tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_TOUCH, null, places, 0, 0));
					}
				}

				tutorials.show(tutorialData);
			}
			
			hud = new BattleHUD();
			hud.addEventListener(Event.CLOSE, backButtonHandler);
			hud.layoutData = new AnchorLayoutData(0,0,0,0);
			addChild(hud);
			
			sfsConnection.addEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, sfsConnection_roomVariablesUpdateHandler);
			
			if( timeManager.now - appModel.battleFieldView.battleData.startAt > 5 )
				appModel.battleFieldView.responseSender.resetAllVars();

			appModel.loadingManager.serverData.putBool("inBattle", false);

			if( !sfsConnection.mySelf.isSpectator )
				addEventListener(TouchEvent.TOUCH, touchHandler);
			
			// play battle theme -_-_-_
			appModel.sounds.stopSound("main-theme");
			appModel.sounds.addSound("battle-theme", null,  themeLoaded, SoundManager.CATE_THEME);
			function themeLoaded():void { appModel.sounds.playSoundUnique("battle-theme", 0.8, 100); }
		}
		
		// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- End Battle _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
		private function endBattle(data:SFSObject):void
		{
			disposeBattleAssets();
			
			var rewards:ISFSArray = data.getSFSArray("outcomes");
			var quest:FieldData = appModel.battleFieldView.battleData.battleField.map;
			var tutorialMode:Boolean = quest.isQuest && (quest.startNum.size() > 0) && player.quests.get(quest.index)==0;

			
			var playerIndex:int = -1
			for(var i:int = 0; i < rewards.size(); i++)
			{
				if( rewards.getSFSObject(i).getInt("id") == player.id )
				{
					playerIndex = i;
					break;
				}
			}
				
			// reduce player resources
			if( playerIndex > -1 )
			{
				var outcomes:IntIntMap = new IntIntMap();
				var item:ISFSObject = rewards.getSFSObject(playerIndex);
				var _keys:Array = item.getKeys();
				for( i = 0; i < _keys.length; i++)
				{
					var key:int = int(_keys[i])
					if( key > 0 )
						outcomes.set(key, item.getInt(_keys[i]));
					if( key == ResourceType.KEY && !quest.isQuest )
						exchanger.items.get(ExchangeType.S_41_KEYS).numExchanges += item.getInt(_keys[i]);
				}
			}
			
			// arena changes manipulation
			var prevArena:int = 0;
			var nextArena:int = 0;
			if( playerIndex > -1 )
			{
				prevArena = player.get_arena(0);
				player.addResources(outcomes);
				nextArena = player.get_arena(0);
			}
			
			var endOverlay:EndOverlay;
			if( quest.isQuest )
			{
				endOverlay = new EndQuestOverlay(playerIndex, rewards, tutorialMode);
			}
			else
			{
				endOverlay = new EndBattleOverlay(playerIndex, rewards, tutorialMode);
				if( playerIndex > -1 && prevArena != nextArena )
					endOverlay.data = [prevArena, nextArena]
			}
			endOverlay.addEventListener(Event.CLOSE, endOverlay_closeHandler);
			endOverlay.addEventListener(FeathersEventType.CLEAR, endOverlay_retryHandler);
			setTimeout(appModel.navigator.addOverlay, player.get_arena(0)==0?1000:0, endOverlay);//delay for noobs
		}
		
		private function disposeBattleAssets():void
		{
			appModel.sounds.stopSound("battle-theme");
			appModel.sounds.stopSound("battle-clock-ticking");			
			appModel.battleFieldView.responseSender.actived = false;
			removeChild(hud, true);
		}
		
		private function endOverlay_retryHandler(event:Event):void
		{
			event.currentTarget.removeEventListener(Event.CLOSE, endOverlay_closeHandler);
			event.currentTarget.removeEventListener(FeathersEventType.CLEAR, endOverlay_retryHandler);
			if( event.data ) 
				showExtraTimeAd();
			else
				retryQuest(appModel.battleFieldView.battleData.map.index, false);
		}
		
		private function showExtraTimeAd():void
		{
			VideoAdsManager.instance.addEventListener(Event.COMPLETE, videoIdsManager_completeHandler);
			VideoAdsManager.instance.showAd(VideoAdsManager.TYPE_QUESTS);
			function videoIdsManager_completeHandler(event:Event):void
			{
				VideoAdsManager.instance.removeEventListener(Event.COMPLETE, videoIdsManager_completeHandler);
				var ad:VideoAd = event.data as VideoAd;
				if( ad.completed && ad.rewarded )
					retryQuest(appModel.battleFieldView.battleData.map.index, true);
				else
					dispatchEventWith(Event.COMPLETE);
				VideoAdsManager.instance.requestAd(VideoAdsManager.TYPE_QUESTS, true);
			}
		}
		
		private function retryQuest(index:int, hasExtraTime:Boolean):void
		{
			waitingOverlay = new BattleStartOverlay(index, false) ;
			appModel.navigator.addOverlay(waitingOverlay);
			
			disposeBattleAssets();
			removeChild(appModel.battleFieldView, true);
			
			var sfsObj:SFSObject = new SFSObject();
			sfsObj.putBool("q", true);
			sfsObj.putInt("i", index);
			if( hasExtraTime )
				sfsObj.putBool("e", true);
			//if( spectatedUser != null && spectatedUser != "" )
			//sfsObj.putText("su", spectatedUser);
			sfsConnection.addEventListener(SFSEvent.EXTENSION_RESPONSE,	sfsConnection_extensionResponseHandler);
			sfsConnection.addEventListener(SFSEvent.CONNECTION_LOST,	sfsConnection_connectionLostHandler);
			sfsConnection.sendExtensionRequest(SFSCommands.START_BATTLE, sfsObj);
		}
		
		private function endOverlay_closeHandler(event:Event):void
		{
			var endOverlay:EndOverlay = event.currentTarget as EndOverlay;
			endOverlay.removeEventListener(Event.CLOSE, endOverlay_closeHandler);
			endOverlay.removeEventListener(FeathersEventType.CLEAR, endOverlay_retryHandler);
			
			if( endOverlay.playerIndex == -1 )
			{
				dispatchEventWith(Event.COMPLETE);
				return;
			}
			
			var field:FieldData = appModel.battleFieldView.battleData.battleField.map;
			// set quest score
			if( field.isQuest && player.quests.get( field.index ) < endOverlay.score )
				player.quests.set(field.index, endOverlay.score);
			
			// create tutorial steps
			var winStr:String = endOverlay.score > 0 ? "_win_" : "_defeat_";
			//quest end
			if( field.isQuest && player.inTutorial() )
			{
				var tutorialData:TutorialData = new TutorialData(field.name + "_end");
				var task:TutorialTask
				for ( var i:int=0; i < field.endNum.size() ; i++ )
				{
					task = new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_quest_" + field.index + "_end" + winStr + field.endNum.get(i));
					task.data = field.endNum.get(i);
					tutorialData.addTask(task);
				}
				tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_tasksFinishHandler);
				tutorials.show(tutorialData);
				return;
			}
			
			// show faction changes overlay
			if( endOverlay.data != null )
			{
				var factionsOverlay:FactionChangeOverlay = new FactionChangeOverlay(endOverlay.data[0], endOverlay.data[1]);
				factionsOverlay.addEventListener(Event.CLOSE, factionsOverlay_closeHandler);
				appModel.navigator.addOverlay(factionsOverlay);
				function factionsOverlay_closeHandler(event:Event):void {
					factionsOverlay.removeEventListener(Event.CLOSE, factionsOverlay_closeHandler);
					dispatchEventWith(Event.COMPLETE);
				}
				return;
			}
				
			if( !endOverlay.tutorialMode && endOverlay.score == 3 )//!sfsConnection.mySelf.isSpectator && 
				appModel.navigator.showOffer();
			dispatchEventWith(Event.COMPLETE);
		}
		
		
		private function tutorials_tasksFinishHandler(event:Event):void
		{
			tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_tasksFinishHandler);
			var tutorial:TutorialData = event.data as TutorialData;
			if( tutorial.name == "quest_2_end" )
			{
				if( player.buildings.exists(BuildingType.B11_BARRACKS) )
				{
					if( player.buildings.get(BuildingType.B11_BARRACKS).get_level() > 1 )
						UserData.instance.prefs.setInt(PrefsTypes.TUTE_STEP_101, PrefsTypes.TUTE_116_END);
					else
						UserData.instance.prefs.setInt(PrefsTypes.TUTE_STEP_101, PrefsTypes.TUTE_113_SELECT_DECK); 
				}
				else
				{
					UserData.instance.prefs.setInt(PrefsTypes.TUTE_STEP_101, PrefsTypes.TUTE_111_SELECT_EXCHANGE);
				}
				
				appModel.navigator.popToRootScreen();
				return;
			}

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
				var towers:SFSArray = event.params.room.getVariable("s").getValue() as SFSArray;
				var destination:int = event.params.room.getVariable("d").getValue();
				
				for( var i:int=0; i<towers.size(); i++ )
					appModel.battleFieldView.places[towers.getInt(i)].fight(appModel.battleFieldView.places[destination].place);
			}
			
			//sfsConnection.removeFromCommands(SFSCommands.FIGHT);
			
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
		private function resetAll(data:SFSObject):void
		{
			var bSize:int = data.getSFSArray("buildings").size();
			for( var i:int=0; i < bSize; i++ )
			{
				var b:ISFSObject = data.getSFSArray("buildings").getSFSObject(i);
				appModel.battleFieldView.places[b.getInt("i")].replaceBuilding(b.getInt("t"), b.getInt("l"));
				appModel.battleFieldView.places[b.getInt("i")].update(b.getInt("p"), b.getInt("tt"));
			}
		}
		
		// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- Touch Handler _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
		private function touchHandler(event:TouchEvent):void
		{
			var pv:PlaceView;
			var touch:Touch = event.getTouch(this);
			if(touch == null)
				return;
			
			if(touch.phase == TouchPhase.BEGAN)
			{
				sourcePlaces = new Vector.<PlaceView>();
				//trace("BEGAN", touch.target, touch.target.parent);
				if( !(touch.target.parent is PlaceView) )
					return;
				
				pv = touch.target.parent as PlaceView;
				
				if(pv.place.building.troopType != player.troopType)
					return;
				
				allPlacesInTouch = appModel.battleFieldView.battleData.battleField.getPlacesByTroopType(TroopType.NONE);
				sourcePlaces.push(pv);
			}
			else 
			{
				if( sourcePlaces == null || sourcePlaces.length == 0 )
					return;
				
				if( touch.phase == TouchPhase.MOVED )
				{
					pv = appModel.battleFieldView.dropTargets.contain(touch.globalX, touch.globalY) as PlaceView;
					if( pv != null && (PathFinder.find(sourcePlaces[0].place, pv.place, allPlacesInTouch) != null || sourcePlaces[0].place.building.troopType == pv.place.building.troopType))
					{
						// check next tower liked by selected places
						if(sourcePlaces.indexOf(pv)==-1 && pv.place.building.troopType == player.troopType)
							sourcePlaces.push(pv);
						endPoint.setTo(pv.x, pv.y);
					}
					else
					{
						endPoint.setTo((touch.globalX-appModel.battleFieldView.x)/appModel.scale, (touch.globalY-appModel.battleFieldView.y)/appModel.scale);
					}
					
					for each(pv in sourcePlaces)
					{
						pv.arrowContainer.visible = true;
						pv.arrowTo(endPoint.x-pv.x, endPoint.y-pv.y);
					}
				}
				else if(touch.phase == TouchPhase.ENDED)
				{
					var destination:PlaceView = appModel.battleFieldView.dropTargets.contain(touch.globalX, touch.globalY) as PlaceView;
					if( destination == null )
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
					if( bf.map.isQuest && !player.hardMode && improvable != null && bf.places.get(improvable.index).building.type == BuildingType.B01_CAMP && state == STATE_CREATED )
					{
						appModel.battleFieldView.places[improvable.index].decorator.improvablePanel.enabled = false;
						setTimeout(function():void{ appModel.battleFieldView.places[improvable.index].decorator.improvablePanel.enabled = true}, 500);
						clearSources(sourcePlaces);
						return;
					}

					// check sources has a path to destination
					for (var i:int = sourcePlaces.length-1; i>=0; i--)
					{
						if(sourcePlaces[i].place.building.troopType != player.troopType || PathFinder.find(sourcePlaces[i].place, destination.place, allPlacesInTouch) == null)
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
			allPlacesInTouch = null;
		}
		private function clearSource(sourceTower:PlaceView):void
		{
			sourceTower.arrowContainer.visible = false;
		}
		
		private function showImproveFloating(placeView:PlaceView):void
		{
			if( player.get_questIndex() < 2 || player.hardMode  )
				return;
			// create transition in data
			var ti:TransitionData = new TransitionData();
			ti.transition = Transitions.EASE_OUT_BACK;
			ti.sourceAlpha = 0;
			ti.sourcePosition = new Point(placeView.x*appModel.scale, placeView.y*appModel.scale+appModel.battleFieldView.y);
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
				state = STATE_STARTED;
				var btn:ImproveButton = event.data as ImproveButton;
				if( btn.locked )
				{
					if( player.get_arena(0) == 0 )
						appModel.navigator.addLog(loc("improve_locked_meaagse"));
					return;
				}
				if( !btn.touchGroup )
				{
					if( player.get_arena(0) == 0 )
						appModel.navigator.addLog(loc("improve_disabled_meaagse"));
					return;
				}
				appModel.battleFieldView.responseSender.improveBuilding(btn.building.index, btn.type);
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
			
			if( !appModel.battleFieldView.battleData.map.isQuest || player.inTutorial() )
				return;
				
			var confirm:ConfirmPopup = new ConfirmPopup(loc("leave_battle_confirm_message"), loc("retry_button"), loc("popup_exit_label"));
			confirm.declineStyle = "danger";
			confirm.addEventListener(Event.SELECT, confirm_eventsHandler);
			confirm.addEventListener(Event.CANCEL, confirm_eventsHandler);
			appModel.navigator.addPopup(confirm);
			function confirm_eventsHandler(event:Event):void {
				confirm.removeEventListener(Event.CANCEL, confirm_eventsHandler);
				confirm.removeEventListener(Event.SELECT, confirm_eventsHandler);

				appModel.battleFieldView.responseSender.leave(event.type == Event.SELECT);
				appModel.battleFieldView.battleData.isLeft = true;
				appModel.battleFieldView.responseSender.actived = false;
					
				if( event.type == Event.SELECT )
					retryQuest(appModel.battleFieldView.battleData.map.index, false);
			}
		}
		
		override public function dispose():void
		{
			player.inFriendlyBattle = false;
			removeConnectionListeners();
			appModel.sounds.stopAllSounds(SoundManager.CATE_THEME);
			setTimeout(appModel.sounds.playSoundUnique, 2000, "main-theme", 1, 100);
			removeChild(appModel.battleFieldView, true);
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
