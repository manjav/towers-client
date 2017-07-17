package com.gerantech.towercraft.controls.items.exchange
{
	import com.gerantech.towercraft.controls.BuildingCard;
	import com.gerantech.towercraft.controls.buttons.ExchangeButton;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.managers.TimeManager;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.utils.StrUtils;
	import com.gt.towers.utils.maps.IntIntMap;
	
	import flash.desktop.Icon;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.layout.AnchorLayoutData;
	import feathers.text.BitmapFontTextFormat;
	
	import starling.events.Event;

	public class SpecialExchangeItemRenderer extends BaseExchangeItemRenderer
	{
		private var labelDisplay:RTLLabel;
		private var buttonDisplay:ExchangeButton;
		private var timeDisplay:BitmapFontTextRenderer;
		private var iconDisplay:BuildingCard;

		
		override protected function initialize():void
		{
			super.initialize();

			/*labelDisplay = new RTLLabel("");
			labelDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN);
			addChild(labelDisplay);*/
			
			iconDisplay = new BuildingCard();
			iconDisplay.showSlider = false;
			iconDisplay.width = 280 * appModel.scale;
			iconDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?NaN:padding, padding, appModel.isLTR?padding:NaN);
			addChild(iconDisplay);
			
			buttonDisplay = new ExchangeButton();
			buttonDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?padding:NaN, padding, appModel.isLTR?NaN:padding);
			buttonDisplay.width = 260 * appModel.scale;
			buttonDisplay.height = 120 * appModel.scale;
			addChild(buttonDisplay);
			
			timeDisplay = new BitmapFontTextRenderer();//imageDisplay.width, imageDisplay.width/2, "");
			timeDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 54*appModel.scale, 0xFFFFFF, "center")
			timeDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding);
			addChild(timeDisplay);	
			
			timeDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding);
			addChild(timeDisplay);

		}
		
		override protected function commitData():void
		{
			if(firstCommit)
				TimeManager.instance.addEventListener(Event.CHANGE, timeManager_changeHandler);
			
			super.commitData();
			//trace(exchange.type, exchange.outcomes.keys().length)
			//labelDisplay.text = loc("building_title_" + exchange.outcomes.keys()[0]);
			iconDisplay.type = exchange.outcomes.keys()[0];
			var reqs:IntIntMap = exchanger.getSpecialRequierments(exchange);
			buttonDisplay.price = reqs.values()[0];
			buttonDisplay.type = reqs.keys()[0];
			timeDisplay.text = StrUtils.uintToTime(uint(exchange.expiredAt - TimeManager.instance.now));
		}
		
		private function timeManager_changeHandler():void
		{
			timeDisplay.text = "< "+StrUtils.toTimeFormat(exchange.expiredAt - TimeManager.instance.now);//uintToTime(exchange.expiredAt - TimeManager.instance.now);
		}		
	
	}
}