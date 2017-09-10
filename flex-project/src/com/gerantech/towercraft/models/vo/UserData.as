package com.gerantech.towercraft.models.vo
{
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gt.towers.utils.maps.IntIntMap;

import flash.net.SharedObject;

public class UserData
{
    public var id:int = -1;
	public var password:String = "";
    public var authenticated:Boolean = false;
    public var buildingsOpened:Boolean;
    public var rated:Boolean;
    public var authenticationAttemps:int;
    public var oneSignalUserId:String;
    public var oneSignalPushToken:String;
	private var settingsMap:IntIntMap;

    private static var _instance:UserData;

		public function UserData() 
		{
			settingsMap = new IntIntMap();
			settingsMap.set(SettingsData.MUSIC, 1);
			settingsMap.set(SettingsData.SFX, 1);
			settingsMap.set(SettingsData.NOTIFICATION, 1);
			settingsMap.set(SettingsData.LOCALE, 0);
		}
		
		public function load():void
		{
			var so:SharedObject = SharedObject.getLocal(SFSConnection.instance.currentIp + "-user-data");
			if(so.data.id == null)
				return;
			id = so.data.id;
			password = so.data.password;
			authenticated = so.data.authenticated;

			if( so.data.setting )
				for(var key:String in so.data.setting )
					settingsMap.set(int(key), int(so.data.setting[key]));

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
			
			if( so.data.setting == null )
				so.data.setting = new Object();
			var settingsKeys:Vector.<int> = settingsMap.keys();
			for each (var key:int in settingsKeys)
				so.data.setting[key] = settingsMap.get(key);
			
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

		public static function get instance():UserData {
			if(!_instance)
				_instance = new UserData();
			return _instance;
		}
		
		public function setSetting(key:int, value:int):void
		{
			if( !settingsMap.exists( key ) )
				return;
			settingsMap.set( key, value );
			save();
		}
		public function getSetting(key:int):int
		{
			return settingsMap.get( key );
		}		
	}
}