package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.BattleHUD;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.buttons.ImproveButton;
import com.gerantech.towercraft.controls.overlays.BattleStartOverlay;
import com.gerantech.towercraft.controls.overlays.BattleWaitingOverlay;
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
import com.gerantech.towercraft.models.vo.RewardData;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.models.vo.VideoAd;
import com.gerantech.towercraft.views.BattleFieldView;
import com.gt.towers.battle.BattleField;
import com.gt.towers.battle.fieldes.FieldData;
import com.gt.towers.battle.fieldes.PlaceData;
import com.gt.towers.constants.CardTypes;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.utils.maps.IntIntMap;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.SFSRoom;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSDataWrapper;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Point;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class BattleScreen extends BaseCustomScreen
{
public var isFriendly:Boolean;
public var requestField:FieldData;
public var spectatedUser:String;
public var waitingOverlay:BattleWaitingOverlay;

private var hud:BattleHUD;

private var endPoint:Point = new Point();
//private var sourcePlaces:Vector.<PlaceView>;
//private var allPlacesInTouch:PlaceList;

private var sfsConnection:SFSConnection;
private var timeoutId:uint;
private var transitionInCompleted:Boolean = true;

private var state:int = 0;
private static const STATE_CREATED:int = 0;
private static const STATE_STARTED:int = 1;
private var touchEnable:Boolean;
private var tutorBattleIndex:int;

public function BattleScreen(){}
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	//backgroundSkin = new Quad(1,1, BaseMetalWorksMobileTheme.CHROME_COLOR);
	
	var sfsObj:SFSObject = new SFSObject();
	sfsObj.putBool("q", requestField != null && requestField.isOperation);
	sfsObj.putInt("i", requestField != null && requestField.isOperation ? requestField.index : 0);
	if( spectatedUser != null && spectatedUser != "" )
		sfsObj.putText("su", spectatedUser);

	sfsConnection = SFSConnection.instance;
	sfsConnection.addEventListener(SFSEvent.EXTENSION_RESPONSE,	sfsConnection_extensionResponseHandler);
	sfsConnection.addEventListener(SFSEvent.CONNECTION_LOST,	sfsConnection_connectionLostHandler);
	if( !isFriendly )
		sfsConnection.sendExtensionRequest(SFSCommands.BATTLE_START, sfsObj);
	addEventListener(TouchEvent.TOUCH, touchHandler);
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
	case SFSCommands.BATTLE_START:
		if( data.containsKey("umt") )
		{
			showUnderMaintenancePopup(data);
			return;
		}
		
		var battleData:BattleData = new BattleData(data);
		appModel.battleFieldView = new BattleFieldView();
		addChild(appModel.battleFieldView);
		appModel.battleFieldView.createPlaces(battleData);
		startBattle();
		break;
	
	case SFSCommands.BATTLE_END:
		endBattle(data);
		break;
	
	case SFSCommands.BATTLE_SEND_STICKER:
		hud.showBubble(data.getInt("t"), false);
		break;
	
	case SFSCommands.BATTLE_DEPLOY_UNIT:
		appModel.battleFieldView.deployUnit(data.getInt("id"), data.getInt("t"), data.getInt("s"), data.getInt("l"), data.getDouble("x"), data.getDouble("y"));
		break;
	}
	//trace(event.params.cmd, data.getDump());
}

private function showUnderMaintenancePopup(data:SFSObject):void
{
	if( !waitingOverlay.ready )
	{
		waitingOverlay.addEventListener(Event.READY, waitingOverlay_readyHandler);
		function waitingOverlay_readyHandler():void {
			showUnderMaintenancePopup(data);
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
	
	tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_STARTED, tutorials_tasksStartHandler);
	var battleData:BattleData = appModel.battleFieldView.battleData;
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
	waitingOverlay.addEventListener(Event.CLOSE, waitingOverlay_closeHandler);
	function waitingOverlay_closeHandler(e:Event):void 
	{
		tutorials.removeAll();
		waitingOverlay.removeEventListener(Event.CLOSE, waitingOverlay_closeHandler);
		var fscale:Number = player.get_arena(0) == 0 ? 1.2 : 1;
		Starling.juggler.tween(appModel.battleFieldView, 1, {delay:1, scale:fscale, transition:Transitions.EASE_IN_OUT, onComplete:showTutorials});
		if( !player.inTutorial() )
			hud.addChildAt(new BattleStartOverlay(battleData.battleField.map.isOperation ? battleData.battleField.map.index : -1, battleData ), 0);
	}
	
	// show battle HUD
	hud = new BattleHUD();
	hud.addEventListener(Event.CLOSE, backButtonHandler);
	hud.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChild(hud);
	
	resetAll(battleData.sfsData);
	updateTowersFromRoomVars();
	
	sfsConnection.addEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, sfsConnection_roomVariablesUpdateHandler);
	appModel.loadingManager.serverData.putBool("inBattle", false);
	
	// play battle theme -_-_-_
	appModel.sounds.stopSound("main-theme");
	appModel.sounds.addSound("battle-theme", null,  themeLoaded, SoundManager.CATE_THEME);
	function themeLoaded():void { appModel.sounds.playSoundUnique("battle-theme", 0.8, 100); }
}

private function tutorials_tasksStartHandler(e:Event) : void
{
	/*clearSources(sourcePlaces);
	sourcePlaces = null;*/
}

private function showTutorials() : void 
{
	touchEnable = true;
	tutorBattleIndex = Math.min(3, player.get_battleswins()) * 20;
	if( sfsConnection.mySelf.isSpectator )
		return;

	//appModel.battleFieldView.createDrops();
	if( player.get_battleswins() > 2 )
	{
		touchEnable = true;
		return;
	}
	
	var field:FieldData = appModel.battleFieldView.battleData.battleField.map;
	if( player.tutorialMode == 0 && !field.isOperation )
		return;

	// create tutorial steps
	var tutorialData:TutorialData = new TutorialData(field.name + "_start");
	tutorialData.data = "start";
	
	//quest start
	var tuteMessage:String = "";
	for (var i:int=0 ; i < field.startNum.size() ; i++) 
	{
		tuteMessage = "tutor_" + field.name + "_start_";
		tuteMessage += field.startNum.get(i);
		trace("tuteMessage:", tuteMessage);
		tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, tuteMessage, null, 500, 1500, field.startNum.get(i)));
	}
	
	if( !player.hardMode )
	{
		/*var places:PlaceDataList = field.getSwipeTutorPlaces();
		if( places.size() > 0 )
			tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_SWIPE, null, places, 0, 1500));
		
		var place:PlaceData = field.getImprovableTutorPlace()
		if( place != null )
		{
			places = new PlaceDataList();
			places.push(place);
			tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_TOUCH, null, places, 0, 0));
		}*/
	}
	tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_tasksFinishHandler);
	tutorials.show(tutorialData);
	
	UserData.instance.prefs.setInt(PrefsTypes.TUTOR, tutorBattleIndex + 1);
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- End Battle _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
private function endBattle(data:SFSObject, skipCelebration:Boolean = false):void
{
	var inTutorial:Boolean = player.get_battleswins() < 3;
	var field:FieldData = appModel.battleFieldView.battleData.battleField.map;

	// show celebration tutorial steps
	if( player.get_battleswins() == 0 && !skipCelebration )
	{
		var tutorialData:TutorialData = new TutorialData("tutor_battle_celebration");
		tutorialData.data = data;
		tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_battle_" + player.get_battleswins() + "_celebration"));
		tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_tasksFinishHandler);
		tutorials.show(tutorialData);
		return;
	}

	touchEnable = false;
	disposeBattleAssets();
	hud.stopTimers();
	tutorials.removeAll();
	
	var rewards:ISFSArray = data.getSFSArray("outcomes");
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
		var bookKey:String = null;
		var _keys:Array = item.getKeys();
		for( i = 0; i < _keys.length; i++)
		{
			var key:int = int(_keys[i]);
			if( ResourceType.isBook(key) )
				bookKey = _keys[i];
			else if( key > 0 )
				outcomes.set(key, item.getInt(_keys[i]));
		}
		if( bookKey != null )
			outcomes.set(int(bookKey), item.getInt(bookKey));
	}
	
	appModel.battleFieldView.battleData.outcomes = new Vector.<RewardData>();
	
	// arena changes manipulation
	var prevArena:int = 0;
	var nextArena:int = 0;
	if( playerIndex > -1 )
	{
		prevArena = player.get_arena(0);
		player.addResources(outcomes);
		nextArena = player.get_arena(0);
	}
	
	// reserved prefs data
	if( inTutorial && rewards.getSFSObject(0).getInt("score") > 0 )
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, tutorBattleIndex + 7);
	
	var endOverlay:EndOverlay;
	if( field.isOperation )
	{
		endOverlay = new EndQuestOverlay(playerIndex, rewards, inTutorial);
	}
	else
	{
		endOverlay = new EndBattleOverlay(playerIndex, rewards, inTutorial);
		if( playerIndex > -1 && prevArena != nextArena )
			endOverlay.data = [prevArena, nextArena];
	}
	endOverlay.addEventListener(Event.CLOSE, endOverlay_closeHandler);
	endOverlay.addEventListener(FeathersEventType.CLEAR, endOverlay_retryHandler);
	
	setTimeout(hud.end, player.get_arena(0) == 0?800:0, endOverlay);// delay for noobs
}

private function disposeBattleAssets():void
{
	appModel.sounds.stopSound("battle-theme");
	appModel.sounds.stopSound("battle-clock-ticking");			
}

private function endOverlay_retryHandler(event:Event):void
{
	event.currentTarget.removeEventListener(Event.CLOSE, endOverlay_closeHandler);
	event.currentTarget.removeEventListener(FeathersEventType.CLEAR, endOverlay_retryHandler);
	if( event.data && player.prefs.getAsBool(PrefsTypes.SETTINGS_5_REMOVE_ADS) ) 
		showExtraTimeAd();
	else
		retryQuest(appModel.battleFieldView.battleData.map.index, false);
}

private function showExtraTimeAd():void
{
	VideoAdsManager.instance.addEventListener(Event.COMPLETE, videoIdsManager_completeHandler);
	VideoAdsManager.instance.showAd(VideoAdsManager.TYPE_OPERATIONS);
	function videoIdsManager_completeHandler(event:Event):void
	{
		VideoAdsManager.instance.removeEventListener(Event.COMPLETE, videoIdsManager_completeHandler);
		var ad:VideoAd = event.data as VideoAd;
		if( ad.completed && ad.rewarded )
			retryQuest(appModel.battleFieldView.battleData.map.index, true);
		else
			dispatchEventWith(Event.COMPLETE);
		VideoAdsManager.instance.requestAd(VideoAdsManager.TYPE_OPERATIONS, true);
	}
}

private function retryQuest(index:int, hasExtraTime:Boolean):void
{
	waitingOverlay = new BattleWaitingOverlay(false);
	appModel.navigator.addOverlay(waitingOverlay);
	
	hud.removeFromParent(true);
	appModel.battleFieldView.responseSender.actived = false;
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
	sfsConnection.sendExtensionRequest(SFSCommands.BATTLE_START, sfsObj);
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
	if( field.isOperation )
	{
		if( player.operations.get( field.index ) < endOverlay.score )
			player.operations.set(field.index, endOverlay.score);
	}
	else
	{
		appModel.battleFieldView.responseSender.leave();
	}
	appModel.battleFieldView.responseSender.actived = false;
	
	// create end tutorial steps
	if( endOverlay.inTutorial )
	{
		var winStr:String = endOverlay.winRatio >= 1 ? "_win_" : "_defeat_";
		var task:TutorialTask
		var tutorialData:TutorialData = new TutorialData(field.name + "_end");
		tutorialData.data = "end";
		for ( var i:int=0; i < field.endNum.size() ; i++ )
		{
			task = new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_" + field.name + "_end" + winStr + field.endNum.get(i));
			task.data = field.endNum.get(i);
			tutorialData.addTask(task);
		}
		tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_tasksFinishHandler);
		tutorials.show(tutorialData);
		return;
	}
	
	/*if ( player.tutorialMode == 1 && endOverlay.winRatio < 1 && player.emptyDeck() )
	{
		tutorialData = new TutorialData("tutor_upgrade");
		tutorialData.data = endOverlay.winRatio;
		tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_upgrade"));
		tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_tasksFinishHandler);
		tutorials.show(tutorialData);
		return;
	}*/
	
	// show faction changes overlay
	if( endOverlay.data != null )
		setTimeout(appModel.navigator.addOverlay, 2200, new FactionChangeOverlay(endOverlay.data[0], endOverlay.data[1]));

	if( !player.inTutorial() && endOverlay.score == 3 && player.get_arena(0) > 0 )//!sfsConnection.mySelf.isSpectator && 
		appModel.navigator.showOffer();
	dispatchEventWith(Event.COMPLETE);
}


private function tutorials_tasksFinishHandler(event:Event):void
{
	tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_tasksFinishHandler);
	var tutorial:TutorialData = event.data as TutorialData;
	if( tutorial.data == "start" )
	{
		touchEnable = true;
		return;
	}
	
	if( tutorial.name == "tutor_battle_celebration" )
	{
		endBattle(tutorial.data as SFSObject, true);
		return;
	}
	if( player.get_battleswins() == 2 )
	{
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_031_SLOT_FOCUS);
		appModel.navigator.popToRootScreen();
		return;
	}
	dispatchEventWith(Event.COMPLETE);
}

protected function sfsConnection_roomVariablesUpdateHandler(event:SFSEvent):void
{
	if( event.params.changedVars.indexOf("units") > -1 )
	{
		updateTowersFromRoomVars();
	    hud.updateRoomVars();
	}

	/*if( event.params.changedVars.indexOf("s") > -1 )
	{
		var room:SFSRoom = SFSRoom(event.params.room);
		var towers:ISFSArray = room.getVariable("s").getSFSArrayValue();
		var destination:int = room.getVariable("d").getIntValue();
		var troopsDivision:Number = room.getVariable("n").getDoubleValue();
		
		for( var i:int=0; i<towers.size(); i++ )
			appModel.battleFieldView.places[towers.getInt(i)].fight(appModel.battleFieldView.places[destination].place, troopsDivision);
	}*/
	//sfsConnection.removeFromCommands(SFSCommands.FIGHT);
}

private function updateTowersFromRoomVars():void
{
	if( !appModel.battleFieldView.battleData.room.containsVariable("units") )
		return;
	var towers:SFSArray = appModel.battleFieldView.battleData.room.getVariable("units").getValue() as SFSArray;
	/*for(var i:int=0; i<towers.size(); i++)
	{
		var wrapped:SFSDataWrapper = towers.getWrappedElementAt(i);
		if( wrapped.type == 20 )
		{
			var t:Array = wrapped.data.split(",");//trace(t)
			appModel.battleFieldView.places[t[0]].update(t[1], t[2]);
		}
		else if( wrapped.type == 5 )
		{
			timeManager.setNow(int(wrapped.data / 1000));
		}
	}*/
}
private function resetAll(data:ISFSObject):void
{
	if( !data.containsKey("buildings") )
		return;
	/*var bSize:int = data.getSFSArray("buildings").size();
	for( var i:int=0; i < bSize; i++ )
	{
		var b:ISFSObject = data.getSFSArray("buildings").getSFSObject(i);
		appModel.battleFieldView.places[b.getInt("i")].replaceBuilding(b.getInt("t"), b.getInt("l"), b.getInt("tt"), b.getInt("p"));
	}*/
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- Touch Handler _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
private function touchHandler(event:TouchEvent):void
{
	if( !touchEnable )
		return;
	/*var pv:PlaceView;
	var touch:Touch = event.getTouch(this);
	if( touch == null )
		return;
	
	if( touch.phase == TouchPhase.BEGAN )
	{
		sourcePlaces = new Vector.<PlaceView>();
		//trace("BEGAN", touch.target, touch.target.parent);
		if( !(touch.target.parent is PlaceView) )
			return;
		
		pv = touch.target.parent as PlaceView;
		
		if( pv.place.building.troopType != player.troopType )
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
			if( pv != null && (PathFinder.find(sourcePlaces[0].place, pv.place, allPlacesInTouch) != null || sourcePlaces[0].place.building.troopType == pv.place.building.troopType) )
			{
				// check next tower liked by selected places
				if( sourcePlaces.indexOf(pv)==-1 && pv.place.building.troopType == player.troopType )
					sourcePlaces.push(pv);
				endPoint.setTo(pv.x, pv.y);
				
				// show drop zone
				for each( var tp:PlaceView in appModel.battleFieldView.places )
					tp.hilight(tp == pv && sourcePlaces[0] != pv);
			}
			else
			{
				endPoint.setTo((touch.globalX), (touch.globalY));
				
				for each( pv in appModel.battleFieldView.places )
					pv.hilight(false);
			}
			
			for each( pv in sourcePlaces )
			{
				pv.arrowContainer.visible = true;
				pv.arrowTo(endPoint.x - pv.x, endPoint.y - pv.y);
			}
		}
		else if( touch.phase == TouchPhase.ENDED )
		{
			if( sourcePlaces == null )
				return;
			
			var destination:PlaceView = appModel.battleFieldView.dropTargets.contain(touch.globalX, touch.globalY) as PlaceView;
			if( destination == null )
			{
				clearSources(sourcePlaces);
				return;
			}
			
			// remove destination from sources if exists
			var self:int = sourcePlaces.indexOf(destination);
			if( self > -1 )
			{
				if( sourcePlaces.length == 1 )
				{
					sourcePlaces[0].dispatchEventWith(Event.SELECT);
					showImproveFloating(sourcePlaces[0]);
				}
				
				clearSource(sourcePlaces[self]);
				sourcePlaces.removeAt(self);
			}
			
			// force improve in tutorial mode
			if( state == STATE_CREATED && tutorials.forceImprove() )
			{
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
			
			// no fihgters
			if( sourcePlaces.length == 0 )
			{
				clearSources(sourcePlaces);
				return;
			}
			
			// force aggregation swipe in tutorial mode
			if( tutorials.forceAggregateSwipe(sourcePlaces, destination) )
			{
				clearSources(sourcePlaces);
				return;
			}
			
			// send fight data to room
			UserData.instance.prefs.setInt(PrefsTypes.TUTOR, tutorBattleIndex + 4);
			appModel.battleFieldView.responseSender.fight(sourcePlaces, destination);
			clearSources(sourcePlaces);
		}
	}*/
}

/**
 * Clear swiping mode
 * @param	sourceTowers

private function clearSources(sourceTowers:Vector.<PlaceView>):void
{
	for each( var tp:PlaceView in sourceTowers )
		clearSource(tp);
		
	for each( tp in appModel.battleFieldView.places )
		tp.hilight(false);

	sourceTowers = null;
	allPlacesInTouch = null;
}
private function clearSource(sourceTower:PlaceView):void
{
	sourceTower.arrowContainer.visible = false;
	sourceTower.hilight(false);
}

private function showImproveFloating(placeView:PlaceView):void
{
	if( player.inTutorial() && player.emptyDeck() )
		return;
	
	// create transition in data
	var ti:TransitionData = new TransitionData();
	ti.transition = Transitions.EASE_OUT_BACK;
	ti.sourceAlpha = 0;
	ti.destinationPosition = ti.sourcePosition = new Point(placeView.x, placeView.y);
	
	// create transition out data
	var to:TransitionData = new TransitionData();
	to.sourceAlpha = 1;
	to.destinationPosition = to.sourcePosition = ti.sourcePosition;
	
	var floating:ImproveFloating = new ImproveFloating();
	floating.placeView = placeView;
	floating.transitionIn = ti;
	floating.transitionOut = to;
	floating.addEventListener(Event.CLOSE, floating_closeHandler);
	floating.addEventListener(Event.SELECT, floating_selectHandler);
	appModel.battleFieldView.addChild(floating);
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
			if( player.get_arena(0) <= 1 )
				appModel.navigator.addLog(loc("improve_locked_meaagse"));
			return;
		}
		else if( !btn.enabled )
		{
			if( player.get_arena(0) <= 1 )
				appModel.navigator.addLog(loc("improve_disabled_meaagse"));
			return;
		}
		appModel.battleFieldView.responseSender.improveBuilding(btn.building.place.index, btn.type);
		if( player.getTutorStep() == tutorBattleIndex + 1 )
		{
			UserData.instance.prefs.setInt(PrefsTypes.TUTOR, tutorBattleIndex + 2);
			if( player.getTutorStep() == PrefsTypes.T_042_IMPROVE )
			{
				var tutorialData:TutorialData = new TutorialData("after_improve");
				tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_battle_3_mid_2"));
				tutorials.show(tutorialData);
			}
		}
	}
}*/
 
override protected function backButtonFunction():void
{
	if( sfsConnection.lastJoinedRoom != null && sfsConnection.mySelf.isSpectator )
	{
		appModel.battleFieldView.responseSender.leave();
		dispatchEventWith(Event.COMPLETE);
		return;
	}
	
	if( player.inTutorial() )
		return;
	
	if( !appModel.battleFieldView.battleData.map.isOperation )
	{
		if( appModel.battleFieldView.battleData.startAt + appModel.battleFieldView.battleData.map.times.get(0) > timeManager.now )
			return;
		var confirm:ConfirmPopup = new ConfirmPopup(loc("leave_battle_confirm_message"));
		confirm.acceptStyle = CustomButton.STYLE_DANGER;
		confirm.addEventListener(Event.SELECT, confirm_selectsHandler);
		appModel.navigator.addPopup(confirm);
		function confirm_selectsHandler(event:Event):void 
		{
			confirm.removeEventListener(Event.SELECT, confirm_selectsHandler);
			appModel.battleFieldView.responseSender.leave();
		}
		return;
	}

	confirm = new ConfirmPopup(loc("leave_operation_confirm_message"), loc("retry_button"));
	confirm.acceptStyle = CustomButton.STYLE_NEUTRAL;
	confirm.addEventListener(Event.SELECT, confirm_eventsHandler);
	confirm.addEventListener(Event.CANCEL, confirm_eventsHandler);
	appModel.navigator.addPopup(confirm);
	function confirm_eventsHandler(event:Event):void 
	{
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
	appModel.sounds.stopAllSounds(SoundManager.CATE_SFX);
	appModel.sounds.stopAllSounds(SoundManager.CATE_THEME);
	setTimeout(appModel.sounds.playSoundUnique, 2000, "main-theme", 1, 100);
	removeChild(appModel.battleFieldView, true);
	super.dispose();
}

private function removeConnectionListeners():void
{
	if( tutorials != null )
		tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_STARTED, tutorials_tasksStartHandler);
	removeEventListener(TouchEvent.TOUCH, touchHandler);
	sfsConnection.removeEventListener(SFSEvent.CONNECTION_LOST,	sfsConnection_connectionLostHandler);
	sfsConnection.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
	sfsConnection.removeEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, sfsConnection_roomVariablesUpdateHandler);
}
}
}