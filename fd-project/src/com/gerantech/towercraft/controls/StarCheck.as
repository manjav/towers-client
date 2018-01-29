package com.gerantech.towercraft.controls
{
import com.gerantech.towercraft.models.Assets;

import feathers.controls.ButtonState;
import feathers.controls.LayoutGroup;
import feathers.skins.ImageSkin;

public class StarCheck extends LayoutGroup
{
private var skin:ImageSkin;

public function StarCheck(){}
override protected function initialize():void
{
	super.initialize();
	
	touchable = false;
	skin = new ImageSkin(Assets.getTexture("gold-key", "gui"));
	skin.setTextureForState(ButtonState.UP, Assets.getTexture("gold-key", "gui"));
	skin.setTextureForState(ButtonState.DISABLED, Assets.getTexture("gold-key-off", "gui"));
	backgroundSkin = skin;
}

override public function set isEnabled(value:Boolean):void
{
	super.isEnabled = value;
	skin.defaultTexture = skin.getTextureForState(value ? ButtonState.UP : ButtonState.DISABLED );
}
}
}