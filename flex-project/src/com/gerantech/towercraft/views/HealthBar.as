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
		private static const SCALE_RECT:Rectangle = new Rectangle(2, 4, 2, 3);
		
		private var _value:Number = 0;
		private var _troopType:int = -2;
		private var maximum:Number;
		
		private var fillDisplay:ImageLoader;
		private var backroundDisplay:ImageLoader;
		
		public function HealthBar(troopType:int, initValue:Number = 0, initMax:Number = 1)
		{
			super();
			touchable = false;
			this.pivotX = this.width/2;
			this.width = 48;
			this.troopType = troopType;
			this.value = initValue;
			this.maximum = initMax;
		}

		override protected function initialize():void
		{
			super.initialize();
			
			layout = new AnchorLayout();
			
			backroundDisplay = new ImageLoader();
			backroundDisplay.scale9Grid = SCALE_RECT;
			backroundDisplay.source = Assets.getTexture("healthbar-bg-"+_troopType);
			backroundDisplay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
			addChild(backroundDisplay);
			
			fillDisplay = new ImageLoader();
			fillDisplay.scale9Grid = SCALE_RECT;
			fillDisplay.source = Assets.getTexture("healthbar-fill-"+_troopType);
			fillDisplay.layoutData = new AnchorLayoutData(0, NaN, 0, 0);
			addChild(fillDisplay);
		}
		
		
		public function get value():Number
		{
			return _value;
		}
		public function set value(v:Number):void
		{
			if( _value == v || v > maximum )
				return;
			//trace(v,maxValue)
			_value = v//Math.pow(v, 6);
			if( fillDisplay )
				fillDisplay.width =  width*(v/maximum);
		}
		
		public function get troopType():int
		{
			return _troopType;
		}
		public function set troopType(value:int):void
		{
			if( _troopType == value )
				return;
			_troopType = value;
			
			if( backroundDisplay )
				backroundDisplay.source = Assets.getTexture("healthbar-bg-"+_troopType);
			if( fillDisplay )
				fillDisplay.source = Assets.getTexture("healthbar-fill-"+_troopType);

		}
	}
}