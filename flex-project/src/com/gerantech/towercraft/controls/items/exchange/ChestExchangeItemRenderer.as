package com.gerantech.towercraft.controls.items.exchange
{
	import com.gerantech.towercraft.controls.buttons.ExchangeButton;
	import com.gerantech.towercraft.controls.headers.ExchangeHeader;
	import com.gerantech.towercraft.controls.overlays.OpenChestOverlay;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.utils.StrUtils;
	import com.gt.towers.constants.ResourceType;
	
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import dragonBones.events.EventObject;
	import dragonBones.objects.DragonBonesData;
	import dragonBones.starling.StarlingArmatureDisplay;
	import dragonBones.starling.StarlingEvent;
	import dragonBones.starling.StarlingFactory;
	
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.layout.AnchorLayoutData;
	import feathers.text.BitmapFontTextFormat;
	
	import starling.events.Event;
	
	public class ChestExchangeItemRenderer extends BaseExchangeItemRenderer
	{
		private var labelDisplay:RTLLabel;
		private var timeDisplay:BitmapFontTextRenderer;
		private var header:ExchangeHeader;

		private var buttonDisplay:ExchangeButton;
		private var chestArmature:StarlingArmatureDisplay;
		private var armatorTimeoutId:int = -1;
		private var state:int = -1;
		
		private static var factory:StarlingFactory;
		private static var dragonBonesData:DragonBonesData;
		
		private function createFactory():void
		{
			if(factory != null)
				return;
			factory = new StarlingFactory();
			dragonBonesData = factory.parseDragonBonesData( JSON.parse(new OpenChestOverlay.skeletonLightClass()) );
			factory.parseTextureAtlasData( JSON.parse(new OpenChestOverlay.atlasDataClass()), new OpenChestOverlay.atlasImageClass() );
		}
		
		
		override protected function commitData():void
		{
			if( index < 0 )
				return;
			super.commitData();
			if(firstCommit)
			{
				timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
				firstCommit = false;
			}
			
			header = new ExchangeHeader("chest-banner", new Rectangle(78, 0, 4, 74), 40*appModel.scale); 
			header.label = loc("exchange_title_"+exchange.type);
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
			
			updateElements(exchange.expiredAt > timeManager.now ? 1 : 0);
			setTimeout(AddArmature, (factory==null?1200:100)+index*300);
		}
		
		private function AddArmature():void
		{
			createFactory();
			
			chestArmature = factory.buildArmatureDisplay(dragonBonesData.armatureNames[(exchange.type%10)-1]);
			chestArmature.x = -540*appModel.scale/2+width/2-padding;
			chestArmature.y = -940*appModel.scale/2+height*0.3;
			chestArmature.scale = appModel.scale/2;
			chestArmature.addEventListener(EventObject.COMPLETE, chestArmature_completeHandler);
			chestArmature.animation.gotoAndPlayByTime("fall",0, 1);
			addChildAt(chestArmature, 1);		
		}
		private function chestArmature_completeHandler(event:StarlingEvent):void
		{
			chestArmature.removeEventListener(EventObject.COMPLETE, chestArmature_completeHandler);
			if( event.eventObject.animationState.name == "fall")
				updateArmature(state, true);
		}
		
		private function timeManager_changeHandler():void
		{
			updateElements(exchange.expiredAt > timeManager.now ? 1 : 0);
		}
		private function updateElements(state:int):void
		{
			if(	this.state == state)
				return;
			
			this.state = state;
			timeDisplay.visible = state==1;
			if( state==1 )
			{
				var t:uint = uint(exchange.expiredAt - timeManager.now);
				timeDisplay.text = "< "+StrUtils.toTimeFormat(t);//uintToTime(t);
				buttonDisplay.count = exchanger.timeToKey(t);
				buttonDisplay.type = ResourceType.KEY;
			}
			else if( state==0)
			{
				buttonDisplay.count = -1;
				buttonDisplay.type = -1;

			}
			updateArmature(state);
		}
		
		private function updateArmature(state:int, force:Boolean=false):void
		{
			if( !chestArmature)
				return;
			
			if(state==1)
			{
				clearTimeout(armatorTimeoutId);
				armatorTimeoutId = -1;
			}
			else if( state==0 && armatorTimeoutId == -1 )
			{
				armatorTimeoutId = setTimeout(chestArmature.animation.gotoAndPlayByTime, force?0:(Math.random()*3000+10000), "wait", 0, 1);
			}			
		}
		
		override public function dispose():void
		{
			timeManager.removeEventListeners(Event.CHANGE);
			if( chestArmature )
				chestArmature.removeEventListener(EventObject.COMPLETE, chestArmature_completeHandler);
			clearTimeout(armatorTimeoutId);
			armatorTimeoutId = -1;
			super.dispose();
		}
	}
}