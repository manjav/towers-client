package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.items.InboxItemRenderer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gt.towers.constants.MessageTypes;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;

import flash.net.URLRequest;
import flash.net.navigateToURL;

import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayoutData;

import starling.events.Event;

public class InboxScreen extends ListScreen
{
private static var messages:ListCollection;
public function InboxScreen()
{
	super();
	if( messages == null )
	{
		SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseHandler);
		SFSConnection.instance.sendExtensionRequest(SFSCommands.INBOX_GET);
	}
}

protected function sfs_responseHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.INBOX_GET )
		return;//trace(event.params.params.getDump())
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseHandler);
	messages = new ListCollection( SFSArray(SFSObject(event.params.params).getSFSArray("data")).toArray() );
	if( list != null )
		showMessages();
}

override protected function initialize():void
{
	title = loc("inbox_page");
	super.initialize();
	
	listLayout.gap = 0;	
	listLayout.hasVariableItemDimensions = true;
	list.itemRendererFactory = function():IListItemRenderer { return new InboxItemRenderer(); }
	list.addEventListener(Event.OPEN, list_eventsHandler);
	list.addEventListener(Event.SELECT, list_eventsHandler);
	list.addEventListener(Event.CANCEL, list_eventsHandler);
	showMessages();
}

private function showMessages():void
{
	if( messages == null || messages.length == 0 )
	{
		var emptyLabel:RTLLabel = new RTLLabel(loc("inbox_empty_label"));
		emptyLabel.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
		addChild(emptyLabel);
		return;
	}	
	list.dataProvider = messages;
}

private function list_eventsHandler(event:Event):void
{
	var message:Object = event.data;
	if( event.type == Event.OPEN )
	{
		var params:SFSObject = new SFSObject();
		params.putInt("id", message.id);
		SFSConnection.instance.sendExtensionRequest(SFSCommands.INBOX_OPEN, params);
		return;
	}
	if( event.type == Event.SELECT )
	{
		if( message.type == MessageTypes.M50_URL )
			navigateToURL(new URLRequest(message.data));
	}
	if( message.type == MessageTypes.M40_CONFIRM )
	{
		params = new SFSObject();
		params.putInt("id", message.id);
		params.putText("data", message.data);
		params.putBool("isAccept", event.type == Event.SELECT);
		SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseConfirmHandler);
		SFSConnection.instance.sendExtensionRequest(SFSCommands.INBOX_CONFIRM, params);
	}
}

protected function sfs_responseConfirmHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.INBOX_CONFIRM )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseConfirmHandler);
}

public static function get numUnreads():int
{
	if( messages == null )
		return 0;
	var ret:int = 0;
	for (var i:int = 0; i < messages.length; i++)
		if( !messages.getItemAt(i).read )
			ret ++;
	return ret;
}
}
}