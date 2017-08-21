package com.gerantech.towercraft.managers.net
{

	import com.gerantech.extensions.NativeAbilities;
	import com.gerantech.towercraft.events.LoadingEvent;
	import com.gerantech.towercraft.managers.TimeManager;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.vo.UserData;
	import com.gerantech.towercraft.utils.StrUtils;
	import com.gerantech.towercraft.utils.Utils;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.Capabilities;
	import flash.utils.getTimer;
	
	[Event(name="loaded",				type="com.gerantech.towercraft.events.LoadingEvent")]
	[Event(name="loginError",			type="com.gerantech.towercraft.events.LoadingEvent")]
	[Event(name="noticeUpdate",			type="com.gerantech.towercraft.events.LoadingEvent")]
	[Event(name="forceUpdate",			type="com.gerantech.towercraft.events.LoadingEvent")]
	[Event(name="networkError",			type="com.gerantech.towercraft.events.LoadingEvent")]
	[Event(name="coreLoadingError",		type="com.gerantech.towercraft.events.LoadingEvent")]
	[Event(name="connectionLost",		type="com.gerantech.towercraft.events.LoadingEvent")]
	[Event(name="forceReload",			type="com.gerantech.towercraft.events.LoadingEvent")]
	
	public class LoadingManager extends EventDispatcher
	{
		public var state:int = -1;
		
		public static const STATE_DISCONNECTED:int = -1;
		public static const STATE_CONNECT:int = 0;
		public static const STATE_LOGIN:int = 1;
		public static const STATE_CORE_LOADING:int = 2;
		public static const STATE_LOADED:int = 3;
		public var inBattle:Boolean;
		public var loadStartAt:int;
		
		private var sfsConnection:SFSConnection;

		public var serverData:SFSObject;
		
		public function load():void
		{
			loadStartAt = getTimer();
			SFSConnection.dispose();
			sfsConnection = SFSConnection.instance;
			sfsConnection.addEventListener(SFSConnection.SUCCEED, sfsConnection_connectionHandler);
			sfsConnection.addEventListener(SFSConnection.FAILURE, sfsConnection_connectionHandler);
			state = STATE_CONNECT;
			if( AppModel.instance.navigator != null )
				AppModel.instance.navigator.popToRootScreen();
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

			var loginParams:ISFSObject;
			// new player
			if( UserData.getInstance().id < 0 )
			{
				loginParams = new SFSObject();
				if( UserData.getInstance().id == -1 )
				{
					loginParams.putText("udid", AppModel.instance.platform == AppModel.PLATFORM_ANDROID ? NativeAbilities.instance.deviceInfo.id : Utils.getPCUniqueCode());
					loginParams.putText("device", AppModel.instance.platform == AppModel.PLATFORM_ANDROID ? StrUtils.truncateText(NativeAbilities.instance.deviceInfo.manufacturer+"-"+NativeAbilities.instance.deviceInfo.model, 32, "") : Capabilities.manufacturer);
				}
			}
			sfsConnection.login(UserData.getInstance().id.toString(), UserData.getInstance().password, "", loginParams);
		}
		

		protected function sfsConnection_loginErrorHandler(event:SFSEvent):void
		{
			sfsConnection.removeEventListener(SFSEvent.LOGIN,		sfsConnection_loginHandler);
			sfsConnection.removeEventListener(SFSEvent.LOGIN_ERROR,	sfsConnection_loginErrorHandler);
			dispatchEvent(new LoadingEvent(LoadingEvent.LOGIN_ERROR, event.params["errorCode"]));
		}
		protected function sfsConnection_loginHandler(event:SFSEvent):void
		{
			sfsConnection.removeEventListener(SFSEvent.LOGIN,		sfsConnection_loginHandler);
			sfsConnection.removeEventListener(SFSEvent.LOGIN_ERROR, sfsConnection_loginErrorHandler);
			
			sfsConnection.addEventListener(SFSEvent.CONNECTION_LOST, sfsConnection_connectionLostHandler);
			serverData = event.params.data;
			
			if(serverData.containsKey("exists"))
			{
				dispatchEvent(new LoadingEvent(LoadingEvent.LOGIN_USER_EXISTS, serverData));
				return;
			}

			// in registring case
			if(serverData.containsKey("password"))
			{
				UserData.getInstance().id = serverData.getLong("id");
				UserData.getInstance().password = serverData.getText("password");
				UserData.getInstance().save();
			}
			
			if( TimeManager.instance != null )
				TimeManager.instance.dispose();
			new TimeManager(serverData.getLong("serverTime"));

			
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
			var coreLoader:CoreLoader = new CoreLoader(serverData.getText("coreVersion"), serverData);
			coreLoader.addEventListener(ErrorEvent.ERROR, coreLoader_errorHandler);
			coreLoader.addEventListener(Event.COMPLETE, coreLoader_completeHandler);
			state = STATE_CORE_LOADING;			
		}
		
		protected function sfsConnection_connectionLostHandler(event:SFSEvent):void
		{
			sfsConnection.logout();
			dispatchEvent(new LoadingEvent(LoadingEvent.CONNECTION_LOST));
		}
		
		protected function coreLoader_errorHandler(event:ErrorEvent):void
		{
			dispatchEvent(new LoadingEvent(LoadingEvent.CORE_LOADING_ERROR));
		}
		
		protected function coreLoader_completeHandler(event:Event):void
		{
			inBattle = serverData.getBool("inBattle");
			event.currentTarget.removeEventListener(Event.COMPLETE, coreLoader_completeHandler);
			//trace(AppModel.instance.descriptor.versionCode, Game.loginData.noticeVersion, Game.loginData.forceVersion)
			state = STATE_LOADED;
			dispatchEvent(new LoadingEvent(LoadingEvent.LOADED));
		}

	}
}