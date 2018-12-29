package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.items.lobby.LobbyChatItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.popups.ConfirmPopup;
import com.gerantech.towercraft.controls.popups.ProfilePopup;
import com.gerantech.towercraft.controls.popups.SimpleListPopup;
import com.gerantech.towercraft.controls.texts.CustomTextInput;
import com.gerantech.towercraft.managers.net.sfs.LobbyManager;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.MessageTypes;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import flash.geom.Rectangle;
import flash.text.ReturnKeyLabel;
import flash.text.SoftKeyboardType;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;

public class LobbyBaseChatSegment extends Segment
{
protected var padding:int;
protected var footerSize:int;
protected var chatList:FastList;
protected var chatLayout:VerticalLayout;
protected var chatTextInput:CustomTextInput;
protected var chatEnableButton:CustomButton;
protected var _buttonsEnabled:Boolean = true;
protected var _chatEnabled:Boolean = false;
protected var autoScroll:Boolean = true;

private var startScrollBarIndicator:Number = 0;
private var preText:String = "";

public function LobbyBaseChatSegment(){}

public function get manager():LobbyManager
{
	if( SFSConnection.instance.publicLobbyManager == null )
		SFSConnection.instance.publicLobbyManager = new LobbyManager(true);
	return SFSConnection.instance.publicLobbyManager;
}

override public function init():void
{
	if( initializeStarted )
		return;
	
	super.init();
	layout = new AnchorLayout();
	loadData();
}

protected function loadData():void
{

	if( manager == null || initializeCompleted )
		return;
	
	if( manager.isReady )
	{
		showElements();
		return;
	}
	manager.addEventListener(Event.READY, manager_readyHandler);
	manager.joinToPublic();
}

protected function manager_readyHandler(event:Event):void
{
	manager.removeEventListener(Event.READY, manager_readyHandler);
	showElements();
}

protected function showElements():void
{
	padding = 16;
	footerSize = 120;
	
	chatLayout = new VerticalLayout();
	chatLayout.paddingTop = padding * 2;
    chatLayout.paddingBottom = footerSize + padding * 2;
	chatLayout.hasVariableItemDimensions = true;
	chatLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	chatLayout.verticalAlign = VerticalAlign.BOTTOM;
	
	chatList = new FastList(false);
	chatList.layout = chatLayout;
    chatList.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	chatList.itemRendererFactory = function ():IListItemRenderer { return new LobbyChatItemRenderer()};
	chatList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	chatList.addEventListener(Event.CHANGE, chatList_changeHandler);
	chatList.addEventListener(FeathersEventType.FOCUS_IN, chatList_focusInHandler);
	chatList.addEventListener(FeathersEventType.CREATION_COMPLETE, chatList_createCompleteHandler);
	chatList.dataProvider = manager.messages;
	chatList.validate();
	chatList.loadingState = 1;
	addChild(chatList);

	chatTextInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.DONE, 0, false, appModel.align );
	chatTextInput.maxChars = 160;
	chatTextInput.textEditorProperties.autoCorrect = true;
	chatTextInput.height = footerSize;
    chatTextInput.layoutData = new AnchorLayoutData(NaN, padding, padding * 2, padding);
    chatTextInput.addEventListener(FeathersEventType.ENTER, sendButton_triggeredHandler);
    chatTextInput.addEventListener(FeathersEventType.FOCUS_OUT, chatTextInput_focusOutHandler);
	
    chatEnableButton = new CustomButton();
    chatEnableButton.width = chatEnableButton.height = footerSize;
    chatEnableButton.icon = Assets.getTexture("tooltip-bg-bot-right", "gui");
    chatEnableButton.iconLayout = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -4);
    chatEnableButton.layoutData = new AnchorLayoutData(NaN, padding, padding * 2, NaN);
    chatEnableButton.addEventListener(Event.TRIGGERED, chatButton_triggeredHandler);
    addChild(chatEnableButton);

	manager.addEventListener(Event.UPDATE, manager_updateHandler);
}

protected function chatList_createCompleteHandler(event:Event):void
{
	chatList.removeEventListener(FeathersEventType.CREATION_COMPLETE, chatList_createCompleteHandler);
	chatList.scrollToDisplayIndex(manager.messages.length - 1);
    setTimeout(chatList.addEventListener, 1000, Event.SCROLL, chatList_scrollHandler);
}

protected function chatList_changeHandler(event:Event):void
{
	if( chatList.selectedItem == null )
		return;
	var msgPack:ISFSObject = chatList.selectedItem as SFSObject;
	if( msgPack.getShort("m") == MessageTypes.M30_FRIENDLY_BATTLE  )
	{
		var myBattleId:int = manager.getMyRequestBattleId();
		if( myBattleId > -1 && msgPack.getInt("bid") != myBattleId )
			return;

		if( msgPack.getShort("st") > 1 )
			return;
		
		var params:SFSObject = new SFSObject();
		params.putShort("m", MessageTypes.M30_FRIENDLY_BATTLE);
		params.putInt("bid", msgPack.getInt("bid"));
		params.putShort("st", msgPack.getShort("st"));
		SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_PUBLIC_MESSAGE, params, manager.lobby );
	}
}

protected function chatList_scrollHandler(event:Event):void
{
    var scrollPos:Number = Math.max(0, chatList.verticalScrollPosition);
    scrollChatList(startScrollBarIndicator-scrollPos);
    startScrollBarIndicator = scrollPos;
}

protected function scrollChatList(changes:Number):void
{
	//trace(changes, chatList.verticalScrollPosition, chatList.maxVerticalScrollPosition)
    if( changes > 10 )
        autoScroll = false;
	else if ( chatList.verticalScrollPosition == chatList.maxVerticalScrollPosition )
        autoScroll = true;
}

protected function scrollToEnd():void
{
    chatList.scrollToDisplayIndex(manager.messages.length-1);
    autoScroll = true;
}

protected function chatList_focusInHandler(event:Event):void
{
    if( !_buttonsEnabled )
        return;
	var selectedItem:LobbyChatItemRenderer = event.data as LobbyChatItemRenderer;
	if( selectedItem == null )
		return;
	
	var msgPack:ISFSObject = selectedItem.data as ISFSObject;
	// prevent hints for my messages
	if( msgPack.getInt("i") != player.id && msgPack.getShort("m") == MessageTypes.M0_TEXT )
		showSimpleListPopup(msgPack, selectedItem, "lobby_report", "lobby_profile", "lobby_reply")
}

protected function showSimpleListPopup(msgPack:ISFSObject, selectedItem:LobbyChatItemRenderer, ... buttons):void
{
	var buttonsPopup:SimpleListPopup = new SimpleListPopup(buttons);
	buttonsPopup.buttons = buttons;
	buttonsPopup.data = msgPack;
	buttonsPopup.addEventListener(Event.SELECT, buttonsPopup_selectHandler);
	buttonsPopup.addEventListener(Event.CLOSE, buttonsPopup_selectHandler);
	buttonsPopup.padding = 24;
	buttonsPopup.buttonsWidth = 320;
	buttonsPopup.buttonHeight = 120;
	var floatingW:int = buttonsPopup.buttonsWidth + buttonsPopup.padding * 2;
	var floatingH:int = buttonsPopup.buttonHeight * buttonsPopup.buttons.length + buttonsPopup.padding * 2;
	var floatingY:int = selectedItem.getBounds(stage).y + floatingH * 0.5;
	var ti:TransitionData = new TransitionData(0.2);
	var to:TransitionData = new TransitionData(0.2);
	to.sourceConstrain = ti.destinationConstrain = this.getBounds(stage);
	ti.transition = Transitions.EASE_OUT_BACK;
	to.sourceAlpha = 1;
	to.destinationAlpha = 0;
	to.destinationBound = ti.sourceBound = new Rectangle(selectedItem.getTouch().globalX-floatingW/2, floatingY+buttonsPopup.buttonHeight/2-floatingH*0.4, floatingW, floatingH*0.8);
	to.sourceBound = ti.destinationBound = new Rectangle(selectedItem.getTouch().globalX-floatingW/2, floatingY+buttonsPopup.buttonHeight/2-floatingH*0.5, floatingW, floatingH);
	buttonsPopup.transitionIn = ti;
	buttonsPopup.transitionOut = to;
	appModel.navigator.addPopup(buttonsPopup);	
}
private function buttonsPopup_selectHandler(event:Event):void
{
	event.currentTarget.removeEventListener(Event.SELECT, buttonsPopup_selectHandler);
	event.currentTarget.removeEventListener(Event.CLOSE, buttonsPopup_selectHandler);
	
	if( event.type == Event.CLOSE )
		return;
	
	var buttonsPopup:SimpleListPopup = event.currentTarget as SimpleListPopup;
	var msgPack:ISFSObject = buttonsPopup.data as ISFSObject;
	switch( event.data )
	{
		case "lobby_profile":
            var user:Object = {name:msgPack.getUtfString("s"), id:int(msgPack.getInt("i"))};
            if( !manager.isPublic )
            {
                user.ln = manager.lobby.name;
                user.lp = manager.emblem;
            }
            appModel.navigator.addPopup( new ProfilePopup(user) );
			break;
		
		case "lobby_report":
			var confirm:ConfirmPopup = new ConfirmPopup(loc("popup_sure_label"), loc("popup_yes_label"));
			confirm.acceptStyle = "danger";
			confirm.addEventListener(Event.SELECT, confirm_selectHandler);
			appModel.navigator.addPopup(confirm);
			break;
		
		case "lobby_reply":
			chatButton_triggeredHandler(null);
			var msg:String = msgPack.getUtfString("t");
			preText = "@" + msgPack.getUtfString("s") + ": " + msg.substr(msg.lastIndexOf("\n") + 1, 20) + "... :\n";
			break;
	}
	function confirm_selectHandler(evet:Event):void
	{
		var sfsReport:ISFSObject = new SFSObject();
		sfsReport.putUtfString("t", msgPack.getUtfString("t"));
		sfsReport.putInt("i", msgPack.getInt("i"));
		sfsReport.putInt("u", msgPack.getInt("u"));
		SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_reportResponseHandler);
		SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_REPORT, sfsReport, manager.lobby);
	}
	function sfs_reportResponseHandler(e:SFSEvent):void
	{
		if( e.params.cmd != SFSCommands.LOBBY_REPORT )
			return;
		SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_reportResponseHandler);
		appModel.navigator.addLog(loc("lobby_report_response_" + e.params.params.getInt("response")) );
	}
}

protected function manager_updateHandler(event:Event):void
{
	if( Starling.current.nativeStage.frameRate < 1 )
		return;
	UserData.instance.lastLobbeyMessageTime = timeManager.now;
	buttonsEnabled = manager.getMyRequestBattleIndex() == -1;
	chatList.validate();
    if( autoScroll )
        scrollToEnd();
}

protected function chatButton_triggeredHandler(event:Event):void
{
	preText = "";
    enabledChatting(true);
	scrollToEnd();
    autoScroll = true;
}

protected function sendButton_triggeredHandler(event:Event):void
{
	if( chatTextInput.text == "" )
		return;
	if( areUVerbose() )
	{
		appModel.navigator.addLog(loc("lobby_message_limit"));
		return;
	}
	var params:SFSObject = new SFSObject();
	params.putUtfString("t", preText + StrUtils.getSimpleString(chatTextInput.text));
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_PUBLIC_MESSAGE, params, manager.lobby );
	chatTextInput.text = preText = "";
}

private function areUVerbose():Boolean 
{
	var last:ISFSObject = manager.messages.getItemAt(manager.messages.length - 1) as SFSObject;
	if ( last != null && last.getInt("i") == player.id && last.containsKey("t") )
		return (last.getText("t").split("\n").length > 5 );
	return false;
}

private function chatTextInput_focusOutHandler(event:Event):void
{
    setTimeout(enabledChatting, 100, false);
}

public function enabledChatting(value:Boolean):void
{
    if( _chatEnabled == value )
        return;
    
    _chatEnabled = value;
    
    if( _chatEnabled )
    {
        chatEnableButton.removeFromParent();
        addChild(chatTextInput);
        chatTextInput.setFocus();
    }
    else
    {
        chatTextInput.removeFromParent();
        addChild(chatEnableButton);
    }
}

public function set buttonsEnabled(value:Boolean):void
{
	if( _buttonsEnabled == value )
		return;
	
	_buttonsEnabled = value;
	chatTextInput.isEnabled = _buttonsEnabled;
    chatEnableButton.isEnabled = _buttonsEnabled;
    appModel.navigator.toolbar.touchable = false;
    chatList.verticalScrollPolicy = _buttonsEnabled ? ScrollPolicy.AUTO : ScrollPolicy.OFF;
	dispatchEventWith(Event.READY, true, _buttonsEnabled);
}

override public function dispose():void
{
	if( manager != null )
		manager.removeEventListener(Event.UPDATE, manager_updateHandler);
	super.dispose();
}
}
}