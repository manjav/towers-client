package com.gerantech.towercraft.controls.groups
{
	import com.gerantech.towercraft.controls.TowersLayout;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.models.Assets;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	public class ColorGroup extends TowersLayout
	{
		private var label:String;
		private var bgColor:uint;
		private var textColor:uint;
		
		public function ColorGroup(label:String, bgColor:uint = 0xFFFFFF, textColor:uint = 0x000000)
		{
			this.label = label;
			this.bgColor = bgColor;
			this.textColor = textColor;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout(); 
			var padding:int = 32 * appModel.scale;
			height = padding * 3;
			
			var skin:ImageLoader = new ImageLoader();
			skin.source = Assets.getTexture("theme/popup-inside-background-skin", "gui")
			skin.alpha = 0.8;
			skin.scale9Grid = new Rectangle(2,2,1,1);
			skin.color = bgColor;
			skin.layoutData = new AnchorLayoutData(0, 0, 0, 0);
			addChild(skin);
			
			var labelDisplay:RTLLabel = new RTLLabel(label, textColor);//imageDisplay.width, imageDisplay.width/2, "");
			labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -padding*0.2);
			labelDisplay.text = label;
			addChild(labelDisplay);
		}
	}
}