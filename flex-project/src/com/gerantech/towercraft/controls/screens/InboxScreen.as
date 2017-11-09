package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.items.InboxItemRenderer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.managers.InboxService;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gt.towers.constants.MessageTypes;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.controls.renderers.IListItemRenderer;
import feathers.layout.AnchorLayoutData;

import starling.display.Quad;
import starling.events.Event;

public class InboxScreen extends ListScreen
{
private var emptyLabel:RTLLabel;

override protected function initialize():void
{
	title = loc("inbox_page");
	super.initialize();
	
	var bgButton:SimpleLayoutButton = new SimpleLayoutButton();
	bgButton.alpha = 0;
	bgButton.backgroundSkin = new Quad(1,1,0xFF);
	bgButton.addEventListener(Event.TRIGGERED, bg_triggeredHandler);
	bgButton.layoutData = new AnchorLayoutData(0,0,0,0);
	
	listLayout.gap = 0;	
	listLayout.hasVariableItemDimensions = true;
	list.itemRendererFactory = function():IListItemRenderer { return new InboxItemRenderer(); }
	list.addEventListener(Event.OPEN, list_eventsHandler);
	list.addEventListener(Event.SELECT, list_eventsHandler);
	list.addEventListener(Event.CANCEL, list_eventsHandler);
	list.backgroundSkin = bgButton;
	list.backgroundSkin.touchable = true;
	showMessages();
}

private function bg_triggeredHandler(event:Event):void
{
	list.selectedIndex = -1;
}

private function showMessages():void
{
	if( InboxService.instance.messages == null || InboxService.instance.messages.length == 0 )
	{
		emptyLabel = new RTLLabel(loc("inbox_empty_label"));
		emptyLabel.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
		addChild(emptyLabel);
		return;
	}
	if( emptyLabel != null )
		emptyLabel.removeFromParent();
	list.dataProvider = InboxService.instance.messages;
}

private function list_eventsHandler(event:Event):void
{
	var message:SFSObject = event.data as SFSObject;
	if( event.type == Event.OPEN )
	{
		SFSConnection.instance.sendExtensionRequest(SFSCommands.INBOX_OPEN, message);
		return;
	}
	if( event.type == Event.SELECT )
	{
		if( message.getShort("type") == MessageTypes.M50_URL )
			appModel.navigator.handleURL(message.getText("data"));
	}
	if( MessageTypes.isConfirm(message.getShort("type")) )
	{
		message.putBool("isAccept", event.type == Event.SELECT);
		SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseConfirmHandler);
		SFSConnection.instance.sendExtensionRequest(SFSCommands.INBOX_CONFIRM, message);
	}
}

protected function sfs_responseConfirmHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.INBOX_CONFIRM )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseConfirmHandler);
}
}
}