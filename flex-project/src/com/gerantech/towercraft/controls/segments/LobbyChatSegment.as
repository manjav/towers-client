package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.items.LobbyChatItemRenderer;
import com.gerantech.towercraft.controls.texts.CustomTextInput;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.utils.StrUtils;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.Room;
import com.smartfoxserver.v2.entities.data.ISFSArray;
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
private var room:Room;
private var chatList:FastList;
private var inputText:CustomTextInput;
private var sendButton:CustomButton;
private var messageCollection:ListCollection;

public function LobbyChatSegment()
{
	room = SFSConnection.instance.lastJoinedRoom;
	var params:SFSObject = new SFSObject();
	params.putInt("id", room.id);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_getRoomInfoHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_INFO, params, room);
}

protected function sfsConnection_getRoomInfoHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.LOBBY_INFO )
		return;

	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_getRoomInfoHandler);
	layout = new AnchorLayout();
	
	messageCollection = new ListCollection();
	var data:ISFSObject = event.params.params as SFSObject;;
	for( var i:int=0; i<data.getSFSArray("messages").size(); i++ )
		messageCollection.addItem(data.getSFSArray("messages").getSFSObject(i));
	
	var chatLayout:VerticalLayout = new VerticalLayout();
	chatLayout.useVirtualLayout = true;
	chatLayout.hasVariableItemDimensions = true;
	chatLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	
	var footerSize:int = 120 * appModel.scale;
	var padding:int = 16 * appModel.scale;
	
	chatList = new FastList();
	chatList.layout = chatLayout;
	chatList.layoutData = new AnchorLayoutData(0, 0, footerSize+padding, 0);
	chatList.itemRendererFactory = function ():IListItemRenderer { return new LobbyChatItemRenderer()};
	chatList.dataProvider = messageCollection;
	addChild(chatList);
	chatList.scrollToPosition(NaN, chatList.maxVerticalScrollPosition+100*appModel.scale);

	inputText = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.DONE );
	inputText.textEditorProperties.autoCorrect = true;
	inputText.height = footerSize;
	inputText.layoutData = new AnchorLayoutData(NaN, footerSize + padding, 0, 0);
	inputText.addEventListener(FeathersEventType.ENTER, sendButton_triggeredHandler);
	addChild(inputText);
	
	sendButton = new CustomButton();
	sendButton.label = "برو";
	sendButton.width = sendButton.height = footerSize;
	sendButton.layoutData = new AnchorLayoutData(NaN, 0, 0, NaN);
	sendButton.addEventListener(Event.TRIGGERED, sendButton_triggeredHandler);
	addChild(sendButton);
	
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_publicMessageHandler);
}

protected function sendButton_triggeredHandler(event:Event):void
{
	if( inputText.text == "" )
		return;
	
	var params:SFSObject = new SFSObject();
	params.putUtfString("t", StrUtils.getSimpleString(inputText.text));
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_PUBLIC_MESSAGE, params, room );
	inputText.text = "";
}

override public function dispose():void
{
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_publicMessageHandler);
	super.dispose();
}

protected function sfsConnection_publicMessageHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.LOBBY_PUBLIC_MESSAGE )
		return;
	
	var msg:ISFSObject = event.params.params as SFSObject;
	var last:SFSObject = messageCollection.length > 0 ? SFSObject(messageCollection.getItemAt(messageCollection.length-1)) : null;
	
	if( last != null && last.getInt("i") == msg.getInt("i") )
	{
		last.putInt("u", msg.getInt("u"));
		last.putUtfString("t", msg.getUtfString("t"));
		messageCollection.updateItemAt(messageCollection.length-1);
	}
	else
	{
		messageCollection.addItem(msg);
	}
	setTimeout(chatList.scrollToPosition, 100, NaN, chatList.maxVerticalScrollPosition+100*appModel.scale, 0.2);
}

}
}