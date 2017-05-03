package com.gerantech.towercraft.models.vo
{
import flash.net.SharedObject;

public class UserData
{
    public var id:int = -1;
	public var password:String = "";
	//public var userName:String = "";
	//public var email:String;
	//public var numRuns:int;
	//public var nickName:String = "Guest";

    private static var _instance:UserData;

		public function UserData() 
		{
		}
		
		public function load():void
		{
			var so:SharedObject = SharedObject.getLocal("user-data");
			if(so.data.id == null)
				return;
			id = so.data.id;
			password = so.data.password;
		}
		public function save():void
		{
			var so:SharedObject = SharedObject.getLocal("user-data");
			so.data.id = id;
			so.data.password = password;
			so.flush(100000);
		}
		public function clear():void
		{
			var so:SharedObject = SharedObject.getLocal("user-data");
			so.clear();
		}

		public function get registered():Boolean
		{
			return id != 0;
		}

	/*	private function checkLevelUp():void {
			var weap:int = Vals.getLevelNumber(_xp) + 2;
			trace("checkLevelUp() :::", weap);
			for(var i:int = 3; i <= weap; i++) {
				if(!alreadyHadsWeapon(weap)) {
					trace("new weapon unlocked :::", i);
					UserData.getInstance().unlockWeapon(i, Vals.UNLOCKED_WEAPON_INITIAL_COUNT);
				}
			}
		}*/

		/*private function alreadyHadsWeapon(weap:int):Boolean {
			return _ownedWeapons.hasOwnProperty(weap);
		}

		public function changeNickName(nName:String):void {
			var obj:SFSObject = new SFSObject();
			obj.putUtfString(Commands.SFSOBJ_DATA_KEY_2, nName);
			MySmartFox.getInstance().sendToServer(Commands.ORDER_UPDATE_NICK, obj);
			_nickName = nName;
		}
*/
		/**
		 * register this weapon for current user in the database
		 * initialCount: number of weapon bullets user will have after unlocking
		 
		public function unlockWeapon(weaponCode:int, initialCount:int):void {
			var obj:SFSObject = new SFSObject();
			obj.putInt(Commands.SFSOBJ_DATA_KEY_2, _idInDatabase);
			obj.putInt(Commands.SFSOBJ_DATA_KEY_3, initialCount);
			obj.putInt(Commands.SFSOBJ_DATA_KEY_4, weaponCode);
			MySmartFox.getInstance().sendToServer(Commands.ORDER_UNLUCK_WEAPON, obj);

			ownedWeapons[weaponCode] = initialCount;
		}*/

		/**
		 * when you do not want to send updated data to the server
		 
		public function updateFromServer(obj:SFSObject):void 
		{
			//set owned weapons:
			var sfsArr:ISFSArray = obj.getSFSArray(Commands.SFSOBJ_DATA_KEY_6)
			var sfsObj:SFSObject;
			var weaponCode:int;
			var weaponCount:int;
			var i:int = 0;
			trace("sfsArr", sfsArr.getDump());
			while(!sfsArr.isNull(i)) {
				sfsObj = sfsArr.getSFSObject(i) as SFSObject;
				weaponCode = sfsObj.getInt(Commands.DATABASE_WEAPON_CODE);
				weaponCount = sfsObj.getInt(Commands.DATABASE_WEAPON_COUNT);
				//_ownedWeapons[weaponCode] = weaponCount;
				trace("weaponCode: ", weaponCode, "weaponCount", weaponCount);
				++i;
			}
			
			//-------------------set the core:
			/*
			
			//testing:
			//Vals.WAITE_BEFORE_START_BOT = 1;
		}*/

		public function loadSavedData(uName:String, pass:String, email:String, firstPlay:String):void {
			/*_userName = uName;
			_password = pass;
			_email = email;
			if(firstPlay == "0")
				isFirsedTimePlayed = 0;
			else
				isFirsedTimePlayed = 1;*/
		}

		

//		public static function get hasEnoughBullets():Boolean {
//			var has:Boolean;
//			var validNum:int;
//			for(var i:int = 0; i < Weapon.NUMBER_OF_WEAPONS; i++) {
//				if(UserData.getInstance().ownedWeapons[i] > Weapon.getMagazineCapacity(i)) {
//					validNum += Weapon.getMagazineCapacity(i);
//				} else if(UserData.getInstance().ownedWeapons[i] != undefined) {
//					validNum += UserData.getInstance().ownedWeapons[i];
//				}
//				if(validNum >= Vals.TOTAL_TURNS / 2) {
//					has = true;
//					break;
//				}
//			}
//
//			trace("hasEnoughBullets :::", validNum);
//			return has;
//		}
		
		public static function getInstance():UserData {
			if(!_instance)
				_instance = new UserData();
			return _instance;
		}

	}
}
