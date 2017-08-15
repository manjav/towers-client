package com.gerantech.towercraft.models.vo
{
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;

import flash.net.SharedObject;

public class UserData
{
    public var id:int = -1;
	public var password:String = "";
    public var authenticated:Boolean = false;
    public var buildingsOpened:Boolean;
    public var rated:Boolean;
    public var authenticationAttemps:int;

    private static var _instance:UserData;

		public function UserData() 
		{
		}
		
		public function load():void
		{
			var so:SharedObject = SharedObject.getLocal(SFSConnection.instance.currentIp + "-user-data");
			if(so.data.id == null)
				return;
			id = so.data.id;
			password = so.data.password;
			authenticated = so.data.authenticated;
			buildingsOpened = so.data.buildingsOpened;
			authenticationAttemps = so.data.authenticationAttemps;
			rated = so.data.rated;
		}
		public function save():void
		{
			var so:SharedObject = SharedObject.getLocal(SFSConnection.instance.currentIp + "-user-data");
			so.data.id = id;
			so.data.password = password;
			so.data.authenticated = authenticated;
			so.data.buildingsOpened = buildingsOpened;
			so.data.authenticationAttemps = authenticationAttemps;
			so.data.rated = rated;
			
			so.flush(100000);
		}
		public function clear():void
		{
			var so:SharedObject = SharedObject.getLocal(SFSConnection.instance.currentIp + "user-data");
			so.clear();
		}

		public function get registered():Boolean
		{
			return id != 0;
		}

		public static function getInstance():UserData {
			if(!_instance)
				_instance = new UserData();
			return _instance;
		}
	}
}