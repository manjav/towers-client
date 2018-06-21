package com.gerantech.towercraft.controls.buttons
{
import feathers.controls.ButtonState;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.textures.Texture;

public class IconButton extends SimpleLayoutButton
{
private var texture:Texture;
private var iconScale:Number;
private var iconDisplay:ImageLoader;
public function IconButton(texture:Texture, iconScale:Number = 0.6)
{
	super();
	this.texture = texture;
	this.iconScale = iconScale;
}

override protected function initialize():void
{
	super.initialize();

	layout = new AnchorLayout();
	iconDisplay = new ImageLoader();
	iconDisplay.source = texture;
	iconDisplay.width = iconDisplay.height = height * iconScale;
	iconDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
	addChild(iconDisplay);
}

override public function set currentState(value:String):void
{
	if( value == super.currentState )
		return;
	iconDisplay.width = iconDisplay.height = height * (value == ButtonState.DOWN ? iconScale * 0.9 : iconScale);
	super.currentState = value;
}
}
}