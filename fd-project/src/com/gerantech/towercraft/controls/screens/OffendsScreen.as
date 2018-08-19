package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.items.InfractionItemRenderer;
import com.gerantech.towercraft.controls.popups.BroadcastMessagePopup;
import com.gerantech.towercraft.controls.popups.ProfilePopup;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayoutData;
import starling.display.Quad;
import starling.events.Event;

public class OffendsScreen extends ListScreen
{
public var reporter:int = -1;
private var infractions:ListCollection;
public function OffendsScreen(){}
override protected function initialize():void
{
	title = "Infractions";
	super.initialize();
	
	infractions = new ListCollection();
	requestInfractions();
	
	var bgButton:SimpleLayoutButton = new SimpleLayoutButton();
	bgButton.alpha = 0;
	bgButton.backgroundSkin = new Quad(1, 1, 0xFF);
	bgButton.addEventListener(Event.TRIGGERED, bg_triggeredHandler);
	bgButton.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	
	listLayout.paddingRight = listLayout.paddingLeft = listLayout.gap = 2;	
	listLayout.hasVariableItemDimensions = true;
	list.itemRendererFactory = function():IListItemRenderer { return new InfractionItemRenderer(); }
	list.addEventListener(Event.SELECT, list_eventsHandler);
	list.addEventListener(Event.CANCEL, list_eventsHandler);
	list.addEventListener(Event.READY, list_eventsHandler);
	list.addEventListener(Event.OPEN, list_eventsHandler);
	list.backgroundSkin = bgButton;
	list.backgroundSkin.touchable = true;
	list.dataProvider = infractions;
}

public function requestInfractions() : void 
{
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_issuesResponseHandler);
	var params:SFSObject;
	if( reporter != -1 )
	{
		params = new SFSObject();
		params.putInt("id", reporter);
	}
	SFSConnection.instance.sendExtensionRequest(SFSCommands.INFRACTIONS_GET, params);
}

protected function sfs_issuesResponseHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.INFRACTIONS_GET )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_issuesResponseHandler);
	infractions.removeAll();
	var issueList:SFSArray = SFSArray(SFSObject(event.params.params).getSFSArray("data"));
	for (var i:int = 0; i < issueList.size(); i++)
	{
		var sfs:ISFSObject = issueList.getSFSObject(i);
		/*var msg:SFSObject = new SFSObject();
		msg.putInt("id", sfs.getInt("reporter"));
		msg.putShort("read", 0);
		msg.putShort("type", 41);
		msg.putUtfString("text", sfs.getUtfString("content"));
		msg.putUtfString("sender", sfs.getUtfString("name"));
		msg.putInt("senderId", sfs.getInt("offender"));
		msg.putLong("utc", sfs.getLong("offend_at"));*/
		infractions.addItem(issueList.getSFSObject(i));
	}
}
private function bg_triggeredHandler(event:Event):void
{
	list.selectedIndex = -1;
}

private function list_eventsHandler(event:Event):void
{
	var msg:SFSObject = event.data as SFSObject;
	if( event.type == Event.SELECT )
	{
	}
	else if( event.type == Event.CANCEL )
	{
		list.selectedIndex = -1;
	}
	else if( event.type == Event.READY )
	{
		appModel.navigator.addPopup(new ProfilePopup({name:msg.getText("name"), id:msg.getInt("offender")}));
	}
	else if( event.type == Event.OPEN )
	{
		appModel.navigator.addPopup(new ProfilePopup({id:msg.getInt("reporter")}, true));
	}
}
}
}