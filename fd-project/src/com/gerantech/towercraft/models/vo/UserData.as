package com.gerantech.towercraft.models.vo
{
import com.gerantech.towercraft.managers.UserPrefs;
import com.gerantech.towercraft.models.AppModel;
import flash.net.SharedObject;

public class UserData
{
public var id:int = -1;
public var prefs:UserPrefs;
public var password:String = "";
public var lastLobbeyMessageTime:int;
public var broadcasts:Vector.<int>;
//public var oneSignalUserId:String;
//public var oneSignalPushToken:String;
public function UserData() {}
private static var _instance:UserData;
public static function get instance():UserData 
{
	if( _instance == null )
		_instance = new UserData();
	return _instance;
}
public function load():void
{
	var so:SharedObject = SharedObject.getLocal(AppModel.instance.descriptor.server + "-user-data");
	if( so.data.id == null )
		return;
	this.lastLobbeyMessageTime = so.data.lastLobbeyMessageTime;
	this.broadcasts = so.data.broadcasts;
	this.id = so.data.id;
	this.password = so.data.password;
}
public function save():void
{
	var so:SharedObject = SharedObject.getLocal(AppModel.instance.descriptor.server + "-user-data");
	so.data.id = this.id;
	so.data.password = this.password;
	so.data.broadcasts = this.broadcasts;
	so.data.lastLobbeyMessageTime = this.lastLobbeyMessageTime;
	so.flush(100000);
}
public function clear():void
{
	var so:SharedObject = SharedObject.getLocal(AppModel.instance.descriptor.server + "user-data");
	so.clear();
}

public function addOpenedBroadcasts(messageTime:int) : void 
{
	if( this.broadcasts == null )
		this.broadcasts = new Vector.<int>();
	this.broadcasts.push(messageTime);
	save();
}

public function get registered():Boolean
{
	return id != 0;
}
}
}