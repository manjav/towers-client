package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.controls.popups.ConfirmPopup;
	import com.gerantech.towercraft.events.LoadingEvent;
	import com.gerantech.towercraft.managers.net.LoadingManager;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.getTimer;
	
	import starling.core.Starling;
	import starling.events.Event;
	
	public class SplashScreen extends Sprite
	{
		private var logo:Bitmap;
		private var _alpha:Number = 1;
		
		public function SplashScreen()
		{
			addEventListener("addedToStage", addedToStageHadnler);
			
			AppModel.instance.loadingManager = new LoadingManager();
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.LOADED,			loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.NETWORK_ERROR,	loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.LOGIN_ERROR, 	loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.NOTICE_UPDATE,	loadingManager_eventsHandler);
			AppModel.instance.loadingManager.addEventListener(LoadingEvent.FORCE_UPDATE,	loadingManager_eventsHandler);
			
			logo = new Assets.splash_bitmap();
			logo.smoothing = true;
			addChild(logo);
		}
		protected function addedToStageHadnler(event:*):void
		{
			removeEventListener("addedToStage", addedToStageHadnler);
			
			graphics.beginFill(0x3d4759);
			graphics.drawRect(0, 0, stage.fullScreenWidth, stage.fullScreenHeight);
			
			logo.width = Math.max(width, height)/3;
			logo.scaleY = logo.scaleX;
			logo.x = (width-logo.width)/2;
			logo.y = (height-logo.height)/2;
		}
		
		protected function loadingManager_eventsHandler(event:LoadingEvent):void
		{
			AppModel.instance.loadingManager.removeEventListener(LoadingEvent.LOADED,			loadingManager_eventsHandler);
			AppModel.instance.loadingManager.removeEventListener(LoadingEvent.NETWORK_ERROR,	loadingManager_eventsHandler);
			AppModel.instance.loadingManager.removeEventListener(LoadingEvent.LOGIN_ERROR, 		loadingManager_eventsHandler);
			AppModel.instance.loadingManager.removeEventListener(LoadingEvent.NOTICE_UPDATE,	loadingManager_eventsHandler);
			AppModel.instance.loadingManager.removeEventListener(LoadingEvent.FORCE_UPDATE,		loadingManager_eventsHandler);
			
			switch(event.type)
			{
				case LoadingEvent.LOADED:
					trace("LoadingEvent.LOADED", "t["+(getTimer()-Towers.t)+"]")
					addEventListener("enterFrame", enterFrameHandler); // fade-out splash screen
					break;
				
				case LoadingEvent.NOTICE_UPDATE:
				case LoadingEvent.FORCE_UPDATE:
					var confirm:ConfirmPopup = new ConfirmPopup(event.type);
					confirm.data = event.type;
					confirm.addEventListener(Event.SELECT, confirm_eventsHandler);
					confirm.addEventListener(Event.CANCEL, confirm_eventsHandler);
					AppModel.instance.navigator.addChild(confirm);
					parent.removeChild(this);
					break;
				
				default:
					// complain !!!!! ..............
					trace("LoadingEvent:", event.type, "t["+(getTimer()-Towers.t)+"]");
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
				navigateToURL(new URLRequest("http://per.city"));
				NativeApplication.nativeApplication.exit();
				return;
			}
			
			if(confirm.data == LoadingEvent.NOTICE_UPDATE)
				AppModel.instance.loadingManager.loadCore();
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
	}
}