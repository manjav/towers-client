package com.gerantech.towercraft.controls.items.exchange
{
	import com.gerantech.towercraft.controls.ExchangeButton;
	import com.gerantech.towercraft.controls.ExchangeHeader;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.managers.TimeManager;
	import com.gerantech.towercraft.utils.StrUtils;
	import com.gt.towers.constants.ResourceType;
	import com.gt.towers.exchanges.Exchanger;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayoutData;
	
	import starling.events.Event;
	
	public class ChestExchangeItemRenderer extends BaseExchangeItemRenderer
	{
		private var iconDisplay:ImageLoader;
		private var labelDisplay:RTLLabel;
		private var timeDisplay:RTLLabel;
		private var header:ExchangeHeader;
		private var inWiating:Boolean;

		private var buttonDisplay:ExchangeButton;
		
		override protected function initialize():void
		{
			super.initialize();

			iconDisplay = new ImageLoader();
			iconDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding*6, NaN, 0);
			iconDisplay.width = 220 * appModel.scale;
			addChild(iconDisplay);
			
			header = new ExchangeHeader("chest-banner", new Rectangle(78, 0, 4, 74), 36*appModel.scale); 
			header.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
			header.height = 110*appModel.scale;
			addChild(header);
			
			timeDisplay = new RTLLabel("");
			timeDisplay.layoutData = new AnchorLayoutData(padding*4, NaN, NaN, NaN, 0);
			addChild(timeDisplay);	
			
			buttonDisplay = new ExchangeButton();
			buttonDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding, NaN, 0);
			buttonDisplay.height = 96*appModel.scale;
			addChild(buttonDisplay);
		}

		override protected function commitData():void
		{
			if(firstCommit )
			{
				inWiating = game.exchanger.items.get(_data as int).expiredAt>TimeManager.instance.now;
				TimeManager.instance.addEventListener(Event.CHANGE, timeManager_changeHandler);
			}
			
			super.commitData();
			
			iconDisplay.source = appModel.assetsManager.getTexture("chest-" + exchange.type);
			header.label = loc("exchange_title_"+exchange.type);
		}
		
		private function timeManager_changeHandler():void
		{
			inWiating = exchange.expiredAt > TimeManager.instance.now;
			updateTexts();
		}
		
		private function updateTexts():void
		{
			timeDisplay.visible = inWiating;
			if(inWiating)
			{
				var t:uint = uint(exchange.expiredAt - TimeManager.instance.now);
				timeDisplay.text = StrUtils.uintToTime(t);
				buttonDisplay.price = exchanger.timeToHard(t);
				buttonDisplay.type = ResourceType.CURRENCY_HARD;
			}
			else
			{
				buttonDisplay.price = -1;
				buttonDisplay.type = -1;
			}			
		}
	}
}