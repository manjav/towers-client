package com.gerantech.towercraft.controls.overlays
{
	import com.gerantech.towercraft.controls.RTLLabel;
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.buildings.Building;
	
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;

	public class UpgradeOverlay extends BaseOverlay
	{
		public var building:Building;

		override protected function initialize():void
		{
			layout = new AnchorLayout();
			super.initialize();

			width = stage.stageWidth;
			height = stage.stageHeight;
			overlay.alpha = 1;
			
			var levelDisplay:RTLLabel = new RTLLabel(String(building.level), 1, "center", null, false, null, 50, null, "bold");
			levelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -320*appModel.scale);
			addChild(levelDisplay);
			
			var iconDisplay:ImageLoader = new ImageLoader();
			iconDisplay.source = Assets.getTexture("improve-"+building.type, "gui");
			iconDisplay.height = iconDisplay.width = 300 * appModel.scale;
			iconDisplay.maintainAspectRatio = false;
			iconDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
			addChild(iconDisplay);	
		}

	}
}