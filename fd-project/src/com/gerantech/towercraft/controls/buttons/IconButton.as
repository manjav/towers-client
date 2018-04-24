package com.gerantech.towercraft.controls.buttons
{
import com.gerantech.towercraft.models.Assets;

import feathers.controls.ButtonState;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.textures.Texture;

public class IconButton extends SimpleLayoutButton
{
private var texture:Texture;
private var iconDisplay:ImageLoader;
public function IconButton(texture:Texture)
{
	super();
	this.texture = texture;
}

override protected function initialize():void
{
	super.initialize();

	layout = new AnchorLayout();
	iconDisplay = new ImageLoader();
	iconDisplay.source = texture;
	iconDisplay.width = iconDisplay.height = height * 0.8;
	iconDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
	addChild(iconDisplay);
}

override public function set currentState(value:String):void
{
	if( value == super.currentState )
		return;
	iconDisplay.scale = value == ButtonState.DOWN ? 0.9 : 1;
	super.currentState = value;
}
}
}