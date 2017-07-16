package com.gerantech.towercraft.controls.items.exchange
{
	import com.gerantech.towercraft.controls.ExchangeButton;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gt.towers.constants.ResourceType;
	
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayoutData;

	public class CurrencyExchangeItemRenderer extends BaseExchangeItemRenderer
	{
		private var iconDisplay:ImageLoader;
		private var titleDisplay:RTLLabel;
		private var countDisplay:RTLLabel;
		private var buttonDisplay:ExchangeButton;
		
		override protected function initialize():void
		{
			super.initialize();
			
			titleDisplay = new RTLLabel("");
			titleDisplay.layoutData = new AnchorLayoutData(padding, NaN, NaN, NaN, 0);
			addChild(titleDisplay);
			
			iconDisplay = new ImageLoader();
			iconDisplay.layoutData = new AnchorLayoutData(padding*4, NaN, NaN, NaN, 0);
			iconDisplay.width = 180 * appModel.scale;
			addChild(iconDisplay);
			
			countDisplay = new RTLLabel("");
			countDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding*6, NaN, 0);
			addChild(countDisplay);	
			
			buttonDisplay = new ExchangeButton();
			buttonDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding, NaN, 0);
			buttonDisplay.height = 96*appModel.scale;
			addChild(buttonDisplay);
		}
		
		override protected function commitData():void
		{
			super.commitData();
			
			titleDisplay.text = loc("exchange_title_"+exchange.type);
			iconDisplay.source = appModel.assetsManager.getTexture("currency-" + exchange.type);
			countDisplay.text = String(exchange.outcomes.values()[0]);

			if( exchange.requirements.keys()[0] == ResourceType.CURRENCY_REAL )
				buttonDisplay.currency = "ت";
			buttonDisplay.price = exchange.requirements.values()[0];
			buttonDisplay.type = exchange.requirements.keys()[0];
		}

	}
}