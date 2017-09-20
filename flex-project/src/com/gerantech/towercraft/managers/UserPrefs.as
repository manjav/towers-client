package com.gerantech.towercraft.managers
{
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.AppModel;
	import com.gt.towers.Player;
	import com.gt.towers.constants.PrefsTypes;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.ISFSArray;
	import com.smartfoxserver.v2.entities.data.SFSObject;

	public class UserPrefs
	{
		public function UserPrefs()
		{
		}
		
		public function requestData():void
		{
			SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_getAllPrefsHandler);
			SFSConnection.instance.sendExtensionRequest(SFSCommands.PREFS);	
		}
		
		protected function sfs_getAllPrefsHandler(event:SFSEvent):void
		{
			if( event.params.cmd != SFSCommands.PREFS )
				return;
			
			SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_getAllPrefsHandler);
			var map:ISFSArray = SFSObject(event.params.params).getSFSArray("map");
			var player:Player = AppModel.instance.game.player;
			for ( var i:int=0; i<map.size(); i++ )
				player.prefs.set(int(map.getSFSObject(i).getText("k")), map.getSFSObject(i).getText("v"));
			
			if( player.prefs.getAsInt(PrefsTypes.P30_OFFER_RATING) == 0 )
				player.prefs.set(PrefsTypes.P30_OFFER_RATING , "20");
			if( player.prefs.getAsInt(PrefsTypes.P31_OFFER_TELEGRAM) == 0 )
				player.prefs.set(PrefsTypes.P31_OFFER_TELEGRAM , "30");
			if( player.prefs.getAsInt(PrefsTypes.P32_OFFER_INSTAGRAM) == 0 )
				player.prefs.set(PrefsTypes.P32_OFFER_INSTAGRAM , "40");
			if( player.prefs.getAsInt(PrefsTypes.P33_OFFER_FRIENDSHIP) == 0 )
				player.prefs.set(PrefsTypes.P33_OFFER_FRIENDSHIP , "50");
		}
		
		public function send(key:int, value:int):void
		{
			AppModel.instance.game.player.prefs.set(key, value.toString());
			var params:SFSObject = new SFSObject();
			params.putInt("k", key);
			params.putText("v", value.toString());
			SFSConnection.instance.sendExtensionRequest(SFSCommands.PREFS, params);	
		}
	}
}