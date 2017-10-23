	package com.gerantech.towercraft.controls.items.exchange
{
	import com.gerantech.towercraft.controls.buttons.ExchangeButton;
	import com.gerantech.towercraft.controls.overlays.OpenChestOverlay;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.utils.StrUtils;
	import com.gt.towers.constants.ExchangeType;
	import com.gt.towers.constants.ResourceType;
	import com.gt.towers.exchanges.ExchangeItem;
	
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import dragonBones.events.EventObject;
	import dragonBones.starling.StarlingArmatureDisplay;
	import dragonBones.starling.StarlingEvent;
	
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.layout.AnchorLayoutData;
	import feathers.text.BitmapFontTextFormat;
	
	import starling.events.Event;
	
	public class ExchangeChestBattleItemRenderer extends ExchangeBaseItemRenderer
	{
		private var labelDisplay:RTLLabel;
		private var timeDisplay:BitmapFontTextRenderer;

		private var buttonDisplay:ExchangeButton;
		private var chestArmature:StarlingArmatureDisplay;
		private var armatorTimeoutId:int = -1;
		private var _state:int = -2;
		
		override protected function commitData():void
		{
			if( index < 0 || _data == null )
				return;
			super.commitData();
			if(firstCommit)
				firstCommit = false;
			
			if( buttonDisplay == null )
			{
				buttonDisplay = new ExchangeButton();
				buttonDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding, NaN, 0);
				buttonDisplay.height = 96 * appModel.scale;
			}
			if( chestArmature == null )
			{
				chestArmature = OpenChestOverlay.factory.buildArmatureDisplay("chest-"+exchange.outcome);
				chestArmature.scale = appModel.scale;
				chestArmature.x = width * 0.5;
				chestArmature.y = height * 0.6;
				chestArmature.animation.gotoAndStopByProgress("fall", 1);
			}
			updateElements();
			addChild(chestArmature);
			addChild(buttonDisplay);
		}
		
		private function chestArmature_completeHandler(event:StarlingEvent):void
		{
			//updateArmature(state, event.eventObject.animationState.name == "fall");
		}
		
		private function timeManager_changeHandler(event:Event):void
		{
			updateElements();
			updateCounter();
		}
		private function updateElements():void
		{
			if(	_state == exchange.getState(timeManager.now))
				return;
			_state = exchange.getState(timeManager.now);

			timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
			if( timeDisplay != null )
				timeDisplay.visible = _state == ExchangeItem.CHEST_STATE_BUSY;
			if( _state == ExchangeItem.CHEST_STATE_WAIT )
			{
				buttonDisplay.count = ExchangeType.getKeyRequierement(exchange.outcome);
				buttonDisplay.type = ResourceType.KEY;
			}
			else if( _state == ExchangeItem.CHEST_STATE_BUSY )
			{
				buttonDisplay.style = "danger";
				updateCounter();
				timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
				buttonDisplay.type = ResourceType.CURRENCY_HARD;
			}
			else if( _state == ExchangeItem.CHEST_STATE_READY )
			{
				buttonDisplay.count = -1;
				buttonDisplay.type = -1;
			}
			//updateArmature();
		}
		
		private function updateCounter():void
		{
			if( exchange.getState(timeManager.now) != ExchangeItem.CHEST_STATE_BUSY )
				return;
			if( timeDisplay == null )
			{
				timeDisplay = new BitmapFontTextRenderer();//imageDisplay.width, imageDisplay.width/2, "");
				timeDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 54*appModel.scale, 0xFFFFFF, "center")
				timeDisplay.layoutData = new AnchorLayoutData(padding, NaN, NaN, NaN, 0);
			}
			var t:uint = uint(exchange.expiredAt - timeManager.now);//trace(index, t)
			timeDisplay.text = "< "+StrUtils.toTimeFormat(t);
			buttonDisplay.count = exchanger.timeToHard(t);			
			addChild(timeDisplay);	
		}
		
		/*private function updateArmature():void
		{
			if( chestArmature == null)
				return;

			if(state == 1)
			{
				clearTimeout(armatorTimeoutId);
				armatorTimeoutId = -1;
			}
			else if( state == 0 && armatorTimeoutId == -1 )
			{
				armatorTimeoutId = setTimeout(animateWaitArmature, immediatly?0:(Math.random()*3000+10000));
			}			
		}
		private function animateWaitArmature():void
		{
			chestArmature.animation.gotoAndPlayByTime("wait", 0, 1);			
			armatorTimeoutId = -1;
		}*/
		
		override public function dispose():void
		{
			timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
			if( chestArmature )
				chestArmature.removeEventListener(EventObject.COMPLETE, chestArmature_completeHandler);
			clearTimeout(armatorTimeoutId);
			armatorTimeoutId = -1;
			super.dispose();
		}
	}
}