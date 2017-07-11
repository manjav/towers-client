package com.gerantech.towercraft.models.vo
{
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;

import flash.net.SharedObject;

public class UserData
{
    public var id:int = -1;
	public var password:String = "";
   // public var tuorStep:String = "quests";

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
			//tuorStep = so.data.tuorStep;
		}
		public function save():void
		{
			var so:SharedObject = SharedObject.getLocal(SFSConnection.instance.currentIp + "-user-data");
			so.data.id = id;
			so.data.password = password;
			//so.data.tuorStep = tuorStep;
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