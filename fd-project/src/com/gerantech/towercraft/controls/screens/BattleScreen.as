package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.BattleHUD;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.overlays.BattleStartOverlay;
import com.gerantech.towercraft.controls.overlays.BattleWaitingOverlay;
import com.gerantech.towercraft.controls.overlays.EndBattleOverlay;
import com.gerantech.towercraft.controls.overlays.EndOverlay;
import com.gerantech.towercraft.controls.overlays.EndQuestOverlay;
import com.gerantech.towercraft.controls.overlays.FactionChangeOverlay;
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
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.utils.maps.IntIntMap;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Point;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;

public class BattleScreen extends BaseCustomScreen
{
public static var IN_BATTLE:Boolean;

public var index:int;
public var battleType:String;
public var isFriendly:Boolean;
public var spectatedUser:String;
public var waitingOverlay:BattleWaitingOverlay;

private var hud:BattleHUD;
private var touchEnable:Boolean;
private var tutorBattleIndex:int;

public function BattleScreen()
{
	appModel.battleFieldView = new BattleFieldView();
	addChild(appModel.battleFieldView);
}
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	
	var params:SFSObject = new SFSObject();
	params.putText("type", battleType);
	params.putInt("index", index);
	if( spectatedUser != null && spectatedUser != "" )
		params.putText("spectatedUser", spectatedUser);

	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE,	sfsConnection_extensionResponseHandler);
	SFSConnection.instance.addEventListener(SFSEvent.CONNECTION_LOST,	sfsConnection_connectionLostHandler);
	if( !isFriendly )
		SFSConnection.instance.sendExtensionRequest(SFSCommands.BATTLE_START, params);
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
		appModel.battleFieldView.createPlaces(battleData);
		startBattle();
		break;
	
	case SFSCommands.BATTLE_END:
		endBattle(data);
		break;
	
	case SFSCommands.BATTLE_SEND_STICKER:
		hud.showBubble(data.getInt("t"), false);
		break;
	
	case SFSCommands.BATTLE_SUMMON_UNIT:
		for( var i:int = 0; i < data.getSFSArray("units").size(); i++ )
		{
			var sfs:ISFSObject = data.getSFSArray("units").getSFSObject(i);
			appModel.battleFieldView.summonUnit(sfs.getInt("i"), sfs.getInt("t"), sfs.getInt("l"), sfs.getInt("s"), sfs.getDouble("x"), sfs.getDouble("y"));
			if( i == 0 )
				appModel.sounds.addAndPlaySound(sfs.getInt("t") + "-summon");
		}
		break;
	
	case SFSCommands.BATTLE_HIT:
		appModel.battleFieldView.hitUnits(data.getInt("b"), data.getSFSArray("t"));
		//appModel.battleFieldView.battleData.battleField.units.get(data.getInt("t")).hit(data.getDouble("d"));
		//UnitView(appModel.battleFieldView.battleData.battleField.units.get(data.getInt("o"))).attacks(data.getInt("t"));
		break;
	
	case SFSCommands.BATTLE_NEW_ROUND:
		appModel.battleFieldView.battleData.battleField.requestReset();
		if( hud != null )
			hud.updateScores(data.getInt("round"), data.getInt("winner"), data.getInt(appModel.battleFieldView.battleData.battleField.side + ""), data.getInt(appModel.battleFieldView.battleData.battleField.side == 0 ? "1" : "0"), data.getInt("unitId"));
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
	
	IN_BATTLE = true;
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
		Starling.juggler.tween(appModel.battleFieldView, 1, {delay:1, scale:1, transition:Transitions.EASE_IN_OUT, onComplete:showTutorials});
		if( !player.inTutorial() )
			hud.addChildAt(new BattleStartOverlay(battleData.battleField.field.isOperation() ? battleData.battleField.field.index : -1, battleData ), 0);
	}
	
	// show battle HUD
	hud = new BattleHUD();
	hud.addEventListener(Event.CLOSE, backButtonHandler);
	hud.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChild(hud);
	
	resetAll(battleData.sfsData);
	appModel.battleFieldView.updateUnits();
	
	SFSConnection.instance.addEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, sfsConnection_roomVariablesUpdateHandler);
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
	tutorBattleIndex = Math.min(3, player.get_battleswins()) * 20;
	if( SFSConnection.instance.mySelf.isSpectator )
		return;

	//appModel.battleFieldView.createDrops();
	if( player.get_battleswins() > 2 )
	{
		readyBattle();
		return;
	}
	
	var field:FieldData = appModel.battleFieldView.battleData.battleField.field;
	if( player.tutorialMode == 0 && !field.isOperation() )
		return;

	// create tutorial steps
	var tutorialData:TutorialData = new TutorialData(field.name + "_start");
	tutorialData.data = "start";
	
	//quest start
	var tuteMessage:String = "";
	for (var i:int=0 ; i < field.startNum.size() ; i++) 
	{
		tuteMessage = "tutor_" + field.type + "_" + player.get_battleswins() + "_start_";
		tuteMessage += field.startNum.get(i);
		tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, tuteMessage, null, 500, 1500, field.startNum.get(i)));
	}
	
	tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_tasksFinishHandler);
	tutorials.show(tutorialData);
	
	UserData.instance.prefs.setInt(PrefsTypes.TUTOR, tutorBattleIndex + 1);
}

private function readyBattle() : void 
{
	touchEnable = true;
	hud.showDeck();
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- End Battle _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
private function endBattle(data:SFSObject, skipCelebration:Boolean = false):void
{
	IN_BATTLE = false;
	var inTutorial:Boolean = player.get_battleswins() < 3;
	appModel.battleFieldView.battleData.battleField.state = BattleField.STATE_4_ENDED;
	var field:FieldData = appModel.battleFieldView.battleData.battleField.field;

	// show celebration tutorial steps
	if( player.get_battleswins() == 0 && !skipCelebration )
	{
		var tutorialData:TutorialData = new TutorialData("tutor_battle_celebration");
		tutorialData.data = data;
		tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_" + field.type + "_" + player.get_battleswins() + "_celebration"));
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
	if( field.isOperation() )
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
		retryOperation(appModel.battleFieldView.battleData.battleField.field.index, false);
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
			retryOperation(appModel.battleFieldView.battleData.battleField.field.index, true);
		else
			dispatchEventWith(Event.COMPLETE);
		VideoAdsManager.instance.requestAd(VideoAdsManager.TYPE_OPERATIONS, true);
	}
}

private function retryOperation(index:int, hasExtraTime:Boolean):void
{
	waitingOverlay = new BattleWaitingOverlay(false);
	appModel.navigator.addOverlay(waitingOverlay);
	
	hud.removeFromParent(true);
	appModel.battleFieldView.responseSender.actived = false;
	disposeBattleAssets();
	removeChild(appModel.battleFieldView, true);
	
	var params:SFSObject = new SFSObject();
	params.putText("type", FieldData.TYPE_OPERATION);
	params.putInt("index", index);
	if( hasExtraTime )
		params.putBool("hasExtraTime", true);
	//if( spectatedUser != null && spectatedUser != "" )
	//sfsObj.putText("spectatedUser", spectatedUser);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE,	sfsConnection_extensionResponseHandler);
	SFSConnection.instance.addEventListener(SFSEvent.CONNECTION_LOST,	sfsConnection_connectionLostHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.BATTLE_START, params);
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
	
	var field:FieldData = appModel.battleFieldView.battleData.battleField.field;
	// set quest score
	if( field.isOperation() )
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
		readyBattle();
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
		appModel.battleFieldView.updateUnits();
	    //hud.updateRoomVars();
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

override protected function backButtonFunction():void
{
	if( SFSConnection.instance.lastJoinedRoom != null && SFSConnection.instance.mySelf.isSpectator )
	{
		appModel.battleFieldView.responseSender.leave();
		dispatchEventWith(Event.COMPLETE);
		return;
	}
	
	if( player.inTutorial() )
		return;
	
	if( !appModel.battleFieldView.battleData.battleField.field.isOperation() )
	{
		if( appModel.battleFieldView.battleData.battleField.startAt + appModel.battleFieldView.battleData.battleField.field.times.get(0) > timeManager.now )
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
			retryOperation(appModel.battleFieldView.battleData.battleField.field.index, false);
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
	SFSConnection.instance.removeEventListener(SFSEvent.CONNECTION_LOST,	sfsConnection_connectionLostHandler);
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
	SFSConnection.instance.removeEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, sfsConnection_roomVariablesUpdateHandler);
}
}
}