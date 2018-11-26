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
	skin = new ImageSkin(Assets.getTexture("gold-key"));
	skin.setTextureForState(ButtonState.UP, Assets.getTexture("gold-key"));
	skin.setTextureForState(ButtonState.DISABLED, Assets.getTexture("gold-key-off"));
	skin.defaultTexture = skin.getTextureForState(isEnabled ? ButtonState.UP : ButtonState.DISABLED );
	backgroundSkin = skin;
}

override public function set isEnabled(value:Boolean):void
{
	super.isEnabled = value;
	if( skin != null )
		skin.defaultTexture = skin.getTextureForState(value ? ButtonState.UP : ButtonState.DISABLED );
}
}
}