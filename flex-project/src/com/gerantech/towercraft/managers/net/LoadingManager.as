package com.gerantech.towercraft.managers.net
{

	import com.gerantech.extensions.NativeAbilities;
	import com.gerantech.towercraft.controls.popups.ConfirmPopup;
	import com.gerantech.towercraft.events.LoadingEvent;
	import com.gerantech.towercraft.managers.TimeManager;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.managers.socials.SocialEvent;
	import com.gerantech.towercraft.managers.socials.SocialManager;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.vo.UserData;
	import com.janumedia.ane.deviceinfo.DeviceInfo;
	import com.janumedia.ane.deviceinfo.DeviceInfoExtension;
	import com.marpies.ane.onesignal.OneSignal;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.Capabilities;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import mx.resources.ResourceManager;
	
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
		public static const STATE_SOCIAL_SIGNIN:int = 5;
		public static const STATE_SEND_SOCIAL_DATA:int = 6;
		public static const STATE_LOADED:int = 10;
		public var inBattle:Boolean;
		public var loadStartAt:int;
		
		private var sfsConnection:SFSConnection;
		private var serverData:SFSObject;
		private var socials:SocialManager;
		
		public function load():void
		{
			loadStartAt = getTimer();
			SFSConnection.dispose();
			sfsConnection = SFSConnection.instance;
			sfsConnection.addEventListener(SFSConnection.SUCCEED, sfsConnection_connectionHandler);
			sfsConnection.addEventListener(SFSConnection.FAILURE, sfsConnection_connectionHandler);
			state = STATE_CONNECT;
			
			socials = new SocialManager();
			socials.init( SocialManager.TYPE_GOOGLEPLAY );
			
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
			
			OneSignal.settings.setAutoRegister( false ).setEnableInAppAlerts( false ).setShowLogs( true )
			if( OneSignal.init( "83cdb330-900e-4494-82a8-068b5a358c18" ) ) {
				//NativeAbilities.instance.showToast("OneSignal.init", 2);
			}
			/*OneSignal.addNotificationReceivedCallback( onNotificationReceived );
			function onNotificationReceived( notification:OneSignalNotification ):void {
				NativeAbilities.instance.showToast(notification.message, 2);
			}
			*/
		}
		
		/***********************************   LOGIN   ***********************************/
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
					var devInfo:DeviceInfo = DeviceInfoExtension.instance.deviceInfo;
					loginParams.putText("udid", AppModel.instance.platform == AppModel.PLATFORM_ANDROID ? NativeAbilities.instance.IMEI : Capabilities.serverString.substr(Math.max(0,Capabilities.serverString.length-150)));
					loginParams.putText("device", AppModel.instance.platform == AppModel.PLATFORM_ANDROID ? devInfo.manufacturer+"-"+devInfo.model : Capabilities.manufacturer);
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
			//GameAnalytics.config.setUserId("test_id");
			
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
		
		protected function sfsConnection_connectionLostHandler(event:SFSEvent):void
		{
			sfsConnection.logout();
			dispatchEvent(new LoadingEvent(LoadingEvent.CONNECTION_LOST));
		}
		
		/*******************************   LOAD CORE FILE   **********************************/
		public function loadCore():void
		{
			var coreLoader:CoreLoader = new CoreLoader(serverData.getText("coreVersion"), serverData);
			coreLoader.addEventListener(ErrorEvent.ERROR, coreLoader_errorHandler);
			coreLoader.addEventListener(Event.COMPLETE, coreLoader_completeHandler);
			state = STATE_CORE_LOADING;			
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
			if( UserData.getInstance().authenticated )
				finalize();
			else
				authenticateSocial();
		}
		
		/************************   AUTHENTICATE SOCIAL OR GAME SERVICES   ***************************/
		public function authenticateSocial():void
		{
			if ( !socials.initialized )
			{
				finalize();
				/*socials.user = new SocialUser();
				socials.user.id = "g01079473321487998344";
				socials.user.name = "ManJav";
				socials.user.imageURL = "content://com.google.android.gms.games.background/images/751cd60e/7927";
				sendSocialData();*/
				return;
			}
			
			if( !socials.authenticated )
			{
				state = STATE_SOCIAL_SIGNIN;			
				socials.addEventListener(SocialEvent.AUTHENTICATE, socialManager_authenticateHandler);
				socials.addEventListener(SocialEvent.FAILURE, socialManager_failureHandler);
				socials.signin();
				return;
			}
			sendSocialData();
		}
		protected function socialManager_failureHandler(event:SocialEvent):void
		{
			socials.removeEventListener(SocialEvent.AUTHENTICATE, socialManager_authenticateHandler);
			socials.removeEventListener(SocialEvent.FAILURE, socialManager_failureHandler);

			setTimeout(AppModel.instance.navigator.addLog, 3000, "Authentication Failed.");
			NativeAbilities.instance.showToast("Your ISP not allowed to connect google play service.", 2);
			finalize();
		}	
		protected function socialManager_authenticateHandler(event:SocialEvent):void
		{
			socials.removeEventListener(SocialEvent.AUTHENTICATE, socialManager_authenticateHandler);
			socials.removeEventListener(SocialEvent.FAILURE, socialManager_failureHandler);
			sendSocialData();
		}
		private function sendSocialData():void
		{
			state = STATE_SEND_SOCIAL_DATA;			
			var sfs:SFSObject = SFSObject.newInstance();
			sfs.putInt("accountType", socials.type);
			sfs.putText("accountId", socials.user.id);
			sfs.putText("accountName", socials.user.name);
			sfs.putText("accountImageURL", socials.user.imageURL);
			
			sfsConnection.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
			sfsConnection.sendExtensionRequest(SFSCommands.OAUTH, sfs);
		}
		protected function sfsConnection_extensionResponseHandler(event:SFSEvent):void
		{
			if( event.params.cmd != SFSCommands.OAUTH )
				return;
			sfsConnection.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
			UserData.getInstance().authenticated = true;

			finalize();
			
			var sfs:SFSObject = event.params.params;
			if( sfs.getInt("playerId") == AppModel.instance.game.player.id )
			{
				UserData.getInstance().save();	
				return;
			}
			
			var confirm:ConfirmPopup = new ConfirmPopup(ResourceManager.getInstance().getString("loc", "popup_reload_authenticated_label", [sfs.getText("playerName")]));
			confirm.data = sfs;
			confirm.addEventListener("select", confirm_eventsHandler);
			confirm.addEventListener("cancel", confirm_eventsHandler);
			AppModel.instance.navigator.addChild(confirm);
		}		
		private function confirm_eventsHandler(event:*):void
		{
			var confirm:ConfirmPopup = event.currentTarget as ConfirmPopup;
			confirm.removeEventListener("select", confirm_eventsHandler);
			confirm.removeEventListener("cancel", confirm_eventsHandler);
			if(event.type == "select")
			{
				var sfs:SFSObject = confirm.data as SFSObject;
				UserData.getInstance().id = sfs.getInt("playerId");
				UserData.getInstance().password = sfs.getText("playerPassword");
				NativeAbilities.instance.showToast(sfs.getInt("playerId") + " core:" + AppModel.instance.game.player.id, 2);
				//AppModel.instance.navigator.addChild(new GameLog(sfs.getInt("playerId") + " " + AppModel.instance.game.player.id + " " + sfs.getText("playerPassword")))
				UserData.getInstance().save();
				dispatchEvent(new LoadingEvent(LoadingEvent.FORCE_RELOAD));
				return;
			}
			UserData.getInstance().save();
		}
		
		/***********************************   FINALIZE   ***************************************/
		private function finalize():void
		{
			state = STATE_LOADED;
			dispatchEvent(new LoadingEvent(LoadingEvent.LOADED));
		}

	}
}