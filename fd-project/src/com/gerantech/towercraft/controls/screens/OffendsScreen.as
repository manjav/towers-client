package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.items.InfractionItemRenderer;
import com.gerantech.towercraft.controls.popups.AdminBanPopup;
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
	
	listLayout.paddingRight = listLayout.paddingLeft = listLayout.gap = 2;	
	listLayout.hasVariableItemDimensions = true;
	list.itemRendererFactory = function():IListItemRenderer { return new InfractionItemRenderer(); }
	list.addEventListener(Event.SELECT, list_eventsHandler);
	list.addEventListener(Event.CANCEL, list_eventsHandler);
	list.addEventListener(Event.READY, list_eventsHandler);
	list.addEventListener(Event.OPEN, list_eventsHandler);
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
	var issueList:SFSArray = SFSArray(SFSObject(event.params.params).getSFSArray("data"));
	var infractionArray:Array = new Array();
	for (var i:int = 0; i < issueList.size(); i++)
		infractionArray.push(issueList.getSFSObject(i));
	infractionArray.sort(function(a:ISFSObject, b:ISFSObject) : int 
	{
		//if( a.getInt("offender") > b.getInt("offender") ) return -1;
		//if( a.getInt("offender") < b.getInt("offender") ) return 1;
		if( a.getLong("offend_at") > b.getLong("offend_at") ) return -1;
		if( a.getLong("offend_at") < b.getLong("offend_at") ) return 1;
		return 0;
	});
	updateAll(infractionArray);
}

private function updateAll(infractionArray:Array):void 
{
	var missed:Boolean;
	for (var i:int = 0; i < infractionArray.length; i++)
	{
		missed = true;
		for (var j:int = 0; j < infractions.length; j++)
		{
			if( infractions.getItemAt(j).getInt("id") == infractionArray[i].getInt("id") && infractions.getItemAt(j).getInt("proceed") != infractionArray[i].getInt("proceed") )
			{
				infractions.getItemAt(j).putInt( "proceed", infractionArray[i].getInt("proceed") );
				infractions.updateItemAt(j);
				missed = false;
				break;
			}
		}
		if( missed )
			infractions.addItem(infractionArray[i]);
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
		ban(msg);
	else if( event.type == Event.CANCEL )
		deleteItem(msg);
	else if( event.type == Event.READY )
		appModel.navigator.addPopup(new ProfilePopup({name:msg.getText("name"), id:msg.getInt("offender")}));
	else if( event.type == Event.OPEN )
		appModel.navigator.addPopup(new ProfilePopup({id:msg.getInt("reporter")}, true));
}

private function ban(msg:ISFSObject):void 
{
	var banPopup:AdminBanPopup = new AdminBanPopup(msg.getInt("offender"));
	banPopup.addEventListener(Event.UPDATE, banPopup_updateHandler);
	appModel.navigator.addPopup(banPopup);
	function banPopup_updateHandler(e:Event) : void
	{
		requestInfractions();
	}
}

private function deleteItem(msg:SFSObject):void 
{
	var params:SFSObject = new SFSObject();
	params.putInt("id", msg.getInt("id"));
	SFSConnection.instance.sendExtensionRequest(SFSCommands.INFRACTIONS_DELETE, params);
	
	infractions.removeItem(msg);
}
}
}