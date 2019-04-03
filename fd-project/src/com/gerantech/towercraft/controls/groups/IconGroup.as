package com.gerantech.towercraft.controls.groups
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.utils.StrUtils;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
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
	this.label = StrUtils.getNumber(label);
	this.textColor = textColor;
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout(); 
	height = 100;
	
	var skin:ImageLoader = new ImageLoader();
	skin.source = Assets.getTexture("theme/inner-rect-medium", "gui")
	skin.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	skin.scale9Grid = new Rectangle(15, 15, 3, 3);
	skin.color = 0x9BBBDD;
	addChild(skin);
	
	var labelDisplay:ShadowLabel = new ShadowLabel(label, 1, 0, null, "ltr", false, null, 0.9);
	labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 60, 0);
	addChild(labelDisplay);
	
	var iconDisplay:ImageLoader = new ImageLoader();
	iconDisplay.source = icon;
	iconDisplay.layoutData = new AnchorLayoutData(-32, NaN, -32, -32);
	addChild(iconDisplay);
}
}
}