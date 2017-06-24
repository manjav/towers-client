package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.controls.buttons.Indicator;
	import com.gerantech.towercraft.managers.net.LoadingManager;
	import com.gerantech.towercraft.models.AppModel;
	import com.gt.towers.Game;
	import com.gt.towers.constants.ResourceType;
	
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import feathers.controls.LayoutGroup;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.events.Event;
	
	public class Toolbar extends LayoutGroup
	{
		private var pointIndicator:Indicator;
		private var softIndicator:Indicator;
		private var hardIndicator:Indicator;
		
		private var intervalID:uint;
		
		override protected function initialize():void
		{
			super.initialize();

			height = 120 * AppModel.instance.scale;
			var padding:Number = 48 * AppModel.instance.scale;
			/*var hlayout:HorizontalLayout = new HorizontalLayout();
			hlayout.gap = 96 * AppModel.instance.scale;
			hlayout.padding = 48 * AppModel.instance.scale;
			hlayout.verticalAlign = VerticalAlign.MIDDLE;
			layout = hlayout;*/
			layout = new AnchorLayout();
			
			pointIndicator = new Indicator("ltr", ResourceType.POINT, false, false);
			pointIndicator.layoutData = new AnchorLayoutData(NaN, NaN, NaN, padding, NaN, 0);
			addChild(pointIndicator);
			
			//addChild(new Spacer(false));
			
			softIndicator = new Indicator("rtl", ResourceType.CURRENCY_SOFT);
			softIndicator.addEventListener(Event.TRIGGERED, indicators_triggerredHandler);
			softIndicator.layoutData = new AnchorLayoutData(NaN, padding, NaN, NaN, NaN, 0);
			addChild(softIndicator);
			
			hardIndicator = new Indicator("rtl", ResourceType.CURRENCY_HARD);
			hardIndicator.addEventListener(Event.TRIGGERED, indicators_triggerredHandler);
			hardIndicator.layoutData = new AnchorLayoutData(NaN, padding*3+softIndicator.width, NaN, NaN, NaN, 0);
			addChild(hardIndicator);
			
			intervalID = setInterval(updateIndicators, 100);
		}
		
		private function indicators_triggerredHandler(event:Event):void
		{
			dispatchEventWith(Event.TRIGGERED);
		}
		
		private function updateIndicators():void
		{
			if(AppModel.instance.loadingManager.state < LoadingManager.STATE_LOADED)
				return;
			
			pointIndicator.setData(0, Game.get_instance().get_player().get_point(), NaN);
			softIndicator.setData(0, Game.get_instance().get_player().get_softs(), NaN);
			hardIndicator.setData(0, Game.get_instance().get_player().get_hards(), NaN);
		}		
		
		override public function dispose():void
		{
			clearInterval(intervalID);
			super.dispose();
		}
		
		
	}
}