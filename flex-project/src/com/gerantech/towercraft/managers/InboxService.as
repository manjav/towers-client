package com.gerantech.towercraft.managers
{
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.data.ListCollection;

import starling.events.Event;

public class InboxService extends BaseManager
{
private static var _instance:InboxService;
public var messages:ListCollection;

public function request():void
{
	if( messages != null )
		return;
	messages = new ListCollection();
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.INBOX_GET);
}

protected function sfs_responseHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.INBOX_GET )
		return;
	var msgs:SFSArray = SFSArray(SFSObject(event.params.params).getSFSArray("data"));
	var exists:Boolean = false;
	for (var i:int = 0; i < msgs.size(); i++) 
	{
		for (var j:int = 0; j < messages.length; j++) 
			if( !exists && msgs.getSFSObject(i).getInt("id") == messages.getItemAt(j).getInt("id") )
				exists = true;
		if( !exists )
			messages.addItem(msgs.getSFSObject(i));
	}
	//trace(event.params.params.getDump())
	dispatchEventWith(Event.UPDATE);
}

public function get numUnreads():int
{
	if( messages == null )
		return 0;
	var ret:int = 0;
	for (var i:int = 0; i < messages.length; i++)
		if( messages.getItemAt(i).getShort("read") == 0 )
			ret ++;
	return ret;
}

public static function get instance ():InboxService 
{
	if( _instance == null )
		_instance = new InboxService();
	return _instance;
}
}
}