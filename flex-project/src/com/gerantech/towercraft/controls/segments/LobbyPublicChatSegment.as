package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.items.LobbyChatItemRenderer;
import com.gerantech.towercraft.controls.texts.CustomTextInput;
import com.gerantech.towercraft.managers.net.sfs.LobbyManager;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.MessageTypes;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

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

import starling.events.Event;

public class LobbyPublicChatSegment extends Segment
{
private var chatList:List;
private var inputText:CustomTextInput;
private var sendButton:CustomButton;
private var _buttonsEnabled:Boolean = true;
private var manager:LobbyManager;

public function LobbyPublicChatSegment()
{
	manager = SFSConnection.instance.publicLobbyManager;
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	if( manager != null && manager.isReady )
		showElements();
	else
		showRequestMode();
}

private function showRequestMode():void
{
	if( manager == null )
		manager = SFSConnection.instance.publicLobbyManager = new LobbyManager(true);
	manager.addEventListener(Event.READY, manager_readyHandler);
	manager.joinToPublic();
}

private function manager_readyHandler(event:Event):void
{
	manager.removeEventListener(Event.READY, manager_readyHandler);
	showElements();
}

private function showElements():void
{
	var footerSize:int = 120 * appModel.scale;
	var padding:int = 16 * appModel.scale;
	
	var chatLayout:VerticalLayout = new VerticalLayout();
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
	chatList.addEventListener(Event.ROOT_CREATED, chatList_triggeredHandler);
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

	UserData.instance.lastLobbeyMessageTime = timeManager.now;
	UserData.instance.save();
}

private function chatList_createCompleteHandler():void
{
	chatList.removeEventListener(FeathersEventType.CREATION_COMPLETE, chatList_createCompleteHandler);
	chatList.scrollToDisplayIndex(manager.messages.length-1);	
}

private function chatList_triggeredHandler(event:Event):void
{
	var params:SFSObject = event.data as SFSObject;
	if( MessageTypes.isConfirm(params.getShort("m")) )
		SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_PUBLIC_MESSAGE, params, manager.lobby );
}

private function manager_updateHandler(event:Event):void
{
	UserData.instance.lastLobbeyMessageTime = timeManager.now;
	buttonsEnabled = manager.getMyRequestBattleIndex() == -1;
	chatList.validate();
	chatList.scrollToDisplayIndex(manager.messages.length-1);	
}

private function chatList_changeHandler(event:Event):void
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