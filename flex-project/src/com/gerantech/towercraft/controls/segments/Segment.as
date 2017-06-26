package com.gerantech.towercraft.controls.segments
{
	
	import com.gerantech.towercraft.controls.TowersLayout;
	import com.gerantech.towercraft.events.LoadingEvent;
	import com.gerantech.towercraft.managers.net.LoadingManager;
	
	public class Segment extends TowersLayout
	{
		public function Segment()
		{
			super();
		}
		override protected function initialize():void
		{
			super.initialize();
			if(appModel.loadingManager.state <  LoadingManager.STATE_LOADED )
			{
				appModel.loadingManager.addEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
				return;
			}
			createElements();
		}
		
		protected function loadingManager_loadedHandler(event:LoadingEvent):void
		{
			appModel.loadingManager.removeEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
			createElements();
		}
		
		protected function createElements():void
		{}
	}
}