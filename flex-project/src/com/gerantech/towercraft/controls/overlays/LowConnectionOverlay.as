package com.gerantech.towercraft.controls.overlays
{
	import com.gerantech.towercraft.controls.groups.Devider;
	import com.gerantech.towercraft.models.Assets;
	
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.core.Starling;

	public class LowConnectionOverlay extends BaseOverlay
	{
		public function LowConnectionOverlay()
		{
			super();
			closeOnOverlay = closeOnStage = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			overlay.alpha = 0.2;
			
			layout = new AnchorLayout();
			
			var imageDisplay:ImageLoader = new ImageLoader();
			imageDisplay.scale = appModel.scale * 2;
			imageDisplay.source = Assets.getTexture("connection-alert", "gui");
			imageDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
			addChild(imageDisplay);
			
			Starling.juggler.tween(imageDisplay, 1, {repeatCount:12, alpha:0});
			
		}
	}
}