package com.gerantech.towercraft.controls.items.exchange
{
	import com.gerantech.towercraft.controls.ExchangeButton;
	import com.gerantech.towercraft.controls.RTLLabel;
	import com.gerantech.towercraft.managers.TimeManager;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.utils.StrUtils;
	
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayoutData;
	
	import starling.events.Event;

	public class SpecialExchangeItemRenderer extends BaseExchangeItemRenderer
	{
		private var labelDisplay:RTLLabel;
		private var iconDisplay:ImageLoader;
		private var buttonDisplay:ExchangeButton;
		private var timeDisplay:RTLLabel;

		
		override protected function initialize():void
		{
			super.initialize();

			labelDisplay = new RTLLabel("");
			labelDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN);
			addChild(labelDisplay);
			
			iconDisplay = new ImageLoader();
			iconDisplay.layoutData = new AnchorLayoutData(padding*4, appModel.isLTR?NaN:padding, padding, appModel.isLTR?padding:NaN);
			addChild(iconDisplay);
			
			buttonDisplay = new ExchangeButton();
			buttonDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?padding:NaN, padding, appModel.isLTR?NaN:padding);
			buttonDisplay.width = 260 * appModel.scale;
			buttonDisplay.height = 120 * appModel.scale;
			addChild(buttonDisplay);
			
			timeDisplay = new RTLLabel("");
			timeDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding);
			addChild(timeDisplay);

		}
		
		override protected function commitData():void
		{
			if(firstCommit)
				TimeManager.instance.addEventListener(Event.CHANGE, timeManager_changeHandler);
			
			super.commitData();
			//trace(exchange.type, exchange.outcomes.keys().length)
			labelDisplay.text = loc("building_title_" + exchange.outcomes.keys()[0]);
			iconDisplay.source = Assets.getTexture("improve-"+exchange.outcomes.keys()[0], "gui");
			buttonDisplay.price = exchange.requirements.values()[0];
			buttonDisplay.type = exchange.requirements.keys()[0];
			timeDisplay.text = StrUtils.uintToTime(uint(exchange.expiredAt - TimeManager.instance.now));
		}
		
		private function timeManager_changeHandler():void
		{
			timeDisplay.text = StrUtils.uintToTime(uint(exchange.expiredAt - TimeManager.instance.now));
		}		
		
		
	}
}