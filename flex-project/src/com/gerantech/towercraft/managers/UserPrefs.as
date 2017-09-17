package com.gerantech.towercraft.managers
{
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.smartfoxserver.v2.core.SFSEvent;

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
			trace(event.params.params.getDump())
		}
	}
}