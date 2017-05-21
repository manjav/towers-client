package com.gerantech.towercraft.managers.net
{

	import com.gerantech.towercraft.events.LoadingEvent;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.vo.UserData;
	import com.gt.towers.Game;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	[Event(name="loaded",				type="com.gerantech.towercraft.events.LoadingEvent")]
	[Event(name="loginError",			type="com.gerantech.towercraft.events.LoadingEvent")]
	[Event(name="noticeUpdate",			type="com.gerantech.towercraft.events.LoadingEvent")]
	[Event(name="forceUpdate",			type="com.gerantech.towercraft.events.LoadingEvent")]
	public class LoadingManager extends EventDispatcher
	{
		private var sfsConnection:SFSConnection;
		
		public function LoadingManager()
		{
			sfsConnection = SFSConnection.getInstance();
			sfsConnection.addEventListener(SFSConnection.SUCCEED, sfsConnection_connectionHandler);
			sfsConnection.addEventListener(SFSConnection.FAILURE, sfsConnection_connectionHandler);
			
			UserData.getInstance().load();
		}
		
		protected function sfsConnection_connectionHandler(event:SFSEvent):void
		{
			sfsConnection.removeEventListener(SFSConnection.FAILURE, sfsConnection_connectionHandler);
			sfsConnection.removeEventListener(SFSConnection.SUCCEED, sfsConnection_connectionHandler);
			if(event.type == SFSConnection.SUCCEED)
				login();
			else
				dispatchEvent(new LoadingEvent(LoadingEvent.NETWORK_ERROR));
		}
		
		/**************************************   LOGIN   ****************************************/
		private function login():void 
		{
			sfsConnection.addEventListener(SFSEvent.LOGIN,			sfsConnection_loginHandler);
			sfsConnection.addEventListener(SFSEvent.LOGIN_ERROR,	sfsConnection_loginErrorHandler);
			sfsConnection.login(UserData.getInstance().id.toString(), UserData.getInstance().password, "");
		}
		protected function sfsConnection_loginErrorHandler(event:SFSEvent):void
		{
			sfsConnection.removeEventListener(SFSEvent.LOGIN,		sfsConnection_loginHandler);
			sfsConnection.removeEventListener(SFSEvent.LOGIN_ERROR,	sfsConnection_loginErrorHandler);
		}
		protected function sfsConnection_loginHandler(event:SFSEvent):void
		{
			sfsConnection.removeEventListener(SFSEvent.LOGIN,		sfsConnection_loginHandler);
			sfsConnection.removeEventListener(SFSEvent.LOGIN_ERROR, sfsConnection_loginErrorHandler);
			
			var data:SFSObject = event.params.data;
			
			// in registring case
			if(data.containsKey("password"))
			{
				if(data.containsKey("id"))
					UserData.getInstance().id = data.getLong("id");
				
				UserData.getInstance().password = data.getText("password");
				UserData.getInstance().save();
			}
			
			/* ------------ PURCHASE VERIFICATION EXAMPLE -----------
			sfsConnection.addEventListener(SFSEvent.EXTENSION_RESPONSE, adfs);
			var param:SFSObject = new SFSObject();
			param.putText("productID", "coin_pack_03");
			param.putText("purchaseToken", "SDu10PZdud5JoToeZa");
			sfsConnection.sendExtensionRequest("verify", param);
			function adfs(event:SFSEvent):void {
				trace(event.params);
			}*/		
			
			// Load << Game-Core >>
			var coreLoader:CoreLoader = new CoreLoader("0.1.1.1002", data);//  "http://51.254.79.215/home/arman/SmartFoxServer_2X/SFS2X/extensions/MyZoneExts/core.swf")
			coreLoader.addEventListener(Event.COMPLETE, coreLoader_completeHandler);
		}
		
		protected function coreLoader_completeHandler(event:Event):void
		{
			event.currentTarget.removeEventListener(Event.COMPLETE, coreLoader_completeHandler);
			//trace(AppModel.instance.descriptor.versionCode, Game.get_instance().noticeVersion, Game.get_instance().forceVersion)
			if(AppModel.instance.descriptor.versionCode < Game.get_instance().noticeVersion)
				dispatchEvent(new LoadingEvent(LoadingEvent.NOTICE_UPDATE));
			else if(AppModel.instance.descriptor.versionCode < Game.get_instance().forceVersion)
				dispatchEvent(new LoadingEvent(LoadingEvent.FORCE_UPDATE));
			else
				dispatchEvent(new LoadingEvent(LoadingEvent.LOADED));
		}

	}
}