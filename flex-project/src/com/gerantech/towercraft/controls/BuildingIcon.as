package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.models.AppModel;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.LayoutGroup;
	import feathers.controls.ProgressBar;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.filters.ColorMatrixFilter;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	
	public class BuildingIcon extends LayoutGroup
	{
		private var iconDisplay:ImageLoader;
		private var progressbar:ProgressBar;
		private var progressLabel:RTLLabel;

		private var disableFilter:ColorMatrixFilter;
		
		public function BuildingIcon()
		{
			super();
			
			layout= new AnchorLayout();
			var progressHeight:int = 64*AppModel.instance.scale;
			
			iconDisplay = new ImageLoader();
			iconDisplay.maintainAspectRatio = false;
			iconDisplay.layoutData = new AnchorLayoutData(0, 0, progressHeight, 0);
			addChild(iconDisplay);
		
			progressbar = new ProgressBar();
			progressbar.layoutData = new AnchorLayoutData(NaN, 0, 0, 0);
			progressbar.height = progressHeight;
			addChild(progressbar);
			
			progressLabel = new RTLLabel("1/2", 1, "center", null, false, null, 0, null, "bold");
			progressLabel.layoutData = new AnchorLayoutData(NaN, 0, 0, 0);
			progressLabel.height = progressHeight;
			addChild(progressLabel);
			
			//disableFilter = new ColorMatrixFilter();
			//disableFilter.resolution = 0.8;
		//	disableFilter.adjustSaturation(-0.7);
			//disableFilter.textureSmoothing = TextureSmoothing.BILINEAR
		}
		
		public function set upgradable(value:Boolean):void
		{
			progressbar.visible = value;
			progressLabel.visible = value;

			//iconDisplay.filter = value ? null : disableFilter;
			iconDisplay.alpha = value ? 1 : 0.7;
		}
		
		
		public function setData(minimum:int, value:Number, maximum:int):void
		{
			progressbar.maximum = maximum;
			progressbar.value = Math.max(0, Math.min( maximum, value ) );
			
			progressLabel.text = value + " / " + maximum;
						
		}
		
		public function setImage(texture:Texture):void
		{
			iconDisplay.source = texture;
		}
	}
}