package com.gerantech.towercraft.controls
{
import com.gerantech.extensions.NativeAbilities;
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.animations.AchievedItem;
import com.gerantech.towercraft.controls.buttons.Indicator;
import com.gerantech.towercraft.controls.headers.Toolbar;
import com.gerantech.towercraft.controls.overlays.BaseOverlay;
import com.gerantech.towercraft.controls.overlays.BattleStartOverlay;
import com.gerantech.towercraft.controls.overlays.TutorialMessageOverlay;
import com.gerantech.towercraft.controls.popups.AbstractPopup;
import com.gerantech.towercraft.controls.popups.InvitationPopup;
import com.gerantech.towercraft.controls.popups.KeysPopup;
import com.gerantech.towercraft.controls.popups.LobbyDetailsPopup;
import com.gerantech.towercraft.controls.screens.DashboardScreen;
import com.gerantech.towercraft.controls.screens.FactionsScreen;
import com.gerantech.towercraft.controls.segments.SocialSegment;
import com.gerantech.towercraft.controls.toasts.BaseToast;
import com.gerantech.towercraft.controls.toasts.ConfirmToast;
import com.gerantech.towercraft.controls.toasts.SimpleToast;
import com.gerantech.towercraft.events.LoadingEvent;
import com.gerantech.towercraft.managers.BillingManager;
import com.gerantech.towercraft.managers.net.LoadingManager;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.utils.StrUtils;
import com.gerantech.towercraft.utils.Utils;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.utils.maps.IntStrMap;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.Buddy;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.utils.Dictionary;

import mx.resources.ResourceManager;

import avmplus.getQualifiedClassName;

import feathers.controls.LayoutGroup;
import feathers.controls.StackScreenNavigator;
import feathers.controls.StackScreenNavigatorItem;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;
import starling.textures.Texture;

public class StackNavigator extends StackScreenNavigator
{
public function StackNavigator()
{
	addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	addEventListener("itemAchieved", itemAchievedHandler);
	addEventListener(Event.CHANGE, navigator_changeHandler);
	AppModel.instance.loadingManager.addEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
}

private function navigator_changeHandler(event:Event):void
{
	if( toolbar && AppModel.instance.loadingManager.state >= LoadingManager.STATE_LOADED )
	{
		if( activeScreenID != Main.DASHBOARD_SCREEN && activeScreenID != Main.QUESTS_SCREEN )
		{
			toolbar.removeFromParent();
			return;
		}
		addChild(toolbar);
		toolbar.alpha = 0;
		toolbar.updateIndicators();
		Starling.juggler.tween(toolbar, 0.1, {delay:0.8, alpha:1});
	}
}
private function toolbar_selectHandler(event:Event):void
{
	if( AppModel.instance.game.player.inTutorial() )
		return;
	if( event.data.resourceType == ResourceType.POINT )
		FactionsScreen.showRanking( AppModel.instance.game.player.get_arena(0) );
	else if( event.data.resourceType == ResourceType.KEY )
		addPopup( new KeysPopup() );
}

protected function loadingManager_loadedHandler(event:LoadingEvent):void
{
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_buddyBattleHandler);
	SFSConnection.instance.lobbyManager.addEventListener(Event.OPEN, lobbyManager_friendlyBattleHandler);
	if( toolbar == null )
	{
		toolbar = new Toolbar();
		toolbar.width = stage.stageWidth;
		toolbar.addEventListener(Event.SELECT, toolbar_selectHandler);
		addChild(toolbar);
	}
}

private function addedToStageHandler(event:Event):void
{
	popups = new Vector.<AbstractPopup>();
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
private var popups:Vector.<AbstractPopup>;
private var popupsContainer:LayoutGroup;
public function addPopup(popup:AbstractPopup) : void
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
		var p:AbstractPopup = event.currentTarget as AbstractPopup;
		p.removeEventListener(Event.CLOSE, popup_closeHandler);
		popups.removeAt(popups.indexOf(p));
	}
}
public function removeAllPopups() : void
{
	popupsContainer.removeChildren(0, -1, true);
	popups = new Vector.<AbstractPopup>();
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  OVERLAYS  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
public var overlays:Vector.<BaseOverlay>;
private var overlaysContainer:LayoutGroup;
public function addOverlay(overlay:BaseOverlay) : void
{
	//for( var i:int=0; i<overlays.length; i++)
	//	if( getQualifiedClassName(overlay) == getQualifiedClassName(overlays[i]) )
	//		return;
	
	overlaysContainer.addChild(overlay);
	overlays.push(overlay);
	overlay.addEventListener(Event.CLOSE, overlay_closeHandler); 
	function overlay_closeHandler(event:Event):void {
		var o:BaseOverlay = event.currentTarget as BaseOverlay;
		o.removeEventListener(Event.CLOSE, overlay_closeHandler);
		overlays.removeAt(overlays.indexOf(o));
	}
}
public function removeAllOverlays():void
{
	overlaysContainer.removeChildren();
	while( overlays.length > 0 )
	{
		overlays[overlays.length-1].removeEventListeners(Event.CLOSE);
		overlays.removeAt(overlays.length-1);
	}
}
// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  TOSTS  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
public function addToast(toast:BaseToast) : void
{
	if( activeScreenID == Main.BATTLE_SCREEN )
		return;
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

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  ANIMATIONS  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
public var toolbar:Toolbar;
private function itemAchievedHandler(event:Event):void
{
	if( activeScreenID == Main.DASHBOARD_SCREEN || activeScreenID == Main.QUESTS_SCREEN )
		addResourceAnimation(event.data.x, event.data.y, event.data.type, event.data.count, event.data.index*0.2)	
}
public function addResourceAnimation(x:Number, y:Number, resourceType:int, count:int, delay:Number=0) : void
{
	var indicator:Indicator = Indicator(toolbar.indicators[resourceType]);
	indicator.value = AppModel.instance.game.player.resources.get(resourceType) - count;
	addAnimation(x, y, 140, Assets.getTexture("res-"+resourceType, "gui"), count, indicator.iconDisplay.getBounds(stage), delay, indicator.punch);
}
public function addAnimation(x:Number, y:Number, size:int, texture:Texture, count:int, zone:Rectangle, delay:Number=0, completeCallback:Function=null, prefix:String="") : void
{
	var anim:AchievedItem = new AchievedItem(texture, count, size, prefix);
	anim.x = x;
	anim.y = y;
	anim.scale = 0;
	Starling.juggler.tween(anim, 0.7, {delay:0.0+delay, scaleX:1.0, transition:Transitions.EASE_OUT_ELASTIC});
	Starling.juggler.tween(anim, 0.7, {delay:0.0+delay, scaleY:1.0, transition:Transitions.EASE_OUT_BACK});
	Starling.juggler.tween(anim, 0.5, {delay:1.5+delay, scale:0.3,  x:zone.x+zone.width/2, y:zone.y, transition:Transitions.EASE_IN, onComplete:function():void{if(completeCallback)completeCallback();anim.removeFromParent(true);}});
	parent.addChild(anim);
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  BUG REPORT  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
/*public function showBugReportButton():void
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
}*/

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  INVOKE   -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
public function handleURL(url:String):void
{
	if( url.substr(0,9) ==  "towers://" )
	{
		handleSchemeQuery([url.substr(9)]);
		return;
	}
	navigateToURL(new URLRequest(url));
}
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
						sfs.putText("udid", AppModel.instance.platform == AppModel.PLATFORM_ANDROID ? NativeAbilities.instance.deviceInfo.id : Utils.getPCUniqueCode());
						SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_responseHandler);
						SFSConnection.instance.sendExtensionRequest(SFSCommands.BUDDY_ADD, sfs);
						function sfsConnection_responseHandler(event:SFSEvent):void{
							if( event.params.cmd != SFSCommands.BUDDY_ADD )
								return
							SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_responseHandler);
							addPopup( new InvitationPopup(event.params.params ) );
						}
					}
					else if( pars["type"] == "lobbydetails" && !AppModel.instance.game.player.inTutorial() )
					{
						addPopup( new LobbyDetailsPopup({id:int(pars["id"])}) );
					}
						
					break;
				
				case "screen":
					pushScreen(pars["type"]);
					break;
				
				case "tabs":
					DashboardScreen.tabIndex = int(pars["dashTab"]);
					SocialSegment.tabIndex = int(pars["socialTab"]);
					popScreen();
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
			item.properties.waitingOverlay = new BattleStartOverlay(-1, false);
			addOverlay( item.properties.waitingOverlay );	
			pushScreen( Main.BATTLE_SCREEN ) ;
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
private function lobbyManager_friendlyBattleHandler(event:Event):void
{
	if( (activeScreenID==Main.DASHBOARD_SCREEN && DashboardScreen.tabIndex==3 && SocialSegment.tabIndex==2) || activeScreenID == Main.BATTLE_SCREEN )
		return;
	var battleToast:SimpleToast = new SimpleToast(loc("lobby_battle_request", [event.data]));
	battleToast.addEventListener(Event.SELECT, battleToast_selectHandler);
	addToast(battleToast);
	function battleToast_selectHandler():void {
		DashboardScreen.tabIndex = 3;
		SocialSegment.tabIndex = 2;
		battleToast.removeEventListener(Event.SELECT, battleToast_selectHandler);
		popToRootScreen();
	}
}


protected function loc(resourceName:String, parameters:Array=null, locale:String=null):String
{
	return ResourceManager.getInstance().getString("loc", resourceName, parameters, locale);
}

public function showOffer():void
{
	var sessions:int = AppModel.instance.game.sessionsCount;
	var prefs:IntStrMap = AppModel.instance.game.player.prefs;
	var type:int = 0;
	if( sessions > prefs.getAsInt(PrefsTypes.OFFER_30_RATING) )
		type = PrefsTypes.OFFER_30_RATING;
	else if( sessions > prefs.getAsInt(PrefsTypes.OFFER_31_TELEGRAM) )
		type = PrefsTypes.OFFER_31_TELEGRAM;
	else if( sessions > prefs.getAsInt(PrefsTypes.OFFER_32_INSTAGRAM) )
		type = PrefsTypes.OFFER_32_INSTAGRAM;
	else if( sessions > prefs.getAsInt(PrefsTypes.OFFER_33_FRIENDSHIP) )
		type = PrefsTypes.OFFER_33_FRIENDSHIP;
//trace(sessions, type, prefs.keys(), prefs.values());
	
	if( type > 0 )
	{
		var confirm:TutorialMessageOverlay = new TutorialMessageOverlay(new TutorialTask(TutorialTask.TYPE_CONFIRM, "popup_offer_"+type));
		confirm.addEventListener(Event.SELECT, confirm_handler);
		confirm.addEventListener(Event.CANCEL, confirm_handler);
		confirm.data = type;
		addOverlay(confirm);
		
		function confirm_handler(e:Event):void{
			confirm.removeEventListener(Event.SELECT, confirm_handler);
			confirm.removeEventListener(Event.CANCEL, confirm_handler);
			var t:int = int(confirm.data);
			if( e.type == Event.SELECT )
			{
				switch(t)
				{
					case PrefsTypes.OFFER_30_RATING:
						BillingManager.instance.rate();
						break;
					case PrefsTypes.OFFER_31_TELEGRAM:
						navigateToURL(new URLRequest(loc("setting_value_311")));
						break;
					case PrefsTypes.OFFER_32_INSTAGRAM:
						navigateToURL(new URLRequest(loc("setting_value_312")));
						break;
					case PrefsTypes.OFFER_33_FRIENDSHIP:
						DashboardScreen.tabIndex = 3;
						SocialSegment.tabIndex = 2;
						popToRootScreen();
						break;
				}
				UserData.instance.prefs.setInt(t, prefs.getAsInt(t)+1000);
			}
			else
			{
				UserData.instance.prefs.setInt(t, prefs.getAsInt(t)+50);
			}
		}
	}
}
}
}