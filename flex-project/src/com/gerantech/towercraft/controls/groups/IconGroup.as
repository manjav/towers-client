package com.gerantech.towercraft.controls.groups
{
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.constants.ResourceType;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.text.BitmapFontTextFormat;
	
	import starling.textures.Texture;
	import com.gerantech.towercraft.controls.TowersLayout;

	public class IconGroup extends TowersLayout
	{
		private var icon:Texture;
		private var label:String;
		private var textColor:uint;
		
		public function IconGroup(icon:Texture, label:String, textColor:uint = 0xFFFFFF)
		{
			super();
			this.icon = icon;
			this.label = label;
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
			skin.color = 0x9bb7d2;
			skin.layoutData = new AnchorLayoutData(0, 0, 0, 0);
			addChild(skin);
			
			var labelDisplay:BitmapFontTextRenderer = new BitmapFontTextRenderer();//imageDisplay.width, imageDisplay.width/2, "");
			labelDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 54*appModel.scale, textColor, "center")
			labelDisplay.layoutData = new AnchorLayoutData(NaN, 0, NaN, padding * 4, NaN, -padding*0.5);
			labelDisplay.text = label;
			addChild(labelDisplay);
			
			var iconDisplay:ImageLoader = new ImageLoader();
			iconDisplay.source = icon;
			iconDisplay.layoutData = new AnchorLayoutData(-padding, NaN, -padding, -padding);
			addChild(iconDisplay);
		}
	}
}