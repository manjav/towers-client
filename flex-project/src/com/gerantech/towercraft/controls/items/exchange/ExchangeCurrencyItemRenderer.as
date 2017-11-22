package com.gerantech.towercraft.controls.items.exchange
{
	import com.gerantech.towercraft.controls.buttons.ExchangeButton;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.controls.texts.ShadowLabel;
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.constants.ResourceType;
	
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayoutData;

	public class ExchangeCurrencyItemRenderer extends ExchangeBaseItemRenderer
	{
		private var iconDisplay:ImageLoader;
		private var titleDisplay:ShadowLabel;
		private var countDisplay:ShadowLabel;
		private var buttonDisplay:ExchangeButton;

		
		override protected function commitData():void
		{
			super.commitData();
			
			iconDisplay = new ImageLoader();
			iconDisplay.source = Assets.getTexture("currency-" + exchange.type, "gui");
			iconDisplay.layoutData = new AnchorLayoutData(0, NaN, NaN, NaN, 0);
			iconDisplay.width = 320 * appModel.scale;
			addChild(iconDisplay);
			
			titleDisplay = new ShadowLabel(loc("exchange_title_"+exchange.type));
			titleDisplay.layoutData = new AnchorLayoutData(padding, NaN, NaN, NaN, 0);
			addChild(titleDisplay);
			
			countDisplay = new ShadowLabel(String(exchange.outcomes.values()[0]));
			countDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding*5, NaN, 0);
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