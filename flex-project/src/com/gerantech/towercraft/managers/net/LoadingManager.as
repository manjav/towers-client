package com.gerantech.towercraft.managers.net
{

	import com.gerantech.extensions.NativeAbilities;
	import com.gerantech.towercraft.controls.popups.ConfirmPopup;
	import com.gerantech.towercraft.events.LoadingEvent;
	import com.gerantech.towercraft.managers.TimeManager;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.UserPrefs;
	import com.gerantech.towercraft.managers.VideoAdsManager;
	import com.gerantech.towercraft.managers.net.sfs.LobbyManager;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.managers.socials.SocialEvent;
	import com.gerantech.towercraft.managers.socials.SocialManager;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.vo.UserData;
	import com.gerantech.towercraft.utils.StrUtils;
	import com.gerantech.towercraft.utils.Utils;
	import com.marpies.ane.onesignal.OneSignal;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.Capabilities;
	import flash.utils.getTimer;
	
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
		public var serverData:SFSObject;
		
		private var sfsConnection:SFSConnection;
		private var socials:SocialManager;

		public function load():void
		{
			loadStartAt = getTimer();
			SFSConnection.dispose();
			sfsConnection = SFSConnection.instance;
			sfsConnection.addEventListener(SFSConnection.SUCCEED, sfsConnection_connectionHandler);
			sfsConnection.addEventListener(SFSConnection.FAILURE, sfsConnection_connectionHandler);
			state = STATE_CONNECT;
			
			if( socials == null )
			{
				socials = new SocialManager();
				socials.init( SocialManager.TYPE_GOOGLEPLAY );
			}
			if( AppModel.instance.navigator != null )
			{
				AppModel.instance.navigator.popToRootScreen();
				AppModel.instance.navigator.removeAllPopups();
			}
			if(UserData.instance.prefs == null )
				UserData.instance.prefs = new UserPrefs();
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
		
		/***********************************   LOGIN   ***********************************/
		private function login():void 
		{
			state = STATE_LOGIN;
			UserData.instance.load();
			sfsConnection.addEventListener(SFSEvent.LOGIN,			sfsConnection_loginHandler);
			sfsConnection.addEventListener(SFSEvent.LOGIN_ERROR,	sfsConnection_loginErrorHandler);
			
			var loginParams:ISFSObject = new SFSObject();
			loginParams.putInt("id", UserData.instance.id);

			// new player
			var __id:int = UserData.instance.id;
			if( __id < 0 )
			{
				if( __id == -1 )
					__id = - Math.random()*(int.MAX_VALUE/2);
				else if( __id == -2 )
					__id = - int.MAX_VALUE/2 - Math.random()*(int.MAX_VALUE/2);
				
				if( __id > - int.MAX_VALUE/2 )
				{
					loginParams.putText("udid", AppModel.instance.platform == AppModel.PLATFORM_ANDROID ? NativeAbilities.instance.deviceInfo.id : Utils.getPCUniqueCode());
					loginParams.putText("device", AppModel.instance.platform == AppModel.PLATFORM_ANDROID ? StrUtils.truncateText(NativeAbilities.instance.deviceInfo.manufacturer+"-"+NativeAbilities.instance.deviceInfo.model, 32, "") : Capabilities.manufacturer);
				}
			}
			loginParams.putInt("appver", AppModel.instance.descriptor.versionCode);
			loginParams.putText("market", AppModel.instance.descriptor.market);

			sfsConnection.login(__id.toString(), UserData.instance.password, "", loginParams);
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
			
			if( serverData.containsKey("umt") )
			{
				dispatchEvent(new LoadingEvent(LoadingEvent.UNDER_MAINTENANCE, serverData));
				return;
			}			
			if( serverData.containsKey("exists") )
			{
				dispatchEvent(new LoadingEvent(LoadingEvent.LOGIN_USER_EXISTS, serverData));
				return;
			}

			// in registring case
			if(serverData.containsKey("password"))
			{
				UserData.instance.id = serverData.getLong("id");
				UserData.instance.password = serverData.getText("password");
				UserData.instance.save();
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
			var coreLoader:CoreLoader = new CoreLoader(serverData);
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
			event.currentTarget.removeEventListener(Event.COMPLETE, coreLoader_completeHandler);
			//trace(AppModel.instance.descriptor.versionCode, Game.loginData.noticeVersion, Game.loginData.forceVersion)
			//if( UserData.instance.authenticated )
				finalize();
			//else
			//	authenticateSocial();
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

			//setTimeout(AppModel.instance.navigator.addLog, 3000, "Authentication Failed.");
			NativeAbilities.instance.showToast("Your ISP not allowed to connect google play service.", 1);
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
			UserData.instance.authenticated = true;

			finalize();
			
			var sfs:SFSObject = event.params.params;
			if( sfs.getInt("playerId") == AppModel.instance.game.player.id )
			{
				UserData.instance.save();	
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
				UserData.instance.id = sfs.getInt("playerId");
				UserData.instance.password = sfs.getText("playerPassword");
				NativeAbilities.instance.showToast(sfs.getInt("playerId") + " core:" + AppModel.instance.game.player.id, 2);
				//AppModel.instance.navigator.addChild(new GameLog(sfs.getInt("playerId") + " " + AppModel.instance.game.player.id + " " + sfs.getText("playerPassword")))
				UserData.instance.save();
				dispatchEvent(new LoadingEvent(LoadingEvent.FORCE_RELOAD));
				return;
			}
			UserData.instance.save();
		}
		
		/***********************************   FINALIZE   ***************************************/
		private function finalize():void
		{
			state = STATE_LOADED;
			sfsConnection.lobbyManager = new LobbyManager();
			dispatchEvent(new LoadingEvent(LoadingEvent.LOADED));
			
			registerPushManager();
			UserData.instance.prefs.requestData();
			
			// catch video ads
			VideoAdsManager.instance.requestAd(VideoAdsManager.TYPE_CHESTS, true);
			if( AppModel.instance.game.player.get_questIndex() < AppModel.instance.game.fieldProvider.quests.keys().length )
				VideoAdsManager.instance.requestAd(VideoAdsManager.TYPE_QUESTS, true);
		}
		
		private function registerPushManager():void
		{
			
			OneSignal.settings.setAutoRegister( true ).setEnableInAppAlerts( false ).setShowLogs( false );
			OneSignal.idsAvailable( onOneSignalIdsAvailable );
			function onOneSignalIdsAvailable( oneSignalUserId:String, oneSignalPushToken:String ):void {
				var pushParams:ISFSObject = new SFSObject();
				if( UserData.instance.oneSignalUserId != oneSignalUserId )
				{
					pushParams.putText("oneSignalUserId", oneSignalUserId);
					UserData.instance.oneSignalUserId = oneSignalUserId;
				}
				if( UserData.instance.oneSignalPushToken != oneSignalPushToken )
				{
					pushParams.putText("oneSignalPushToken", oneSignalPushToken);
					UserData.instance.oneSignalPushToken = oneSignalPushToken;// 'pushToken' may be null if there's a server or connection error
				}
				if( pushParams.containsKey("oneSignalUserId") )
				{
					UserData.instance.save();
					sfsConnection.sendExtensionRequest(SFSCommands.REGISTER_PUSH, pushParams);
				}
			}
			if( OneSignal.init( "83cdb330-900e-4494-82a8-068b5a358c18" ) ) {
				//NativeAbilities.instance.showToast("OneSignal.init", 2);
			}
			/*OneSignal.addNotificationReceivedCallback( onNotificationReceived );
			function onNotificationReceived( notification:OneSignalNotification ):void {
			NativeAbilities.instance.showToast(notification.message, 2);
			}*/			
		}
		
	}
}