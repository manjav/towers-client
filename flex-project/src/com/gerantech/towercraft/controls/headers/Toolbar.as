package com.gerantech.towercraft.controls.headers
{
	import com.gerantech.towercraft.controls.TowersLayout;
	import com.gerantech.towercraft.controls.buttons.Indicator;
	import com.gerantech.towercraft.events.LoadingEvent;
	import com.gerantech.towercraft.managers.net.LoadingManager;
	import com.gerantech.towercraft.models.AppModel;
	import com.gt.towers.constants.ResourceType;
	import com.gt.towers.events.CoreEvent;
	
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.events.Event;
	
	public class Toolbar extends TowersLayout
	{
		private var pointIndicator:Indicator;
		private var softIndicator:Indicator;
		private var hardIndicator:Indicator;
		
		override protected function initialize():void
		{
			super.initialize();

			height = 120 * AppModel.instance.scale;
			var padding:Number = 48 * AppModel.instance.scale;
			layout = new AnchorLayout();
			
			pointIndicator = new Indicator("ltr", ResourceType.POINT, false, false);
			pointIndicator.layoutData = new AnchorLayoutData(NaN, NaN, NaN, padding, NaN, 0);
			addChild(pointIndicator);
			
			softIndicator = new Indicator("rtl", ResourceType.CURRENCY_SOFT);
			softIndicator.addEventListener(Event.TRIGGERED, indicators_triggerredHandler);
			softIndicator.layoutData = new AnchorLayoutData(NaN, padding, NaN, NaN, NaN, 0);
			addChild(softIndicator);
			
			hardIndicator = new Indicator("rtl", ResourceType.CURRENCY_HARD);
			hardIndicator.addEventListener(Event.TRIGGERED, indicators_triggerredHandler);
			hardIndicator.layoutData = new AnchorLayoutData(NaN, padding*3+softIndicator.width, NaN, NaN, NaN, 0);
			addChild(hardIndicator);
			
			if(appModel.loadingManager.state >= LoadingManager.STATE_LOADED )
				init();
			else
				appModel.loadingManager.addEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
		}
		protected function loadingManager_loadedHandler(event:LoadingEvent):void
		{
			appModel.loadingManager.removeEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
			init();
		}
		
		private function init():void
		{
			player.resources.addEventListener(CoreEvent.CHANGE, playerResources_changeHandler);
			updateIndicators();
		}
		
		protected function playerResources_changeHandler(event:CoreEvent):void
		{
			trace("CoreEvent.CHANGE:", ResourceType.getName(event.key), event.from, event.to);
			updateIndicators();
		}
		
		private function updateIndicators():void
		{
			pointIndicator.visible = !player.inTutorial();
			if(pointIndicator.visible)
				pointIndicator.setData(0, player.get_point(), NaN);
			softIndicator.setData(0, player.get_softs(), NaN);
			hardIndicator.setData(0, player.get_hards(), NaN);
		}		
		
		private function indicators_triggerredHandler(event:Event):void
		{
			dispatchEventWith(Event.TRIGGERED);
		}

		override public function dispose():void
		{
			player.resources.removeEventListener(CoreEvent.CHANGE, playerResources_changeHandler);
			super.dispose();
		}
		
	}
}