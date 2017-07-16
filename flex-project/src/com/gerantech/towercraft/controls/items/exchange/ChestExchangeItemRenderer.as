package com.gerantech.towercraft.controls.items.exchange
{
	import com.gerantech.towercraft.controls.ExchangeButton;
	import com.gerantech.towercraft.controls.ExchangeHeader;
	import com.gerantech.towercraft.controls.overlays.OpenChestOverlay;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.managers.TimeManager;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.utils.StrUtils;
	import com.gt.towers.constants.ResourceType;
	import com.gt.towers.exchanges.Exchanger;
	
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import dragonBones.events.EventObject;
	import dragonBones.starling.StarlingArmatureDisplay;
	import dragonBones.starling.StarlingEvent;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.layout.AnchorLayoutData;
	import feathers.text.BitmapFontTextFormat;
	
	import starling.events.Event;
	
	public class ChestExchangeItemRenderer extends BaseExchangeItemRenderer
	{
		//private var iconDisplay:ImageLoader;
		private var labelDisplay:RTLLabel;
		private var timeDisplay:BitmapFontTextRenderer;
		private var header:ExchangeHeader;
		private var inWiating:Boolean;

		private var buttonDisplay:ExchangeButton;
		private var chestArmature:StarlingArmatureDisplay;
		private var armatorTimeoutId:int = -1;
		
		override protected function initialize():void
		{
			super.initialize();

			OpenChestOverlay.createFactory();

			header = new ExchangeHeader("chest-banner", new Rectangle(78, 0, 4, 74), 40*appModel.scale); 
			header.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
			header.height = 110*appModel.scale;
			addChild(header);
			
			timeDisplay = new BitmapFontTextRenderer();//imageDisplay.width, imageDisplay.width/2, "");
			timeDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 54*appModel.scale, 0xFFFFFF, "center")
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
			
			clearTimeout(armatorTimeoutId);
			armatorTimeoutId = -1;

			if( chestArmature != null )
				chestArmature.removeFromParent();
			chestArmature = OpenChestOverlay.factory. buildArmatureDisplay(OpenChestOverlay.dragonBonesData.armatureNames[(exchange.type%10)-1]);
			chestArmature.x = -540*appModel.scale/2+width/2-padding;
			chestArmature.y = -960*appModel.scale/2+height*0.3;
			chestArmature.scale = appModel.scale/2;
			chestArmature.animation.gotoAndStopByFrame("wait", 0);
			addChildAt(chestArmature, 1);
			header.label = loc("exchange_title_"+exchange.type);
		}
		private function timeManager_changeHandler():void
		{
			inWiating = exchange.expiredAt > TimeManager.instance.now;
			updateElements();
		}
		private function updateElements():void
		{
			timeDisplay.visible = inWiating;
			if( inWiating )
			{
				var t:uint = uint(exchange.expiredAt - TimeManager.instance.now);
				timeDisplay.text = "< "+StrUtils.toTimeFormat(t);//uintToTime(t);
				buttonDisplay.price = exchanger.timeToHard(t);
				buttonDisplay.type = ResourceType.CURRENCY_HARD;
				chestArmature.removeEventListener(EventObject.COMPLETE, chestArmature_completeHandler);
				clearTimeout(armatorTimeoutId);
				armatorTimeoutId = -1;
			}
			else
			{
				buttonDisplay.price = -1;
				buttonDisplay.type = -1;
				
				if( armatorTimeoutId == -1 )
				{
					chestArmature.addEventListener(EventObject.COMPLETE, chestArmature_completeHandler);
					armatorTimeoutId = setTimeout(chestArmature.animation.gotoAndPlayByTime, Math.random()*10000, "wait", 0, 1);
				}
			}			
		}
		private function chestArmature_completeHandler(event:StarlingEvent):void
		{
			armatorTimeoutId = setTimeout(chestArmature.animation.gotoAndPlayByTime, Math.random()*3000+10000, "wait", 0, 1);
		}
		
		override public function dispose():void
		{
			TimeManager.instance.removeEventListener(Event.CHANGE, timeManager_changeHandler);
			if( chestArmature != null )
				chestArmature.removeEventListener(EventObject.COMPLETE, chestArmature_completeHandler);
			clearTimeout(armatorTimeoutId);
			armatorTimeoutId = -1;
			super.dispose();
		}
	}
}