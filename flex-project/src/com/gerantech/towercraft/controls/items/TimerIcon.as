package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.LayoutGroup;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Image;

	public class TimerIcon extends LayoutGroup
	{
		private var needle:Image;
		private var _time:Number = 0;

		private var background:ImageLoader;
		private var _deg:Number = 0.47;
		private var intervalId:uint;
		public function TimerIcon()
		{
		}
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			
			background =  new ImageLoader();
			background.source = Assets.getTexture("timer", "gui");
			background.layoutData = new AnchorLayoutData(0, 0, 0 , 0);
			addChild(background);
			
			needle = new Image(Assets.getTexture("timer-needle", "gui"));
			needle.pivotX = needle.width/2;
			needle.pivotY = needle.height/2;
			needle.height = 64*AppModel.instance.scale;
			needle.scaleX = needle.scaleY;
			//needle.rotation = Math.PI

			//needle.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
			//needle.width = background.originalSourceHeight/height;
			addChild(needle);
			play()
		}
		
		public function play():void
		{
			rotate();
			intervalId = setInterval(rotate, 1000);
		}
		
		public function stop():void
		{
			time = _deg = 0.47;
			clearInterval(intervalId);
			Starling.juggler.removeTweens(this);
		}
		
		public function rotate():void
		{
			_deg += Math.PI*0.5;
			Starling.juggler.tween(this, 0.5, {time:_deg, transition:Transitions.EASE_OUT_ELASTIC});
		}
		
		public function get time():Number
		{
			return _time;
		}
		public function set time(value:Number):void
		{
			if(_time == value)
				return;
			_time = value;
			needle.rotation = _time;
			needle.x = width/2;
			needle.y = height/2;
		}
		
		override public function dispose():void
		{
			stop();
			super.dispose();
		}
		
		
		
	}
}