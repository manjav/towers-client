package com.gerantech.towercraft.controls.overlays
{
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.buildings.Building;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.text.BitmapFontTextFormat;
	
	import starling.animation.Transitions;
	import starling.core.Starling;

	public class UpgradeOverlay extends BaseOverlay
	{
		public var building:Building;

		override protected function initialize():void
		{
			layout = new AnchorLayout();
			closable = false;
			super.initialize();

			width = stage.stageWidth;
			height = stage.stageHeight;
			overlay.alpha = 1;
			
			var iconDisplay:ImageLoader = new ImageLoader();
			iconDisplay.source = Assets.getTexture("building-"+building.type, "gui");
			iconDisplay.height = iconDisplay.width = 360 * appModel.scale;
			iconDisplay.maintainAspectRatio = false;
			iconDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
			addChild(iconDisplay);	
			
			var levelDisplay:BitmapFontTextRenderer = new BitmapFontTextRenderer();//imageDisplay.width, imageDisplay.width/2, "");
			levelDisplay.alignPivot();
			levelDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 160*appModel.scale, 0xFFFFFF, "center")
			levelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -320*appModel.scale);
			levelDisplay.text = String(building.level-1) 
			addChild(levelDisplay);
			
			Starling.juggler.tween(levelDisplay, 0.5, {delay:0.5, scale:0, transition:Transitions.EASE_IN_BACK, onComplete:sclaeCompleted});
			function sclaeCompleted():void {
				closable = true;
				levelDisplay.text = String(building.level) 
				Starling.juggler.tween(levelDisplay, 0.5, {scale:1, transition:Transitions.EASE_IN_OUT_BACK});
			}
		}
	}
}