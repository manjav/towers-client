package com.gerantech.towercraft.controls.sliders
{
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.ProgressBar;
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.text.BitmapFontTextFormat;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	
	public class BuildingSlider extends ProgressBar
	{
		private var labelDisplay:BitmapFontTextRenderer;
		private var upgradeDisplay:ImageLoader;
		private var timeoutId:uint;
		public function BuildingSlider()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			labelDisplay = new BitmapFontTextRenderer();
			labelDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 48*AppModel.instance.scale, 0xFFFFFF, "center");
			
			upgradeDisplay = new ImageLoader();
			upgradeDisplay.maintainAspectRatio = false;
			upgradeDisplay.source = Assets.getTexture("upgrade-ready", "skin");
		}
		
		override protected function draw():void
		{
			labelDisplay.width = width;
			super.draw();
		}
		
		override public function set value(newValue:Number):void
		{
			super.value = Math.max(0, Math.min( newValue, maximum ) );
			labelDisplay.text = newValue + " / " + maximum;
			addChild(labelDisplay);
			isEnabled = newValue >= maximum;
			
			if( newValue >= maximum )
			{
				upgradeDisplay.height = height * 1.2;
				upgradeDisplay.width = upgradeDisplay.height;
				upgradeDisplay.x = height*0.1;
				upgradeDisplay.y = -height*0.6;
				addChild(upgradeDisplay);
				punchArrow();
				
				labelDisplay.x = height*0.3;
				labelDisplay.width = width-height*0.3;
			}
			else
			{
				stopPunching();
				upgradeDisplay.removeFromParent();
			}
		}
		
		private function punchArrow():void
		{
			timeoutId = setTimeout(animateUpgradeDisplay, 2000+Math.random()*1000);
		}
		private function animateUpgradeDisplay():void
		{
			Starling.juggler.tween(upgradeDisplay, 0.5, {y:-height*0.6, height:height*1.2, transition:Transitions.EASE_OUT_BACK, onComplete:punchArrow});
			upgradeDisplay.y = -height*1.5;
			upgradeDisplay.height = height*1.8;
		}
		
		private function stopPunching():void
		{
			clearTimeout(timeoutId);
			Starling.juggler.removeTweens(upgradeDisplay);
		}

		override public function dispose():void
		{
			stopPunching();
			super.dispose();
		}

	}
}