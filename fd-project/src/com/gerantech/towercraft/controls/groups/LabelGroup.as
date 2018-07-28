package com.gerantech.towercraft.controls.groups 
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
/**
 * ...
 * @author Mansour Djawadi ...
 */
public class LabelGroup extends TowersLayout
{
private var label:String;
private var textColor:uint;

public function LabelGroup(label:String, textColor:uint = 0xFFFFFF)
{
	super();
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
	skin.scale9Grid = new Rectangle(4, 4, 2, 2);
	skin.alpha = 0.8;
	skin.color = 0x9bb7d2;
	backgroundSkin = skin;
	
	var labelDisplay:ShadowLabel = new ShadowLabel(label, textColor, 0, "center", null, false, null, 0.8);
	labelDisplay.layoutData = new AnchorLayoutData(-padding, NaN, NaN, NaN, 0);
	labelDisplay.height = padding * 2;
	addChild(labelDisplay);
}
}
}