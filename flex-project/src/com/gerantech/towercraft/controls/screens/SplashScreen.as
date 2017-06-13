package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.events.LoadingEvent;
	import com.gerantech.towercraft.managers.net.LoadingManager;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	public class SplashScreen extends Sprite
	{
		private var logo:Bitmap;
		private var _alpha:Number = 1;
		
		public function SplashScreen()
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHadnler);
			
			LoadingManager.instance.addEventListener(LoadingEvent.LOADED,			loadingManager_eventsHandler);
			LoadingManager.instance.addEventListener(LoadingEvent.NETWORK_ERROR,	loadingManager_eventsHandler);
			LoadingManager.instance.addEventListener(LoadingEvent.LOGIN_ERROR, 		loadingManager_eventsHandler);
			LoadingManager.instance.addEventListener(LoadingEvent.NOTICE_UPDATE,	loadingManager_eventsHandler);
			LoadingManager.instance.addEventListener(LoadingEvent.FORCE_UPDATE,		loadingManager_eventsHandler);
			
			logo = new Assets.splash_bitmap();
			logo.smoothing = true;
			addChild(logo);
		}
		protected function addedToStageHadnler(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHadnler);
			
			graphics.beginFill(0);
			graphics.drawRect(0, 0, stage.fullScreenWidth, stage.fullScreenHeight);
			
			logo.width = Math.max(width, height)/3;
			logo.scaleY = logo.scaleX;
			logo.x = (width-logo.width)/2;
			logo.y = (height-logo.height)/2;
		}
		
		protected function loadingManager_eventsHandler(event:LoadingEvent):void
		{
			event.currentTarget.removeEventListener(LoadingEvent.LOADED,		loadingManager_eventsHandler);
			event.currentTarget.removeEventListener(LoadingEvent.NETWORK_ERROR,	loadingManager_eventsHandler);
			event.currentTarget.removeEventListener(LoadingEvent.LOGIN_ERROR, 	loadingManager_eventsHandler);
			event.currentTarget.removeEventListener(LoadingEvent.NOTICE_UPDATE,	loadingManager_eventsHandler);
			event.currentTarget.removeEventListener(LoadingEvent.FORCE_UPDATE,	loadingManager_eventsHandler);
			
			switch(event.type)
			{
				case LoadingEvent.LOADED:
					trace("LoadingEvent.LOADED", "t["+(getTimer()-TowerCraft.t)+"]")
					addEventListener(Event.ENTER_FRAME, enterFrameHandler); // fade-out splash screen
					break;
				
				default:
					// complain !!!!! ..............
					trace("LoadingEvent:", event.type, "t["+(getTimer()-TowerCraft.t)+"]")
					break;
			}
		}
		
		protected function enterFrameHandler(event:Event):void
		{
			_alpha -= 0.08;
			alpha = _alpha;

			if(_alpha <= 0)
			{
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				AppModel.instance.navigator.dispatchEventWith("complete");
				parent.removeChild(this);
			}
		}
	}
}