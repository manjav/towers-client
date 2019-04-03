package com.gerantech.towercraft.controls.groups
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;

public class ColorGroup extends TowersLayout
{
protected var label:String;
protected var bgColor:uint;
protected var textColor:uint;
protected var labelDisplay:ShadowLabel;

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
	height = 100;
	
	var skin:ImageLoader = new ImageLoader();
	skin.source = Assets.getTexture("theme/inner-rect-medium", "gui")
	skin.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	skin.scale9Grid = new Rectangle(15, 15, 3, 3);
	skin.color = bgColor;
	addChild(skin);
	
	labelDisplay = new ShadowLabel(label, textColor, 0, null, null, false, null, 0.9);
	labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
	addChild(labelDisplay);
}
}
}