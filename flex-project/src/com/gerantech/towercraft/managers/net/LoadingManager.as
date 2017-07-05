package com.gerantech.towercraft.managers.net
{

	import com.gerantech.towercraft.events.LoadingEvent;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.vo.UserData;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.desktop.NativeApplication;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	[Event(name="loaded",				type="com.gerantech.towercraft.events.LoadingEvent")]
	[Event(name="loginError",			type="com.gerantech.towercraft.events.LoadingEvent")]
	[Event(name="noticeUpdate",			type="com.gerantech.towercraft.events.LoadingEvent")]
	[Event(name="forceUpdate",			type="com.gerantech.towercraft.events.LoadingEvent")]
	public class LoadingManager extends EventDispatcher
	{
		public var state:int = -1;
		
		public static const STATE_DISCONNECTED:int = -1;
		public static const STATE_CONNECT:int = 0;
		public static const STATE_LOGIN:int = 1;
		public static const STATE_CORE_LOADING:int = 2;
		public static const STATE_LOADED:int = 3;
		
		private var sfsConnection:SFSConnection;

		private var serverData:SFSObject;
		public var inBattle:Boolean;
		
		public function LoadingManager()
		{
			sfsConnection = SFSConnection.instance;
			sfsConnection.addEventListener(SFSConnection.SUCCEED, sfsConnection_connectionHandler);
			sfsConnection.addEventListener(SFSConnection.FAILURE, sfsConnection_connectionHandler);
			state = STATE_CONNECT;
		}
		
		protected function sfsConnection_connectionHandler(event:SFSEvent):void
		{
			sfsConnection.removeEventListener(SFSConnection.FAILURE, sfsConnection_connectionHandler);
			sfsConnection.removeEventListener(SFSConnection.SUCCEED, sfsConnection_connectionHandler);
			if(event.type == SFSConnection.SUCCEED)
			{				
				login();
			}
			else
			{
				dispatchEvent(new LoadingEvent(LoadingEvent.NETWORK_ERROR));
				state = STATE_DISCONNECTED;
			}
		}
		
		/**************************************   LOGIN   ****************************************/
		private function login():void 
		{
			state = STATE_LOGIN;
			UserData.getInstance().load();
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
			
			sfsConnection.addEventListener(SFSEvent.CONNECTION_LOST, sfsConnection_connectionLostHandler);
			serverData = event.params.data;
			
			// in registring case
			if(serverData.containsKey("password"))
			{
				if(serverData.containsKey("id"))
					UserData.getInstance().id = serverData.getLong("id");
				
				UserData.getInstance().password = serverData.getText("password");
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
			
			//trace(AppModel.instance.descriptor.versionCode , serverData.getInt("noticeVersion"), serverData.getInt("forceVersion"))
			if( AppModel.instance.descriptor.versionCode < serverData.getInt("forceVersion") )
				dispatchEvent(new LoadingEvent(LoadingEvent.FORCE_UPDATE));
			else if( AppModel.instance.descriptor.versionCode < serverData.getInt("noticeVersion") )
				dispatchEvent(new LoadingEvent(LoadingEvent.NOTICE_UPDATE));
			else
				loadCore();
		}
		
		public function loadCore():void
		{
			var coreLoader:CoreLoader = new CoreLoader(serverData.getText("coreVersion"), serverData);//  "http://51.254.79.215/home/arman/SmartFoxServer_2X/SFS2X/extensions/MyZoneExts/core.swf")
			coreLoader.addEventListener(ErrorEvent.ERROR, coreLoader_errorHandler);
			coreLoader.addEventListener(Event.COMPLETE, coreLoader_completeHandler);
			state = STATE_CORE_LOADING;			
		}
		
		protected function sfsConnection_connectionLostHandler(event:SFSEvent):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		protected function coreLoader_errorHandler(event:ErrorEvent):void
		{
			dispatchEvent(new LoadingEvent(LoadingEvent.CORE_LOADING_ERROR));
		}
		
		protected function coreLoader_completeHandler(event:Event):void
		{
			inBattle = serverData.getBool("inBattle");trace("inBattle", inBattle)
			event.currentTarget.removeEventListener(Event.COMPLETE, coreLoader_completeHandler);
			//trace(AppModel.instance.descriptor.versionCode, Game.loginData.noticeVersion, Game.loginData.forceVersion)
				dispatchEvent(new LoadingEvent(LoadingEvent.LOADED));
				state = STATE_LOADED;
		}


	}
}