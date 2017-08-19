package com.gerantech.towercraft.views
{
	import com.gerantech.towercraft.models.Assets;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.LayoutGroup;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	public class HealthBar extends LayoutGroup
	{
		private static const SCALE_RECT:Rectangle = new Rectangle(3, 4, 2, 3);
		private var _value:Number = 0;
		
		private var initValue:Number;
		private var maxValue:Number;
		private var troopType:int;
		
		private var fillDisplay:ImageLoader;
		private var backroundDisplay:ImageLoader;
		
		public function HealthBar(troopType:int, initValue:Number = 0, initMax:Number = 1)
		{
			super();
			this.pivotX = this.width/2;
			this.width = 48;
			this.troopType = troopType;
			this.initValue = initValue;
			this.maxValue = initMax;
		}

		override protected function initialize():void
		{
			super.initialize();
			
			layout = new AnchorLayout();
			
			backroundDisplay = new ImageLoader();
			backroundDisplay.scale9Grid = SCALE_RECT;
			backroundDisplay.source = Assets.getTexture("healthbar-bg");
			backroundDisplay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
			addChild(backroundDisplay);
			
			fillDisplay = new ImageLoader();
			fillDisplay.scale9Grid = SCALE_RECT;
			fillDisplay.source = Assets.getTexture("healthbar-"+troopType);
			fillDisplay.layoutData = new AnchorLayoutData(0, NaN, 0, 0);
			addChild(fillDisplay);
			
			value = initValue;
		}
		
		
		public function get value():Number
		{
			return _value;
		}
		public function set value(v:Number):void
		{
			if( _value == v )
				return;
			//trace(v,maxValue)
			_value = v//Math.pow(v, 6);
			fillDisplay.width =  width*((maxValue-v)/maxValue);
		}
	}
}