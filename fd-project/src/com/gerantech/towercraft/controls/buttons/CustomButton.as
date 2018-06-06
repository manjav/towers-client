package com.gerantech.towercraft.controls.buttons
{
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;

import flash.geom.Point;

import feathers.controls.ButtonState;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.ILayoutData;
import feathers.skins.ImageSkin;

import starling.textures.Texture;

public class CustomButton extends SimpleLayoutButton
{
public var iconLayout:ILayoutData;
public var iconPosition:Point;
public var data:Object;
public var autoSizeLabel:Boolean = true;

protected var padding:Number;
protected var labelDisplay:RTLLabel;
protected var shadowDisplay:RTLLabel;
protected var iconDisplay:ImageLoader;

protected var labelLayoutData:AnchorLayoutData;
protected var shadowLayoutData:AnchorLayoutData;

private var _style:String = "normal"
private var _label:String = "";
private var _icon:Texture;
private var _fontColor:uint = 1;
private var _fontsize:Number = 0;

private var defaultTextue:Texture;
private var downTextue:Texture;

public function CustomButton()
{
	if( width == 0 )
		width = 250 * appModel.scale;
	minWidth = 72 * appModel.scale;
	minHeight = 72 * appModel.scale;
	height = maxHeight = 128 * appModel.scale;
	
	iconPosition = new Point();
	padding = 8 * appModel.scale;
	layout = new AnchorLayout();
	shadowLayoutData = new AnchorLayoutData(NaN, padding, NaN, padding, NaN, -padding * 0.8);
	labelLayoutData = new AnchorLayoutData(NaN, padding, NaN, padding, NaN, -padding * 0.3);
	iconLayout = new AnchorLayoutData(NaN, padding + iconPosition.x, NaN, NaN, NaN, iconPosition.y - padding * 0.4);
}

override protected function initialize():void
{
	super.initialize();
	
	if( _fontsize == 0 )
	{
		if( autoSizeLabel )
			_fontsize = Math.max(0.5, Math.min(1.15, height / 92 / appModel.scale));
		else
			_fontsize = appModel.theme.gameFontSize * appModel.scale;
	}
	
	updateTextures();
	skin = new ImageSkin(isEnabled ? defaultTextue : appModel.theme.buttonDisabledSkinTexture);
	skin.setTextureForState(ButtonState.UP, defaultTextue);
	skin.setTextureForState(ButtonState.DOWN, downTextue);
	skin.setTextureForState(ButtonState.DISABLED, appModel.theme.buttonDisabledSkinTexture);
	skin.scale9Grid = BaseMetalWorksMobileTheme.BUTTON_SCALE9_GRID;
	backgroundSkin = skin;
	
	shadowDisplay = new RTLLabel(_label, 0x000000, "center", null, false, null, _fontsize);
	shadowDisplay.pixelSnapping = false;
	shadowDisplay.touchable = false;
	shadowDisplay.layoutData = shadowLayoutData;
	addChild(shadowDisplay);
	
	labelDisplay = new RTLLabel(_label, _fontColor, "center", null, false, null, _fontsize);
	labelDisplay.pixelSnapping = false;
	labelDisplay.touchable = false;
	labelDisplay.layoutData = labelLayoutData;
	addChild(labelDisplay);
	
	iconDisplay = new ImageLoader();
	iconDisplay.touchable = false;
	iconDisplay.height = height * 0.7;
	iconDisplay.layoutData = iconLayout;
	iconDisplay.source = _icon;
	addChild(iconDisplay);
}

private function updateTextures():void
{
	defaultTextue = appModel.theme.buttonUpSkinTexture;
	if( style == "danger" )
		defaultTextue = appModel.theme.buttonDangerUpSkinTexture;
	else if( style == "neutral" )
		defaultTextue = appModel.theme.buttonNeutralUpSkinTexture;
	
	downTextue = appModel.theme.buttonDownSkinTexture;
	if( style == "danger" )
		downTextue = appModel.theme.buttonDangerDownSkinTexture;
	else if( style == "neutral" )
		downTextue = appModel.theme.buttonNeutralDownSkinTexture;			
	
	if( skin )
		skin.defaultTexture = defaultTextue;
}		

public function get label():String
{
	return _label;
}
public function set label(value:String):void
{
	if(_label == value)
		return;
	_label = value;
	if( labelDisplay )
		labelDisplay.text = _label;
	if( shadowDisplay )
		shadowDisplay.text = _label;
}



public function get icon():Texture
{
	return _icon;
}
public function set icon(value:Texture):void
{
	_icon = value;
	if ( iconDisplay )
		iconDisplay.source = _icon;
	
	labelLayoutData.right = (_icon==null?1:10)*padding;
	shadowLayoutData.right = (_icon==null?1:10)*padding;
}

override public function set currentState(value:String):void
{
	if(super.currentState == value)
		return;
	
	super.currentState = value;
	shadowLayoutData.verticalCenter = -padding*(value==ButtonState.DOWN?0.5:0.8)
}

public function get style():String
{
	return _style;
}
public function set style(value:String):void
{
	if( _style == value )
		return;
	_style = value;
	updateTextures();
}

public function get fontColor():uint
{
	return _fontColor;
}
public function set fontColor(value:uint):void
{
	if( _fontColor == value )
		return;
	_fontColor = value;
}

public function get fontsize():Number
{
	return _fontsize;
}
public function set fontsize(value:Number):void
{
	if( _fontsize == value )
		return;
	_fontsize = value;
	if( labelDisplay != null )
	{
		labelDisplay.fontSize = _fontsize;
		shadowDisplay.fontSize = _fontsize;
	}
}
}
}