package com.gerantech.towercraft.controls.sliders
{
	import com.gerantech.towercraft.controls.StarCheck;
	import com.gerantech.towercraft.controls.TowersLayout;
	import com.gerantech.towercraft.controls.items.TimerIcon;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.LayoutGroup;
	import feathers.controls.ProgressBar;
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.Direction;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.HorizontalLayout;
	import feathers.text.BitmapFontTextFormat;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.BlendMode;
	
	public class BattleTimerSlider extends TowersLayout
	{
		private var timeoutId:uint;
		private var progressBar:Slider;
		private var iconDisplay:TimerIcon;
		private var stars:Vector.<StarCheck>;
		private var _value:Number = 0;
		
		public function BattleTimerSlider()
		{
			super();
		}

		override protected function initialize():void
		{
			super.initialize();
			
			layout = new AnchorLayout();
			width = 280 * appModel.scale;
			height = 60 * appModel.scale;
		
			progressBar = new Slider();
			progressBar.value = 1;
			progressBar.isEnabled = false;
			progressBar.horizontalAlign = HorizontalAlign.RIGHT;
			progressBar.layoutData = new AnchorLayoutData (0,0,0,0);
			addChild(progressBar)

			iconDisplay = new TimerIcon();
			iconDisplay.height = height * 2;
			iconDisplay.layoutData = new AnchorLayoutData (NaN, -height/2, NaN, NaN, NaN, 0);
			addChild(iconDisplay);
			
			stars = new Vector.<StarCheck>();
			for ( var i:int=0; i<3; i++ )
			{
				var star:StarCheck = new StarCheck();
				star.width = star.height = height * 0.8;
				star.x = i * (width-height)/4 + height*0.4;
				star.y = height * 0.05;
				addChild(star)
				stars.push(star);
			}
			stars.reverse();
		}
		
		public function get value():Number
		{
			return _value;
		}
		public function set value(newValue:Number):void
		{
			if(_value == newValue)
				return;
			
			progressBar.value = _value = Math.max(0, Math.min( newValue, maximum ) );
		}
		
		public function get minimum():Number
		{
			return progressBar.minimum;
		}
		public function set minimum(value:Number):void
		{
			progressBar.minimum = value;
		}
		
		public function get maximum():Number
		{
			return progressBar.maximum;
		}
		public function set maximum(value:Number):void
		{
			progressBar.maximum = value;
		}
		
		private function animateFinished():void
		{
			timeoutId = setTimeout(animateUpgradeDisplay, 2000+Math.random()*1000);
		}
		private function animateUpgradeDisplay():void
		{
			Starling.juggler.tween(iconDisplay, 0.5, {y:-height*0.6, height:height*1.2, transition:Transitions.EASE_OUT_BACK, onComplete:animateFinished});
			iconDisplay.y = -height*1.5;
			iconDisplay.height = height*1.8;
		}		
		override public function dispose():void
		{
			clearTimeout(timeoutId);
			Starling.juggler.removeTweens(iconDisplay);
			super.dispose();
		}
		
		public function enableStars(score:int):void
		{
			for ( var i:int=0; i<stars.length; i++ )
			{
				stars[i].isEnabled = score >= i;
				stars[i].alpha = 0;
				Starling.juggler.tween(stars[i], 0.3, {delay:i/10, alpha:1});
			}
		}
	}
}