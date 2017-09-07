package com.gerantech.towercraft.controls
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.buttons.SimpleButton;
import com.gerantech.towercraft.controls.overlays.BaseOverlay;
import com.gerantech.towercraft.controls.overlays.WaitingOverlay;
import com.gerantech.towercraft.controls.popups.BasePopup;
import com.gerantech.towercraft.controls.popups.BugReportPopup;
import com.gerantech.towercraft.controls.popups.InvitationPopup;
import com.gerantech.towercraft.controls.popups.RestorePopup;
import com.gerantech.towercraft.controls.toasts.BaseToast;
import com.gerantech.towercraft.controls.toasts.ConfirmToast;
import com.gerantech.towercraft.events.LoadingEvent;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.utils.StrUtils;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.Buddy;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

import flash.utils.Dictionary;

import mx.resources.ResourceManager;

import avmplus.getQualifiedClassName;

import feathers.controls.LayoutGroup;
import feathers.controls.StackScreenNavigator;
import feathers.controls.StackScreenNavigatorItem;
import feathers.events.FeathersEventType;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class StackNavigator extends StackScreenNavigator
{
public function StackNavigator()
{
	addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	AppModel.instance.loadingManager.addEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
}

protected function loadingManager_loadedHandler(event:LoadingEvent):void
{
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_buddyBattleHandler);
}

private function addedToStageHandler(event:Event):void
{
	popups = new Vector.<BasePopup>();
	popupsContainer = new LayoutGroup();
	parent.addChild(popupsContainer);
	
	overlays = new Vector.<BaseOverlay>();
	overlaysContainer = new LayoutGroup();
	parent.addChild(overlaysContainer);
	
	logs = new Vector.<GameLog>();
	GameLog.MOVING_DISTANCE = -120 * AppModel.instance.scale
	GameLog.GAP = 80 * AppModel.instance.scale;
	logsContainer = new LayoutGroup();
	parent.addChild(logsContainer);
}		

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  POPUPS  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
private var popups:Vector.<BasePopup>;
private var popupsContainer:LayoutGroup;
public function addPopup(popup:BasePopup) : void
{
	for( var i:int=0; i<popups.length; i++)
	{
		if( getQualifiedClassName(popup) == getQualifiedClassName(popups[i]) )
			return;
	}
	
	popupsContainer.addChild(popup);
	popups.push(popup);
	popup.addEventListener(Event.CLOSE, popup_closeHandler); 
	function popup_closeHandler(event:Event):void {
		var p:BasePopup = event.currentTarget as BasePopup;
		p.removeEventListener(Event.CLOSE, popup_closeHandler);
		popups.removeAt(popups.indexOf(p));
	}
}


// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  OVERLAYS  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
private var overlays:Vector.<BaseOverlay>;
private var overlaysContainer:LayoutGroup;
public function addOverlay(overlay:BaseOverlay) : void
{
	for( var i:int=0; i<overlays.length; i++)
		if( getQualifiedClassName(overlay) == getQualifiedClassName(overlays[i]) )
			return;
	
	overlaysContainer.addChild(overlay);
	overlays.push(overlay);
	overlay.addEventListener(Event.CLOSE, overlay_closeHandler); 
	function overlay_closeHandler(event:Event):void {
		var o:BaseOverlay = event.currentTarget as BaseOverlay;
		o.removeEventListener(Event.CLOSE, overlay_closeHandler);
		overlays.removeAt(overlays.indexOf(o));
	}
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  OVERLAYS  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
public function addToast(toast:BaseToast) : void
{
	addPopup(toast);
}


// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  LOGS  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
private var logs:Vector.<GameLog>;
private var logsContainer:LayoutGroup;
private var busyLogger:Boolean;

private var battleconfirmToast:ConfirmToast;
public function addLog(text:String) : void
{
	addLogGame( new GameLog(text) );
}
public function addLogGame(log:GameLog) : void
{
	if( busyLogger )
		return;
	
	busyLogger = true;
	log.y = logs.length * GameLog.GAP + stage.stageHeight/2;
	logsContainer.addChild(log);
	logs.push(log);
	Starling.juggler.tween(logsContainer, 0.3, {y : logsContainer.y - GameLog.GAP, transition:Transitions.EASE_OUT, onComplete:function():void{busyLogger=false;}});
}


// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  BUG REPORT  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
public function showBugReportButton():void
{
	var bugReportButton:SimpleButton = new SimpleButton();
	bugReportButton.isLongPressEnabled = true;
	bugReportButton.alpha = AppModel.instance.game.player.inTutorial() ? 0 : 1;
	bugReportButton.addChild(new Image(Assets.getTexture("bug-icon", "gui")));
	bugReportButton.addEventListener(Event.TRIGGERED, bugReportButton_triggeredHandler);
	bugReportButton.addEventListener(FeathersEventType.LONG_PRESS, bugReportButton_longPressHandler);
	bugReportButton.x = 12 * AppModel.instance.scale;
	bugReportButton.y = stage.stageHeight - 300 * AppModel.instance.scale;
	bugReportButton.width = 120*AppModel.instance.scale;
	bugReportButton.scaleY = bugReportButton.scaleX;
	addChild(bugReportButton);
	function bugReportButton_triggeredHandler(event:Event):void {
		var reportPopup:BugReportPopup = new BugReportPopup();
		reportPopup.addEventListener(Event.COMPLETE, reportPopup_completeHandler);
		addPopup(reportPopup);
		function reportPopup_completeHandler(event:Event):void {
			var reportPopup:BugReportPopup = new BugReportPopup();
			addLog(ResourceManager.getInstance().getString("loc", "popup_bugreport_fine"));
		}
	}
	function bugReportButton_longPressHandler(event:Event):void {
		var restorePopup:RestorePopup = new RestorePopup();
		addPopup(restorePopup);
	}
	addEventListener(Event.CHANGE, changeHandler);
	function changeHandler(event:Event):void {
		removeChild(bugReportButton);
		addChild(bugReportButton);
		bugReportButton.y = stage.stageHeight - (activeScreenID==Main.BATTLE_SCREEN?150:300) * AppModel.instance.scale;
	}
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  INVOKE   -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
public function handleInvokes():void
{
	if( AppModel.instance.invokes != null )
		handleSchemeQuery( AppModel.instance.invokes );
}
private function handleSchemeQuery(arguments:Array):void
{
	for each( var a:String in arguments )
	{
		if( a.indexOf("open?")> -1 )
		{
			var pars:Dictionary = StrUtils.getParams(a.split("open?")[1]);
			switch ( pars["controls"] )
			{
				case "popup":
					if( pars["type"] == "invitation" )
					{
						var sfs:SFSObject = new SFSObject();
						sfs.putText("invitationCode", pars["ic"]);
						SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_responseHandler);
						SFSConnection.instance.sendExtensionRequest(SFSCommands.BUDDY_ADD, sfs);
						function sfsConnection_responseHandler(event:SFSEvent):void{
							if( event.params.cmd != SFSCommands.BUDDY_ADD )
								return
							SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_responseHandler);
							addPopup( new InvitationPopup(event.params.params ) );
						}
					}
					break;
				
				case "screen":
					pushScreen(pars["type"]);
					break;
			}
		}
	}
	AppModel.instance.invokes = null;			//trace("k:", a, "v:", pars[a]);	
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  BUDDY BATTLE  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
public function invokeBuddyBattle(buddy:Buddy):void
{
	var params:ISFSObject = new SFSObject();
	params.putInt("o", int(buddy.name));
	sendBattleRequest(params, 0);
}
private function sendBattleRequest(params:ISFSObject, state:int):void
{
	params.putShort("bs", state);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.BUDDY_BATTLE, params);
}
protected function sfs_buddyBattleHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.BUDDY_BATTLE )
		return;
	
	var params:ISFSObject = event.params.params as SFSObject;
	var imSubject:Boolean = params.getInt("s") == AppModel.instance.game.player.id;
	switch( params.getShort("bs") )
	{
		case 0:
			var acceptLabel:String = imSubject ? null : loc("lobby_battle_accept");
			var message:String = loc(imSubject ? "lobby_battle_me" : "buddy_battle_request", imSubject?[]:[params.getUtfString("sn")]);
			battleconfirmToast = new ConfirmToast(message, acceptLabel, loc("popup_cancel_label"));
			battleconfirmToast.acceptStyle = "danger";
			battleconfirmToast.declineStyle = "neutral";
			battleconfirmToast.addEventListener(Event.SELECT, toast_selectHandler);
			battleconfirmToast.addEventListener(Event.CANCEL, toast_cancelHandler);
			addToast(battleconfirmToast);
			function toast_selectHandler(event:Event):void {
				battleconfirmToast.removeEventListener(Event.SELECT, toast_selectHandler);
				battleconfirmToast.removeEventListener(Event.CANCEL, toast_cancelHandler);
				sendBattleRequest(params, 1);
			}
			function toast_cancelHandler(event:Event):void {
				battleconfirmToast.removeEventListener(Event.SELECT, toast_selectHandler);
				battleconfirmToast.removeEventListener(Event.CANCEL, toast_cancelHandler);
				sendBattleRequest(params, 3);
			}
			break;
		
		case 1:
			var item:StackScreenNavigatorItem = getScreen( Main.BATTLE_SCREEN );
			item.properties.isFriendly = true;
			item.properties.waitingOverlay = new WaitingOverlay() ;
			pushScreen( Main.BATTLE_SCREEN ) ;
			addOverlay( item.properties.waitingOverlay );	
			break;
		
		case 4:
			addLog(loc("buddy_battle_absent"));
			break;

		default:
			addLog(loc(params.getInt("c") == AppModel.instance.game.player.id?"buddy_battle_canceled_me":"buddy_battle_canceled_he"));
			break;
	}
	
	if( params.getShort("bs") > 0 && battleconfirmToast != null )
	{
		battleconfirmToast.close();
		battleconfirmToast = null;
	}
	
}
protected function loc(resourceName:String, parameters:Array=null, locale:String=null):String
{
	return ResourceManager.getInstance().getString("loc", resourceName, parameters, locale);
}
}
}