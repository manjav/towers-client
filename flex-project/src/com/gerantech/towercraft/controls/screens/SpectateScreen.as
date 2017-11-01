package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.items.BattleItemRenderer;
import com.gerantech.towercraft.controls.overlays.WaitingOverlay;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gt.towers.battle.fieldes.FieldData;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.Room;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;
import com.smartfoxserver.v2.entities.variables.SFSRoomVariable;
import com.smartfoxserver.v2.requests.LeaveRoomRequest;

import feathers.controls.StackScreenNavigatorItem;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;

import starling.events.Event;

public class SpectateScreen extends ListScreen
{
public var cmd:String;
private var sfsConnection:SFSConnection;

private var rooms:ListCollection = new ListCollection();

override protected function initialize():void
{
	var sfsObj:SFSObject = new SFSObject();
	sfsObj.putText("t", cmd);
	
	sfsConnection = SFSConnection.instance;
	sfsConnection.addEventListener(SFSEvent.CONNECTION_LOST,	sfs_connectionLostHandler);
	sfsConnection.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseUpdateHandler);
	sfsConnection.addEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, sfs_roomVariablesUpdateHandler);
	sfsConnection.sendExtensionRequest("spectateBattles", sfsObj);
	

	title = "All "+ cmd.substr(0,1).toUpperCase() + cmd.substr(1);
	super.initialize();
	listLayout.gap = 0;	
	list.itemRendererFactory = function():IListItemRenderer { return new BattleItemRenderer(); }
	list.dataProvider = rooms;
}

protected function sfs_responseUpdateHandler(event:SFSEvent):void
{
	if( event.params.cmd != "spectateBattles" )
		return;
	updateRooms(SFSRoomVariable(sfsConnection.getRoomByName(cmd).getVariable("rooms")).getSFSArrayValue());
}
override protected function list_changeHandler(event:Event):void
{
	super.list_changeHandler(event);

	var item:StackScreenNavigatorItem = appModel.navigator.getScreen( Main.BATTLE_SCREEN );
	item.properties.requestField = new FieldData(100000 + SFSObject(list.selectedItem).getInt("id"), "quest_100000") ;
	item.properties.spectatedUser = "Admin";
	item.properties.waitingOverlay = new WaitingOverlay() ;
	appModel.navigator.pushScreen( Main.BATTLE_SCREEN ) ;
	appModel.navigator.addOverlay(item.properties.waitingOverlay);
}

protected function sfs_roomVariablesUpdateHandler(event:SFSEvent):void
{
	if( cmd != event.params.room.name || event.params.changedVars.indexOf("rooms") == -1 )
		return;
	updateRooms(SFSRoomVariable(event.params.room.getVariable("rooms")).getSFSArrayValue());
}

private function updateRooms(_rooms:ISFSArray):void
{
	trace("roooooooooooooom");
	var rs:Array = new Array();
	for (var i:int = 0; i < _rooms.size(); i++) 
		rs.push(_rooms.getSFSObject(i));
	rooms.data = rs;
}

protected function sfs_connectionLostHandler(event:SFSEvent):void
{
	removeConnectionListeners();
}
protected function removeConnectionListeners():void
{
	sfsConnection.removeEventListener(SFSEvent.CONNECTION_LOST,	sfs_connectionLostHandler);
	sfsConnection.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseUpdateHandler);
	sfsConnection.removeEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, sfs_roomVariablesUpdateHandler);
}
override protected function backButtonFunction():void
{
	dispatchEventWith(Event.COMPLETE);
}
override public function dispose():void
{
	var r:Room = sfsConnection.getRoomByName(cmd)
	sfsConnection.send(new LeaveRoomRequest(sfsConnection.getRoomByName(cmd)));
	removeConnectionListeners();
	super.dispose();
}
}
}