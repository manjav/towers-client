package com.gerantech.towercraft.controls.items.exchange
{
	import com.gerantech.towercraft.controls.buttons.ExchangeButton;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gt.towers.constants.ResourceType;
	
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayoutData;

	public class ExchangeCurrencyItemRenderer extends ExchangeBaseItemRenderer
	{
		private var iconDisplay:ImageLoader;
		private var titleDisplay:RTLLabel;
		private var countDisplay:RTLLabel;
		private var buttonDisplay:ExchangeButton;

		
		override protected function commitData():void
		{
			super.commitData();
			
			titleDisplay = new RTLLabel(loc("exchange_title_"+exchange.type));
			titleDisplay.layoutData = new AnchorLayoutData(padding, NaN, NaN, NaN, 0);
			addChild(titleDisplay);
			
			iconDisplay = new ImageLoader();
			iconDisplay.source = appModel.assets.getTexture("currency-" + exchange.type);
			iconDisplay.layoutData = new AnchorLayoutData(padding*4, NaN, NaN, NaN, 0);
			iconDisplay.width = 180 * appModel.scale;
			addChild(iconDisplay);
			
			countDisplay = new RTLLabel(String(exchange.outcomes.values()[0]));
			countDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding*6, NaN, 0);
			addChild(countDisplay);	
			
			buttonDisplay = new ExchangeButton();
			buttonDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding, NaN, 0);
			buttonDisplay.height = 96*appModel.scale;
			if( exchange.requirements.keys()[0] == ResourceType.CURRENCY_REAL )
				buttonDisplay.currency = "ت";
			buttonDisplay.count = exchange.requirements.values()[0];
			buttonDisplay.type = exchange.requirements.keys()[0];
			addChild(buttonDisplay);
		}

	}
}