package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.controls.popups.BanPopup;
	import com.gerantech.towercraft.controls.popups.ConfirmPopup;
	import com.gerantech.towercraft.controls.popups.MessagePopup;
	import com.gerantech.towercraft.controls.popups.UnderMaintenancePopup;
	import com.gerantech.towercraft.events.LoadingEvent;
	import com.gerantech.towercraft.managers.BillingManager;
	import com.gerantech.towercraft.managers.net.LoadingManager;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.vo.UserData;
	import com.gerantech.towercraft.utils.StrUtils;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.getTimer;
	
	import mx.resources.ResourceManager;
	
	
	public class SplashScreen extends Sprite
	{
		[Embed(source="../../../../../assets/animations/splash-screen.swf")]
		private static const splash_screen_file:Class;
		
		private var logo:MovieClip;
		private var _parent:DisplayObjectContainer;
		
		public function SplashScreen()
		{
			addEventListener("addedToStage", addedToStageHadnler);
			
			logo = new splash_screen_file();
			logo.addEventListener("clear", logo_clearHandler);
			addChild(logo);
		}
		protected function logo_clearHandler(event:*):void
		{
			logo.removeEventListener("clear", logo_clearHandler);
			
			if(	AppModel.instance.loadingManager == null )
				AppModel.instance.loadingManager = new LoadingManager();
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.NETWORK_ERROR,		loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.LOGIN_ERROR, 		loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.LOGIN_USER_EXISTS, 	loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.LOGIN_USER_BANNED, 	loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.UNDER_MAINTENANCE, 	loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.NOTICE_UPDATE,		loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.FORCE_UPDATE,		loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.CORE_LOADING_ERROR,	loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.LOADED,				loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.CONNECTION_LOST,		loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.FORCE_RELOAD,		loadingManager_eventsHandler);
			AppModel.instance.loadingManager.load();
		}
		protected function addedToStageHadnler(event:*):void
		{
			stage.addEventListener("resize", stage_resizeHandler);
			removeEventListener("addedToStage", addedToStageHadnler);
			_parent = parent;
		}
		protected function stage_resizeHandler(event:*):void
		{
			graphics.clear();
			graphics.beginFill(0);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			logo.scaleX = stage.stageWidth/logo.width
			logo.scaleY= stage.stageHeight/logo.height;
		}
		
		protected function loadingManager_eventsHandler(event:LoadingEvent):void
		{
			AppModel.instance.loadingManager.removeEventListener(LoadingEvent.NETWORK_ERROR,		loadingManager_eventsHandler);
			AppModel.instance.loadingManager.removeEventListener(LoadingEvent.LOGIN_ERROR, 			loadingManager_eventsHandler);
			AppModel.instance.loadingManager.removeEventListener(LoadingEvent.LOGIN_USER_EXISTS, 	loadingManager_eventsHandler);
			AppModel.instance.loadingManager.removeEventListener(LoadingEvent.LOGIN_USER_BANNED, 	loadingManager_eventsHandler);
			AppModel.instance.loadingManager.removeEventListener(LoadingEvent.UNDER_MAINTENANCE, 	loadingManager_eventsHandler);
			AppModel.instance.loadingManager.removeEventListener(LoadingEvent.NOTICE_UPDATE,		loadingManager_eventsHandler);
			AppModel.instance.loadingManager.removeEventListener(LoadingEvent.FORCE_UPDATE,			loadingManager_eventsHandler);
			AppModel.instance.loadingManager.removeEventListener(LoadingEvent.CORE_LOADING_ERROR,	loadingManager_eventsHandler);
			AppModel.instance.loadingManager.removeEventListener(LoadingEvent.LOADED,				loadingManager_eventsHandler);

			trace(event.type)
			var confirmData:SFSObject = new SFSObject();
			confirmData.putText("type", event.type);			
			
			switch(event.type)
			{
				case LoadingEvent.LOADED:
					trace("LoadingEvent.LOADED", "t["+(getTimer()-Towers.t)+ ","+(getTimer()-AppModel.instance.loadingManager.loadStartAt)+"]");
					logo.addEventListener("cancel", logo_cancelHandler);
					if( stage != null )
						stage.dispatchEvent(new Event("continue"));
					break;
				case LoadingEvent.CONNECTION_LOST:
					var reloadpopup:MessagePopup = new MessagePopup(loc("popup_"+event.type+"_message"), loc("popup_reload_label"));
					reloadpopup.data = confirmData;
					reloadpopup.closeOnOverlay = false;
					reloadpopup.addEventListener("select", confirm_eventsHandler);
					AppModel.instance.navigator.addPopup(reloadpopup);
					if(parent)
						parent.removeChild(this);
					break;
				
				case LoadingEvent.FORCE_RELOAD:
					reload();
					break;
				
				case LoadingEvent.UNDER_MAINTENANCE:
					if( parent )
						parent.removeChild(this);
					AppModel.instance.navigator.addPopup(new UnderMaintenancePopup(event.data.getInt("umt")));
					break;
				
				case LoadingEvent.LOGIN_USER_BANNED:
					if( parent )
						parent.removeChild(this);
					var popup:BanPopup = new BanPopup();
					popup.data = event.data.getSFSObject("ban").getUtfString("message") + "\n\n" + StrUtils.toTimeFormat( event.data.getSFSObject("ban").getLong("until") );
					AppModel.instance.navigator.addPopup(popup);
					return;
		
				default:
					var message:String = loc("popup_"+event.type+"_message");
					if( event.type == LoadingEvent.LOGIN_ERROR )
					{
						if( event.data == 2 || event.data == 3 || event.data == 6 )
							message = loc("popup_loginError_" + event.data + "_message");
					}
					else if( event.type == LoadingEvent.LOGIN_USER_EXISTS )
					{
						message = loc("popup_reload_authenticated_label", [event.data.getText("name")]);
					}
					
					var acceptLabel:String = "popup_reload_label";
					if( event.type == LoadingEvent.NOTICE_UPDATE || event.type == LoadingEvent.FORCE_UPDATE )
						acceptLabel = "popup_update_label";
					else if( event.type == LoadingEvent.LOGIN_USER_EXISTS )
						acceptLabel = "popup_accept_label";
					
					if( event.type == LoadingEvent.LOGIN_USER_EXISTS )
						confirmData.putSFSObject("serverData", event.data as SFSObject);
					
					var confirm:ConfirmPopup = new ConfirmPopup(message, loc(acceptLabel));
					confirm.closeOnOverlay = false;
					confirm.data = confirmData;
					confirm.declineStyle = "danger";
					confirm.addEventListener("select", confirm_eventsHandler);
					confirm.addEventListener("cancel", confirm_eventsHandler);
					AppModel.instance.navigator.addPopup(confirm);
					if(parent)
						parent.removeChild(this);
					/*break;
					// complain !!!!! ..............
					trace("LoadingEvent:", event.type, "t["+(getTimer()-Towers.t)+"]");*/
					break;
			}
		}
		
		private function confirm_eventsHandler(event:*):void
		{
			var confirm:ConfirmPopup = event.currentTarget as ConfirmPopup;
			confirm.closeOnOverlay = false;
			confirm.removeEventListener("select", confirm_eventsHandler);
			confirm.removeEventListener("cancel", confirm_eventsHandler);
			
			var confirmData:SFSObject = confirm.data as SFSObject;
			if(event.type == "select")
			{
				switch(confirmData.getText("type"))
				{
					case LoadingEvent.NOTICE_UPDATE:
					case LoadingEvent.FORCE_UPDATE:
						navigateToURL(new URLRequest(BillingManager.instance.getDownloadURL()));
						break;
					
					case LoadingEvent.CORE_LOADING_ERROR:
						AppModel.instance.loadingManager.addEventListener(LoadingEvent.LOADED,				loadingManager_eventsHandler);
						AppModel.instance.loadingManager.addEventListener(LoadingEvent.CORE_LOADING_ERROR,	loadingManager_eventsHandler);
						AppModel.instance.loadingManager.loadCore();
						break;
					
					case LoadingEvent.LOGIN_USER_EXISTS:
						UserData.instance.id = confirmData.getSFSObject("serverData").getLong("id");
						UserData.instance.password = confirmData.getSFSObject("serverData").getText("password");
						UserData.instance.save();
						reload();
						break;

					default:
						reload();
				}
				return;
			}
			
			switch(confirmData.getText("type"))
			{
				case LoadingEvent.NOTICE_UPDATE:
					AppModel.instance.loadingManager.addEventListener(LoadingEvent.LOADED,				loadingManager_eventsHandler);
					AppModel.instance.loadingManager.addEventListener(LoadingEvent.CORE_LOADING_ERROR,	loadingManager_eventsHandler);
					AppModel.instance.loadingManager.loadCore();
					return;
					
				case LoadingEvent.LOGIN_USER_EXISTS:
					UserData.instance.id = -2;
					UserData.instance.save();
					reload();
					return;
			}
			NativeApplication.nativeApplication.exit();
		}
		
		private function reload():void
		{
			AppModel.instance.loadingManager.removeEventListener(LoadingEvent.CONNECTION_LOST,	loadingManager_eventsHandler);
			AppModel.instance.loadingManager.removeEventListener(LoadingEvent.FORCE_RELOAD,		loadingManager_eventsHandler);
			_parent.addChild(this);
			logo.addEventListener("clear", logo_clearHandler);
			stage.dispatchEvent(new Event("start"));
		}
		protected function logo_cancelHandler(event:*):void
		{
			logo.removeEventListener("cancel", logo_cancelHandler);
			if(parent)
				parent.removeChild(this);
		}
		
		protected function loc(resourceName:String, parameters:Array=null, locale:String=null):String
		{
			return ResourceManager.getInstance().getString("loc", resourceName, parameters, locale);
		}
	}
}