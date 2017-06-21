package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.controls.buttons.Indicator;
	import com.gerantech.towercraft.events.LoadingEvent;
	import com.gerantech.towercraft.managers.net.LoadingManager;
	import com.gerantech.towercraft.models.AppModel;
	import com.gt.towers.Game;
	import com.gt.towers.constants.ResourceType;
	
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import feathers.controls.LayoutGroup;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalAlign;
	
	public class Toolbar extends LayoutGroup
	{
		private var pointIndicator:Indicator;
		private var c0Indicator:Indicator;
		private var c1Indicator:Indicator;
		
		private var intervalID:uint;
		
		override protected function initialize():void
		{
			super.initialize();

			var hlayout:HorizontalLayout = new HorizontalLayout();
			hlayout.gap = 96 * AppModel.instance.scale;
			hlayout.padding = 48 * AppModel.instance.scale;
			hlayout.verticalAlign = VerticalAlign.MIDDLE;
			layout = hlayout;
			
			pointIndicator = new Indicator("ltr", ResourceType.POINT, false, false);
			addChild(pointIndicator);
			
			addChild(new Spacer(false));
			
			c0Indicator = new Indicator("rtl", ResourceType.CURRENCY_SOFT);
			addChild(c0Indicator);
			
			c1Indicator = new Indicator("rtl", ResourceType.CURRENCY_HARD);
			addChild(c1Indicator);
			
			intervalID = setInterval(updateIndicators, 100);
		}

		
		private function updateIndicators():void
		{
			if(AppModel.instance.loadingManager.state < LoadingManager.STATE_LOADED)
				return;
			
			pointIndicator.setData(0, Game.get_instance().get_player().get_point(), NaN);
			c0Indicator.setData(0, Game.get_instance().get_player().get_money(), NaN);
			c1Indicator.setData(0, Game.get_instance().get_player().get_gem(), NaN);
		}		
		
		override public function dispose():void
		{
			clearInterval(intervalID);
			super.dispose();
		}
		
		
	}
}