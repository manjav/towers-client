package com.gerantech.towercraft.managers.net
{

	import com.gerantech.towercraft.events.LoadingEvent;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.vo.UserData;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
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
			sfsConnection.addEventListener(SFSEvent.CONNECTION, sfsConnection_connectionHandler);
			
			UserData.getInstance().load();
		}
		
		protected function sfsConnection_connectionHandler(event:SFSEvent):void
		{
			sfsConnection.removeEventListener(SFSEvent.CONNECTION, sfsConnection_connectionHandler);
			if(event.params.success)
				login();
			else
				dispatchEvent(new LoadingEvent(LoadingEvent.NETWORK_ERROR));
		}
		
		/**************************************   LOGIN   ****************************************/
		private function login():void 
		{
			sfsConnection.addEventListener(SFSEvent.LOGIN, sfsConnection_signupHandler);
			sfsConnection.addEventListener(SFSEvent.LOGIN_ERROR, sfsConnection_signupErrorHandler);
			sfsConnection.login(UserData.getInstance().id.toString(), UserData.getInstance().password, "");
		}
		protected function sfsConnection_signupErrorHandler(event:SFSEvent):void
		{
			sfsConnection.removeEventListener(SFSEvent.LOGIN, sfsConnection_signupHandler);
			sfsConnection.removeEventListener(SFSEvent.LOGIN_ERROR, sfsConnection_signupErrorHandler);
		}
		protected function sfsConnection_signupHandler(event:SFSEvent):void
		{
			sfsConnection.removeEventListener(SFSEvent.LOGIN, sfsConnection_signupHandler);
			sfsConnection.removeEventListener(SFSEvent.LOGIN_ERROR, sfsConnection_signupErrorHandler);
			
			var data:SFSObject = event.params.data;
			
			// in registring case
			if(data.containsKey("password"))
			{
				if(data.containsKey("id"))
					UserData.getInstance().id = data.getLong("id");
				
				UserData.getInstance().password = data.getText("password");
				UserData.getInstance().save();
			}
			
			dispatchEvent(new LoadingEvent(LoadingEvent.LOADED));
			
			// trace(event.params.dagetS("success"));
			// Load << Game-Core >>
			/*var coreLoader:CoreLoader = new CoreLoader("0.9.7.1000", event.params.params);//  "http://51.254.79.215/home/arman/SmartFoxServer_2X/SFS2X/extensions/MyZoneExts/core.swf")
			coreLoader.addEventListener(Event.COMPLETE, coreLoader_completeHandler);
			}
		}
		
		protected function coreLoader_completeHandler(event:Event):void
		{
			event.currentTarget.removeEventListener(Event.COMPLETE, coreLoader_completeHandler);
			
			if(AppModel.getInstance().descriptor.versionCode < Game.get_instance().noticeVersion)
			dispatchEvent(new LoadingEvent(LoadingEvent.NOTICE_UPDATE));
			else if(AppModel.getInstance().descriptor.versionCode < Game.get_instance().forceVersion)
			dispatchEvent(new LoadingEvent(LoadingEvent.FORCE_UPDATE));
			else
			dispatchEvent(new LoadingEvent(LoadingEvent.LOADED));*/
		}
		

		
		/*protected function sfsConnection_signupExtensionResponseHandler(event:SFSEvent):void
		{
		
		================================================================
		var sfs:SFSObject = new SFSObject();
		sfs.putInt("n1", 12);
		sfs.putInt("n2", 33);
		
		sfsConnection.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
		sfsConnection.send("add", sfs);
		protected function sfsConnection_extensionResponseHandler(event:SFSEvent):void
		{
			trace(event.params);
		}
		
		
		=============================================================
			switch(event.params.cmd)
			{
				case Commands.CMD_SUBMIT:
					sfsConnection.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_signupExtensionResponseHandler);
					if (event.params.params.getBool("success"))
					{
						trace("Success, thanks for registering: ",UserData.getInstance().userName, UserData.getInstance().password, UserData.getInstance().email);
						UserData.getInstance().save();
						signin();
					}
					else
					{
						dispatchEvent(new LoadingEvent(LoadingEvent.SIGNUP_ERROR, "SignUp Error: " + event.params.params.getUtfString("errorMessage")));
					}
					break;
				
				case Commands.ANS_TIME:
					var serverTime:Number = event.params.params.getLong(Commands.SFSOBJ_DATA_COMMAND);
					UserData.getInstance().userName = serverTime.toString() + StringUtils.generateRandomString(5);
					UserData.getInstance().email = serverTime+"@fakeMail.com";
					
					var sfso:SFSObject = new SFSObject();
					//they should match the corresponding column name in database table:
					//sfso.putUtfString("uid", "12");
					sfso.putUtfString("username", UserData.getInstance().userName);
					sfso.putUtfString("nickname", UserData.getInstance().nickName);
					sfso.putUtfString("pass", UserData.getInstance().password);
					sfso.putUtfString("email", UserData.getInstance().email);
					
					trace("sfso",sfso.getDump());
					sfsConnection.send(Commands.CMD_SUBMIT, sfso);
					break;
			}			
		}*/	
	}
}