package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.controls.popups.ConfirmPopup;
	import com.gerantech.towercraft.controls.popups.MessagePopup;
	import com.gerantech.towercraft.events.LoadingEvent;
	import com.gerantech.towercraft.managers.net.LoadingManager;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.getTimer;
	
	import mx.resources.ResourceManager;
	
	import starling.events.Event;
	
	public class SplashScreen extends Sprite
	{
		private var logo:Bitmap;
		private var _alpha:Number = 1;
		private var _parent:DisplayObjectContainer;
		
		public function SplashScreen()
		{
			addEventListener("addedToStage", addedToStageHadnler);
			
			AppModel.instance.loadingManager = new LoadingManager();
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.LOADED,				loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.NETWORK_ERROR,		loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.LOGIN_ERROR, 		loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.NOTICE_UPDATE,		loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.FORCE_UPDATE,		loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.CORE_LOADING_ERROR,	loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.CONNECTION_LOST,		loadingManager_eventsHandler);
			AppModel.instance.loadingManager.load();
			
			logo = new Assets.splash_bitmap();
			logo.smoothing = true;
			addChild(logo);
		}
		protected function addedToStageHadnler(event:*):void
		{
			removeEventListener("addedToStage", addedToStageHadnler);
			_parent = parent;
			graphics.beginFill(0x3d4759);
			graphics.drawRect(0, 0, stage.fullScreenWidth*2, stage.fullScreenHeight*2);
			
			logo.width = Math.max(stage.fullScreenWidth, stage.fullScreenHeight)/3;
			logo.scaleY = logo.scaleX;
			logo.x = (stage.fullScreenWidth-logo.width)/2;
			logo.y = (stage.fullScreenHeight-logo.height)/2;
		}
		
		protected function loadingManager_eventsHandler(event:LoadingEvent):void
		{

			AppModel.instance.loadingManager.removeEventListener(LoadingEvent.LOADED,				loadingManager_eventsHandler);
			AppModel.instance.loadingManager.removeEventListener(LoadingEvent.NETWORK_ERROR,		loadingManager_eventsHandler);
			AppModel.instance.loadingManager.removeEventListener(LoadingEvent.LOGIN_ERROR, 			loadingManager_eventsHandler);
			AppModel.instance.loadingManager.removeEventListener(LoadingEvent.NOTICE_UPDATE,		loadingManager_eventsHandler);
			AppModel.instance.loadingManager.removeEventListener(LoadingEvent.FORCE_UPDATE,			loadingManager_eventsHandler);
			AppModel.instance.loadingManager.removeEventListener(LoadingEvent.CORE_LOADING_ERROR,	loadingManager_eventsHandler);
			trace(event.type)
			switch(event.type)
			{
				case LoadingEvent.LOADED:
					trace("LoadingEvent.LOADED", "t["+(getTimer()-Towers.t)+ ","+(getTimer()-AppModel.instance.loadingManager.loadStartAt)+"]")
					if(parent)
						addEventListener("enterFrame", enterFrameHandler); // fade-out splash screen
					break;
				case LoadingEvent.CONNECTION_LOST:
					var reloadpopup:MessagePopup = new MessagePopup(loc("popup_"+event.type+"_message"), loc("popup_reload_label"));
					reloadpopup.data = event.type;
					reloadpopup.addEventListener(Event.SELECT, confirm_eventsHandler);
					AppModel.instance.navigator.addPopup(reloadpopup);
					if(parent)
						parent.removeChild(this);
					break;
		
				default:
					var acceptLabel:String = event.type==LoadingEvent.NOTICE_UPDATE || event.type==LoadingEvent.FORCE_UPDATE ? "popup_update_label" :  "popup_reload_label";
					var confirm:ConfirmPopup = new ConfirmPopup(loc("popup_"+event.type+"_message"), loc(acceptLabel));
					confirm.data = event.type;
					confirm.declineStyle = "danger";
					confirm.addEventListener(Event.SELECT, confirm_eventsHandler);
					confirm.addEventListener(Event.CANCEL, confirm_eventsHandler);
					AppModel.instance.navigator.addPopup(confirm);
					if(parent)
						parent.removeChild(this);
					/*break;
					// complain !!!!! ..............
					trace("LoadingEvent:", event.type, "t["+(getTimer()-Towers.t)+"]");*/
					break;
			}
		}
		
		private function confirm_eventsHandler(event:Event):void
		{
			var confirm:ConfirmPopup = event.currentTarget as ConfirmPopup;
			confirm.removeEventListener(Event.SELECT, confirm_eventsHandler);
			confirm.removeEventListener(Event.CANCEL, confirm_eventsHandler);
			if(event.type == Event.SELECT)
			{
				switch(confirm.data)
				{
					case LoadingEvent.NOTICE_UPDATE:
					case LoadingEvent.FORCE_UPDATE:
						navigateToURL(new URLRequest("http://towers.grantech.ir/get/towerstory.apk"));
					case LoadingEvent.CORE_LOADING_ERROR:
						NativeApplication.nativeApplication.exit();
						break;
					
					case LoadingEvent.NETWORK_ERROR:
					case LoadingEvent.CONNECTION_LOST:
						reload();
				}
				return;
			}
			
			switch(confirm.data)
			{
				case LoadingEvent.NOTICE_UPDATE:
					AppModel.instance.loadingManager.loadCore();
					return;
			}
			NativeApplication.nativeApplication.exit();
		}
		
		private function reload():void
		{
			alpha = _alpha = 1;
			_parent.addChild(this);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.LOADED,			loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.NETWORK_ERROR,	loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.LOGIN_ERROR, 	loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.NOTICE_UPDATE,	loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.FORCE_UPDATE,	loadingManager_eventsHandler);
			AppModel.instance.loadingManager.load();
		}
		
		protected function enterFrameHandler(event:*):void
		{
			_alpha -= 0.08;
			alpha = _alpha;

			if(_alpha <= 0)
			{
				removeEventListener("enterFrame", enterFrameHandler);
				parent.removeChild(this);
			}
		}
		
		protected function loc(resourceName:String, parameters:Array=null, locale:String=null):String
		{
			return ResourceManager.getInstance().getString("loc", resourceName, parameters, locale);
		}
	}
}