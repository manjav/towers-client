package com.gerantech.towercraft.controls.items.exchange
{
	import com.gerantech.towercraft.controls.BuildingCard;
	import com.gerantech.towercraft.controls.buttons.ExchangeButton;
	import com.gerantech.towercraft.controls.sliders.BuildingSlider;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.managers.TimeManager;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.utils.StrUtils;
	import com.gt.towers.buildings.Building;
	import com.gt.towers.utils.maps.IntIntMap;
	import com.hurlant.crypto.symmetric.ECBMode;
	
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayoutData;
	import feathers.text.BitmapFontTextFormat;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.events.Event;

	public class SpecialExchangeItemRenderer extends BaseExchangeItemRenderer
	{
		private var nameDisplay:RTLLabel;
		private var nameShadowDisplay:RTLLabel;
		private var timeDisplay:RTLLabel;
		private var iconDisplay:BuildingCard;
		private var iconAnimation:BuildingCard;
		private var slider:BuildingSlider;
		private var buttonDisplay:ExchangeButton;

		override protected function initialize():void
		{
			super.initialize();

			nameShadowDisplay = new RTLLabel("", 0);
			nameShadowDisplay.layoutData = new AnchorLayoutData(padding+padding/6, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN);
			addChild(nameShadowDisplay);
			
			nameDisplay = new RTLLabel("");
			nameDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN);
			addChild(nameDisplay);
			
			slider = new BuildingSlider();
			slider.layoutData = new AnchorLayoutData(padding*5, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN);
			slider.width = padding * 10;
			slider.height = padding * 2.4;
			addChild(slider);
			
			// empty rear pages ....
			function addEmptyPage(hPadding:Number):void
			{
				var page:ImageLoader = new ImageLoader();
				page.source = Assets.getTexture("building-button", "skin");
				page.width = 280 * appModel.scale;
				page.layoutData = new AnchorLayoutData(padding, appModel.isLTR?hPadding:NaN, padding, appModel.isLTR?NaN:hPadding);
				page.scale9Grid = new Rectangle(10, 10, 56, 37);
				addChild(page);
			}
			addEmptyPage( padding );
			addEmptyPage( padding*1.5 );
		
			// icon
			iconDisplay = new BuildingCard();
			iconDisplay.showLevel = false;
			iconDisplay.showSlider = false;
			iconDisplay.width = 280 * appModel.scale;
			iconDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?padding*2:NaN, padding, appModel.isLTR?NaN:padding*2);
			addChild(iconDisplay);
			
			iconAnimation = new BuildingCard();
			iconAnimation.showLevel = false;
			iconAnimation.showSlider = false;

			
			buttonDisplay = new ExchangeButton();
			buttonDisplay.addEventListener(Event.TRIGGERED, buttonDisplay_triggeredHandler);
			buttonDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding, padding, appModel.isLTR?padding:NaN);
			buttonDisplay.width = 260 * appModel.scale;
			buttonDisplay.height = 120 * appModel.scale;
			addChild(buttonDisplay);
			
			/*timeDisplay = new BitmapFontTextRenderer();//imageDisplay.width, imageDisplay.width/2, "");
			timeDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 54*appModel.scale, 0xFFFFFF, appModel.isLTR?"right":"left", -20*appModel.scale)*/
			timeDisplay = new RTLLabel("", 1, appModel.isLTR?"right":"left", null, false, null, 0.8);
			timeDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?iconDisplay.width+padding*3:NaN, padding, appModel.isLTR?NaN:padding*3+iconDisplay.width);
			addChild(timeDisplay);	
		}
		
		private function buttonDisplay_triggeredHandler(event:Event):void
		{
			if ( !player.has(exchange.requirements) )
			{
				appModel.navigator.addLog(loc("log_not_enough", [loc("resource_title_"+exchange.requirements.keys()[0])]));
				return;
			}
			
			TimeManager.instance.removeEventListener(Event.CHANGE, timeManager_changeHandler);
			
			buttonDisplay.removeEventListener(Event.TRIGGERED, buttonDisplay_triggeredHandler);
			iconAnimation.x = iconDisplay.x;
			iconAnimation.y = iconDisplay.y;
			iconAnimation.width = iconDisplay.width;
			iconAnimation.height = iconDisplay.height;
			addChild(iconAnimation);
			
			iconAnimation.layoutData = new AnchorLayoutData();
			Starling.juggler.tween(iconAnimation, 0.3, {x:iconDisplay.x+32*appModel.scale, y:iconDisplay.y-64*appModel.scale, width:iconDisplay.width*1.2, height:iconDisplay.height*1.2, transition:Transitions.EASE_OUT_BACK});
			Starling.juggler.tween(iconAnimation, 0.3, {delay:0.35, x:slider.x, y:slider.y, width:slider.width, height:slider.height, transition:Transitions.EASE_IN, onComplete:cardAchieved});
			
			timeDisplay.scale = 1.2;
			timeDisplay.text = loc( "exchange_special_availabled", [(49-exchange.numExchanges), StrUtils.toTimeFormat(uint(exchange.expiredAt - TimeManager.instance.now))] );
			Starling.juggler.tween(timeDisplay, 0.2, {scale:1, transition:Transitions.EASE_OUT_BACK});
			function cardAchieved():void
			{
				iconAnimation.removeFromParent();
				slider.scale = 1.2;
				Starling.juggler.tween(slider, 0.2, {scale:1, transition:Transitions.EASE_OUT_BACK});
				buttonDisplay.addEventListener(Event.TRIGGERED, buttonDisplay_triggeredHandler);
				setTimeout(_owner.dispatchEventWith, 100, FeathersEventType.END_INTERACTION, false, exchange);
			}
		}
		
		override protected function commitData():void
		{
			if(firstCommit)
				TimeManager.instance.addEventListener(Event.CHANGE, timeManager_changeHandler);
			
			super.commitData();
			
			var building:Building = player.buildings.get(exchange.outcomes.keys()[0]);
			exchange.requirements = exchanger.getSpecialRequierments(exchange);

			//trace(exchange.type, exchange.outcomes.keys().length)
			//labelDisplay.text = loc("building_title_" + exchange.outcomes.keys()[0]);
			nameShadowDisplay.text = nameDisplay.text = loc("building_title_" + building.type);
			iconDisplay.type = building.type;
			iconAnimation.type = building.type;
			
			buttonDisplay.count = exchange.requirements.values()[0];
			buttonDisplay.type = exchange.requirements.keys()[0];
			
			slider.maximum = building.get_upgradeCards();
			slider.value = player.resources.get(building.type);
			timeDisplay.text = loc( "exchange_special_availabled", [(50-exchange.numExchanges), StrUtils.toTimeFormat(uint(exchange.expiredAt - TimeManager.instance.now))] );
		}
		
		private function timeManager_changeHandler():void
		{
			timeDisplay.text = loc( "exchange_special_availabled", [(50-exchange.numExchanges), StrUtils.toTimeFormat(uint(exchange.expiredAt - TimeManager.instance.now))] );
		}
		
		public function showAchieveAnimation():void
		{
			// TODO Auto Generated method stub
			
		}		
		
	
		
	}
}