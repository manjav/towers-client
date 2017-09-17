package com.gerantech.towercraft.controls.animations
{
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.text.BitmapFontTextFormat;
	
	import starling.display.Sprite;
	
	public class AchievedItem extends Sprite
	{
		private var resourceType:int;
		private var count:int;
		
		public function AchievedItem(resourceType:int, count:int)
		{
			this.resourceType = resourceType;
			this.count = count;

			var size:int = 140*AppModel.instance.scale;

			var labelDisplay:BitmapFontTextRenderer = new BitmapFontTextRenderer();//imageDisplay.width, imageDisplay.width/2, "");
			labelDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 72*AppModel.instance.scale, 0xFFFFFF, "left");
			labelDisplay.pixelSnapping = false;
			labelDisplay.y = -size * 0.5;
			labelDisplay.text = (count>0 ? "+":"-") + count;
			addChild(labelDisplay);
			
			var iconDisplay:ImageLoader = new ImageLoader();
			iconDisplay.source = Assets.getTexture("res-"+resourceType, "gui");
			iconDisplay.width = iconDisplay.height = size;
			iconDisplay.x = -size;
			iconDisplay.y = -size * 0.5;
			addChild(iconDisplay);
		}
	}
}