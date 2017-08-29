package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.headers.LobbyHeader;
import com.gerantech.towercraft.controls.items.LobbyChatItemRenderer;
import com.gerantech.towercraft.controls.texts.CustomTextInput;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.MessageTypes;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

import flash.text.ReturnKeyLabel;
import flash.text.SoftKeyboardType;
import flash.utils.setTimeout;

import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;

import starling.events.Event;

public class LobbyChatSegment extends Segment
{
private var chatList:FastList;
private var inputText:CustomTextInput;
private var sendButton:CustomButton;
private var messageCollection:ListCollection;
private var header:LobbyHeader;
private var headerSize:int;
private var startScrollBarIndicator:Number = 0;

public function LobbyChatSegment()
{
	var params:SFSObject = new SFSObject();
	params.putInt("id", SFSConnection.instance.myLobby.id);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_getLobbyInfoHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_INFO, params, SFSConnection.instance.myLobby);
}

protected function sfs_getLobbyInfoHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.LOBBY_INFO )
		return;

	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_getLobbyInfoHandler);
	layout = new AnchorLayout();
	
	messageCollection = new ListCollection();
	var data:ISFSObject = event.params.params as SFSObject;
	for( var i:int=0; i<data.getSFSArray("messages").size(); i++ )
		messageCollection.addItem(data.getSFSArray("messages").getSFSObject(i));
	
	headerSize = 132 * appModel.scale;
	var footerSize:int = 120 * appModel.scale;
	var padding:int = 16 * appModel.scale;
	
	var chatLayout:VerticalLayout = new VerticalLayout();
	chatLayout.paddingTop = headerSize;
	chatLayout.useVirtualLayout = true;
	chatLayout.hasVariableItemDimensions = true;
	chatLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	
	chatList = new FastList();
	chatList.layout = chatLayout;
	chatList.layoutData = new AnchorLayoutData(0, 0, footerSize+padding, 0);
	chatList.itemRendererFactory = function ():IListItemRenderer { return new LobbyChatItemRenderer()};
	chatList.dataProvider = messageCollection;
	setTimeout(chatList.scrollToDisplayIndex, 100, messageCollection.length-1, 0.2);
	setTimeout(chatList.addEventListener, 1000, Event.SCROLL, chatList_scrollHandler);
	addChild(chatList);

	header = new LobbyHeader(SFSConnection.instance.myLobby);
	header.height = headerSize;
	header.layoutData = new AnchorLayoutData(NaN, 0, NaN, 0);
	addChild(header);
	
	inputText = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.DONE, 0xAAAAAA, false, appModel.align );
	inputText.textEditorProperties.autoCorrect = true;
	inputText.height = footerSize;
	inputText.layoutData = new AnchorLayoutData(NaN, footerSize + padding*2, 0, padding);
	inputText.addEventListener(FeathersEventType.ENTER, sendButton_triggeredHandler);
	addChild(inputText);
	
	sendButton = new CustomButton();
	sendButton.label = loc("lobby_send");
	sendButton.width = sendButton.height = footerSize;
	sendButton.layoutData = new AnchorLayoutData(NaN, padding, 0, NaN);
	sendButton.addEventListener(Event.TRIGGERED, sendButton_triggeredHandler);
	addChild(sendButton);
	
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_publicMessageHandler);
}

protected function chatList_scrollHandler(event:Event):void
{
	var scrollPos:Number = Math.max(0,chatList.verticalScrollPosition);
	var changes:Number = startScrollBarIndicator-scrollPos;
	header.y = Math.max(-headerSize, Math.min(0, header.y+changes));
	startScrollBarIndicator = scrollPos;
}

protected function sendButton_triggeredHandler(event:Event):void
{
	if( inputText.text == "" )
		return;
	
	var params:SFSObject = new SFSObject();
	params.putUtfString("t", StrUtils.getSimpleString(inputText.text));
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_PUBLIC_MESSAGE, params, SFSConnection.instance.myLobby );
	inputText.text = "";
}

protected function sfs_publicMessageHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.LOBBY_PUBLIC_MESSAGE )
		return;
	var msg:ISFSObject = event.params.params as SFSObject;
	var last:SFSObject = messageCollection.length > 0 ? SFSObject(messageCollection.getItemAt(messageCollection.length-1)) : null;
	if( last != null && msg.getShort("m") == MessageTypes.M0_TEXT && last.getShort("m") == MessageTypes.M0_TEXT && last.getInt("i") == msg.getInt("i") )
	{
		last.putInt("u", msg.getInt("u"));
		last.putUtfString("t", msg.getUtfString("t"));
		messageCollection.updateItemAt(messageCollection.length-1);
	}
	else
	{
		messageCollection.addItem(msg);
	}
	setTimeout(chatList.scrollToDisplayIndex, 100, messageCollection.length-1, 0.2);
}

override public function dispose():void
{
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_publicMessageHandler);
	super.dispose();
}

}
}