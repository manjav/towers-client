package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.items.LobbyChatItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
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

import flash.geom.Rectangle;
import flash.text.ReturnKeyLabel;
import flash.text.SoftKeyboardType;

import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.renderers.IListItemRenderer;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import starling.animation.Transitions;
import starling.events.Event;

public class LobbyPublicChatSegment extends Segment
{
protected var padding:int;
protected var footerSize:int;

protected var chatList:List;
protected var chatLayout:VerticalLayout;
protected var inputText:CustomTextInput;
protected var sendButton:CustomButton;
protected var _buttonsEnabled:Boolean = true;


public function LobbyPublicChatSegment(){}

public function get manager():LobbyManager
{
	if( SFSConnection.instance.publicLobbyManager == null )
		SFSConnection.instance.publicLobbyManager = new LobbyManager(true);
	return SFSConnection.instance.publicLobbyManager;
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	loadData();
}

protected function loadData():void
{
	if( manager == null )
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
	padding = 16 * appModel.scale;
	footerSize = 120 * appModel.scale;
	
	chatLayout = new VerticalLayout();
	chatLayout.paddingTop = padding * 2;
	chatLayout.hasVariableItemDimensions = true;
	chatLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	chatLayout.verticalAlign = VerticalAlign.BOTTOM;
	
	chatList = new List();
	chatList.layout = chatLayout;
	chatList.layoutData = new AnchorLayoutData(0, 0, footerSize+padding, 0);
	chatList.itemRendererFactory = function ():IListItemRenderer { return new LobbyChatItemRenderer()};
	chatList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	chatList.addEventListener(Event.CHANGE, chatList_changeHandler);
	chatList.addEventListener(FeathersEventType.FOCUS_IN, chatList_focusInHandler);
	chatList.addEventListener(FeathersEventType.CREATION_COMPLETE, chatList_createCompleteHandler);
	chatList.dataProvider = manager.messages;
	chatList.validate();
	addChild(chatList);

	inputText = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.DONE, 0xAAAAAA, false, appModel.align );
	inputText.textEditorProperties.autoCorrect = true;
	inputText.height = footerSize;
	inputText.layoutData = new AnchorLayoutData(NaN, footerSize + padding*2, 0, padding);
	inputText.addEventListener(FeathersEventType.ENTER, sendButton_triggeredHandler);
	addChild(inputText);
	
	sendButton = new CustomButton();
	sendButton.width = sendButton.height = footerSize;
	sendButton.icon = Assets.getTexture("tooltip-bg-bot-right", "gui");
	sendButton.iconLayout = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -4 * appModel.scale);
	sendButton.layoutData = new AnchorLayoutData(NaN, padding, 0, NaN);
	sendButton.addEventListener(Event.TRIGGERED, sendButton_triggeredHandler);
	addChild(sendButton);
	
	manager.addEventListener(Event.UPDATE, manager_updateHandler);
}

protected function chatList_createCompleteHandler(event:Event):void
{
	chatList.removeEventListener(FeathersEventType.CREATION_COMPLETE, chatList_createCompleteHandler);
	chatList.scrollToDisplayIndex(manager.messages.length-1);	
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

protected function chatList_focusInHandler(event:Event):void
{
	var selectedItem:LobbyChatItemRenderer = event.data as LobbyChatItemRenderer;
	if( selectedItem == null )
		return;
	
	var msgPack:ISFSObject = selectedItem.data as ISFSObject;
	
	// prevent hints for my messages
	if( msgPack.getInt("i") == player.id )
		return;
	
	// only for messages
	if( msgPack.getShort("m") != MessageTypes.M0_TEXT )
		return;
	
	var buttonsPopup:SimpleListPopup = new SimpleListPopup("lobby_profile", "lobby_report");
	buttonsPopup.data = msgPack;
	buttonsPopup.addEventListener(Event.SELECT, buttonsPopup_selectHandler);
	buttonsPopup.addEventListener(Event.CLOSE, buttonsPopup_selectHandler);
	buttonsPopup.padding = 24 * appModel.scale;
	buttonsPopup.buttonsWidth = 320 * appModel.scale;
	buttonsPopup.buttonHeight = 120 * appModel.scale;
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
			appModel.navigator.addPopup( new ProfilePopup(msgPack.getText("s"), int(msgPack.getInt("i"))) );
			break;
		case "lobby_report":
			var sfsReport:ISFSObject = new SFSObject();
			sfsReport.putUtfString("t", msgPack.getUtfString("t"));
			sfsReport.putInt("i", msgPack.getInt("i"));
			sfsReport.putInt("u", msgPack.getInt("u"));
			SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_reportResponseHandler);
			SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_REPORT, sfsReport, manager.lobby);
			break;
	}
	function sfs_reportResponseHandler(event:SFSEvent):void
	{
		if( event.params.cmd != SFSCommands.LOBBY_REPORT )
			return;
		SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_reportResponseHandler);
		appModel.navigator.addLog(loc("lobby_report_response_" + event.params.params.getInt("response")) );
	}
}

protected function manager_updateHandler(event:Event):void
{
	UserData.instance.lastLobbeyMessageTime = timeManager.now;
	buttonsEnabled = manager.getMyRequestBattleIndex() == -1;
	chatList.validate();
	chatList.scrollToDisplayIndex(manager.messages.length-1);	
}

protected function sendButton_triggeredHandler(event:Event):void
{
	if( inputText.text == "" )
		return;
	
	var params:SFSObject = new SFSObject();
	params.putUtfString("t", StrUtils.getSimpleString(inputText.text));
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_PUBLIC_MESSAGE, params, manager.lobby );
	inputText.text = "";
}

public function set buttonsEnabled(value:Boolean):void
{
	if( _buttonsEnabled == value )
		return;
	
	_buttonsEnabled = value;
	inputText.isEnabled = _buttonsEnabled;
	sendButton.isEnabled = _buttonsEnabled;
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