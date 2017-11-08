package com.gerantech.towercraft.controls.buttons
{
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;

import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;

import starling.textures.Texture;

public class NotifierButton extends IconButton
{
private var _badgeNumber:int = 0;
private var notifyImage:ImageLoader;
private var shadowDisplay:ShadowLabel;

public function NotifierButton(texture:Texture)
{
	super(texture);
}

public function get badgeNumber():int
{
	return _badgeNumber;
}
public function set badgeNumber(value:int):void
{
	if( _badgeNumber == value )
		return;
	_badgeNumber = value;
	
	if( notifyImage == null || shadowDisplay == null )
		return;
	notifyImage.visible = _badgeNumber > 0;
	shadowDisplay.visible = _badgeNumber > 0;
	
	if( _badgeNumber > 0 )
		shadowDisplay.text = _badgeNumber.toString();
}

override protected function initialize():void
{
	super.initialize();
	
	var _padding:Number = -4 * AppModel.instance.scale;
	
	notifyImage = new ImageLoader();
	notifyImage.touchable = false;
	notifyImage.visible = false;
	notifyImage.scale9Grid = BaseMetalWorksMobileTheme.BUTTON_SCALE9_GRID;
	notifyImage.height = notifyImage.width = appModel.scale * 60;
	notifyImage.layoutData = new AnchorLayoutData(_padding, _padding);
	notifyImage.source = appModel.theme.buttonDangerUpSkinTexture;
	addChild(notifyImage);
	
	shadowDisplay = new ShadowLabel(_badgeNumber.toString(), 1, 0, "center", null, false, null, 0.8);
	shadowDisplay.shadowDistance = _padding;
	shadowDisplay.touchable = false;
	shadowDisplay.visible = false;
	shadowDisplay.height = shadowDisplay.width = appModel.scale * 60;
	shadowDisplay.layoutData = new AnchorLayoutData(_padding*2, _padding);
	addChild(shadowDisplay);
}
}
}