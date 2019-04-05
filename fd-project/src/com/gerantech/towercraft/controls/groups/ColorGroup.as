package com.gerantech.towercraft.controls.groups
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.themes.MainTheme;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

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
	skin.source = appModel.theme.roundMediumInnerSkin;
	skin.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	skin.color = bgColor;
	skin.scale9Grid = MainTheme.ROUND_MEDIUM_SCALE9_GRID;
	addChild(skin);
	
	labelDisplay = new ShadowLabel(label, textColor, 0, null, null, false, null, 0.9);
	labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
	addChild(labelDisplay);
}
}
}