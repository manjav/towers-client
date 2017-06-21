package com.gerantech.towercraft.managers.net.sfs
{
	import com.smartfoxserver.v2.SmartFox;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.Room;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.smartfoxserver.v2.requests.ExtensionRequest;
	import com.smartfoxserver.v2.requests.LoginRequest;
	import com.smartfoxserver.v2.requests.LogoutRequest;
	
	import flash.events.IOErrorEvent;
	

	[Event(name="succeed",			type="com.gerantech.towercraft.managers.net.sfs.SFSConnection")]
	[Event(name="failure",			type="com.gerantech.towercraft.managers.net.sfs.SFSConnection")]

	public class SFSConnection extends SmartFox
	{
		public var userName:String;
		public var password:String;
		public var zoneName:String;
		private var loginParams:ISFSObject;
		
		public var retryTimeout:int = 500;
		public var retryMax:int = 3;
		public var retryIndex:int = 1;
		
		private static var _instance:SFSConnection;
		
		public static const SUCCEED:String = "succeed";
		public static const FAILURE:String = "failure";
		
		
		public function SFSConnection()
		{
			// Create an instance of the SmartFox class
			
			// Turn on the debug feature
			//debug = false;
			
			//sfs.addEventListener(SFSEvent.CONFIG_LOAD_SUCCESS,	sfs_configLoadSuccessHandler);
			//sfs.addEventListener(SFSEvent.CONFIG_LOAD_FAILURE,	sfs_configLoadFailureHandler);
			
			addEventListener(SFSEvent.CONNECTION,			sfs_connectionHandler);
			addEventListener(SFSEvent.SOCKET_ERROR,			sfs_connectionHandler);
			addEventListener(SFSEvent.CONNECTION_LOST,		sfs_connectionLostHandler);
			
			//login:
			addEventListener(SFSEvent.LOGIN, 				sfs_loginHandler);
			addEventListener(SFSEvent.LOGOUT, 				sfs_logoutHandler);
			addEventListener(SFSEvent.LOGIN_ERROR, 			sfs_loginErrorHandler);
			
			//addEventListener(SFSEvent.EXTENSION_RESPONSE,	sfs_extensionResponseHandler);

			loadConfig();
		}
		
		public function retry():void
		{
			if(config == null)
				loadConfig();
			else if(!isConnected)
				connect();
		}
		
		public function login(userName:String="", password:String="", zoneName:String="", params:ISFSObject=null):void
		{
			if(!isConnected)
				return;
			
			this.userName = userName;
			this.password = password;
			this.zoneName = zoneName;
			this.loginParams = params;
			
			send( new LoginRequest(userName, password, zoneName, loginParams) );
		}
		
		public function logout():void
		{
			if(!isConnected)
				return;
			send( new LogoutRequest() );
		}
		
		public function sendExtensionRequest(extCmd:String, params:ISFSObject=null, room:Room=null, useUDP:Boolean=false):void
		{
			if(!isConnected)
				return;
			send(new ExtensionRequest(extCmd, params, room, useUDP));
		}

		
		
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		// SFS2X event handlers
		//:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
		
		// Connection ....................................................
		protected function sfs_connectionHandler(event:SFSEvent):void
		{
			//trace("sfs_connectionHandler", event.params.success)//, "t["+(getTimer()-Tanks.t)+"]");
			if(event.type == SFSEvent.CONNECTION && event.params.success)
			{
				retryIndex = 0;
				if( hasEventListener( SFSConnection.SUCCEED ) )
					dispatchEvent(new SFSEvent(SFSConnection.SUCCEED, event.params));
			}
			else
			{
				if(retryIndex < retryMax)
				{
					disconnect();
					loadConfig();
					retryIndex ++;
				}
				else if(hasEventListener(SFSConnection.FAILURE))
				{
					dispatchEvent(new SFSEvent(SFSConnection.FAILURE, event.params));
				}
			}
		}
		protected function sfs_connectionLostHandler(event:SFSEvent):void
		{
			trace("Connection was lost. Reason: " + event.params.reason);
			//NativeApplication.nativeApplication.exit();
			//dispatchEvent(event.clone());
		}
		// Login ....................................................
		public function sfs_loginHandler(event:SFSEvent):void
		{
		//	trace("Login Succeed:", UserData.getInstance().userName, UserData.getInstance().password, "t["+(getTimer()-Tanks.t)+"]");
		//	dispatchEvent(event.clone());
		}
		protected function sfs_logoutHandler(event:SFSEvent):void
		{
			userName = password = zoneName = "";
		//	dispatchEvent(event.clone());
		}
		public function sfs_loginErrorHandler(event:SFSEvent):void
		{
			trace("Login failed: " + event.params.errorMessage);
			/*if(retryIndex < retryMax)
			{
				sfs.send( new LoginRequest(userName, password, zoneName, loginParams) );
				retryIndex ++;
			}
			else
			{*/
			//	dispatchEvent(event.clone());
			//}
		}	
		// Response ....................................................
		/*protected function sfs_extensionResponseHandler(event:SFSEvent):void
		{
			if(hasEventListener(event.type))
				dispatchEvent(event.clone());
		}	*/

		
		/*public function destroy():void
		{
			//TODO: connection lost bayad dobare ezafe shavad amma dar classe playOnlineSFS na inja
			trace("Connector is destroying...");
			// Add SFS2X event listeners
			//disconnect

			//sfs.removeEventListener(SFSEvent.CONFIG_LOAD_SUCCESS,	sfs_configLoadSuccessHandler)
			//sfs.removeEventListener(SFSEvent.CONFIG_LOAD_FAILURE,	sfs_configLoadFailureHandler)
				
			sfs.removeEventListener(SFSEvent.CONNECTION,			sfs_connectionHandler);
			sfs.removeEventListener(SFSEvent.SOCKET_ERROR,			sfs_socketErrorHandler);
			sfs.removeEventListener(SFSEvent.CONNECTION_LOST,		sfs_connectionLostHandler);
			//login:
			sfs.removeEventListener(SFSEvent.LOGIN,					sfs_loginHandler);
			sfs.removeEventListener(SFSEvent.LOGIN_ERROR,			sfs_loginErrorHandler);
			sfs.removeEventListener(SFSEvent.EXTENSION_RESPONSE,	sfs_extensionResponseHandler);
		}*/

		public static function get instance():SFSConnection
		{
			if(_instance == null)
				_instance = new SFSConnection();
			return _instance;
		}
	}
}