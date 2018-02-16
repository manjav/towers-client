package com.gerantech.towercraft.controls.segments.lobby
{
import com.gerantech.towercraft.controls.segments.Segment;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.layout.AnchorLayout;

public class LobbyChatItemSegment extends Segment
{
public var padding:int;
public var otherPadding:int;
public var data:ISFSObject;

protected var itsMe:Boolean;

override public function init():void
{
	super.init();
	layout = new AnchorLayout();
	padding = 48 * appModel.scale;
	otherPadding = 120 * appModel.scale;
}

public function commitData(_data:ISFSObject):void
{
	this.data = _data as SFSObject;
	itsMe = data.getInt("i") == player.id;
	if( !initializeStarted )
		init();
}
	
protected function findUser(uid:int):ISFSObject
{
	var all:ISFSArray = SFSConnection.instance.lobbyManager.members;//lobby.getSFSArray("all");
	if( all == null )
		return null;
	var allSize:int = all.size();
	for( var i:int=0; i<allSize; i++ )
	{
		if( all.getSFSObject(i).getInt("id") == uid )
			return all.getSFSObject(i);
	}
	return null;
}		
}
}