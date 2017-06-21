package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.models.AppModel;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.LayoutGroup;
	import feathers.controls.ProgressBar;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.textures.Texture;
	
	public class BuildingIcon extends LayoutGroup
	{
		private var iconDisplay:ImageLoader;
		private var progressbar:ProgressBar;
		private var progressLabel:RTLLabel;
		
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
		}
		
		public function set upgradable(value:Boolean):void
		{
			progressbar.visible = value;
			progressLabel.visible = value;
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