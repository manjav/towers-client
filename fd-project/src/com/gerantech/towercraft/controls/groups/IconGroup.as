package com.gerantech.towercraft.controls.groups
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.models.Assets;
import feathers.controls.ImageLoader;
import feathers.controls.text.BitmapFontTextRenderer;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.text.BitmapFontTextFormat;
import flash.geom.Rectangle;
import starling.textures.Texture;

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
	var padding:int = 32;
	height = padding * 3;
	
	var skin:ImageLoader = new ImageLoader();
	skin.source = Assets.getTexture("theme/inner-rect-medium", "gui")
	skin.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	skin.scale9Grid = new Rectangle(15, 15, 3, 3);
	skin.color = 0x9BBBDD;
	addChild(skin);
	
	var labelDisplay:BitmapFontTextRenderer = new BitmapFontTextRenderer();
	labelDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 48, textColor, "center");
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