package com.gerantech.towercraft.controls.groups
{
import com.gerantech.towercraft.utils.StrUtils;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;
import starling.textures.Texture;

public class IconGroup extends ColorGroup
{
protected var icon:Texture;
public function IconGroup(icon:Texture, label:String, bgColor:uint = 0xFFFFFF, textColor:uint = 0xFFFFFF)
{
	super(StrUtils.getNumber(label), bgColor, textColor);
	this.icon = icon;
}

override protected function initialize():void
{
	super.initialize();
	
	AnchorLayoutData(labelDisplay.layoutData).horizontalCenter = 60;
	
	var iconDisplay:ImageLoader = new ImageLoader();
	iconDisplay.source = icon;
	iconDisplay.layoutData = new AnchorLayoutData(-32, NaN, -32, -32);
	addChild(iconDisplay);
}
}
}