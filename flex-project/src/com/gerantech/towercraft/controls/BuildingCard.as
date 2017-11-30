package com.gerantech.towercraft.controls
{
import com.gerantech.towercraft.controls.sliders.BuildingSlider;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.buildings.Building;

import flash.geom.Rectangle;

import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;

import starling.utils.ScaleMode;

public class BuildingCard extends TowersLayout
{
private var iconDisplay:ImageLoader;
private var sliderDisplay:BuildingSlider;

private var _type:int = -1;
private var _level:int = 0;
private var _locked:Boolean = false;
private var _showSlider:Boolean = true;
private var _showLevel:Boolean = true;

private var skin:ImageSkin;
private var levelDisplay:RTLLabel;

public var levelDisplayFactory:Function;
public var sliderDisplayFactory:Function;

public function BuildingCard()
{
	super();
}

override protected function initialize():void
{
	super.initialize();
	
	skin = new ImageSkin(Assets.getTexture("theme/building-button", "gui"));
	skin.pixelSnapping = false;
	skin.setTextureForState("normal", Assets.getTexture("theme/building-button", "gui"));
	skin.setTextureForState("locked", Assets.getTexture("theme/building-button-disable", "gui"));
	skin.scale9Grid = new Rectangle(10, 10, 56, 37);
	backgroundSkin = skin;
	
	layout= new AnchorLayout();
	var padding:int = 16 * appModel.scale;
	
	iconDisplay = new ImageLoader();
	iconDisplay.pixelSnapping = false;
	iconDisplay.horizontalAlign = "left";
	iconDisplay.padding = 8 * appModel.scale;
	iconDisplay.scaleMode = ScaleMode.NO_BORDER;
	iconDisplay.layoutData = new AnchorLayoutData(0, 0, padding * 2, 0);
	addChild(iconDisplay);
	
	if( levelDisplayFactory == null )
		levelDisplayFactory = defaultLevelDisplayFactory;
	levelDisplayFactory();

	if( sliderDisplayFactory == null )
		sliderDisplayFactory = defaultSliderDisplayFactory;
	sliderDisplayFactory();

	var t:int = type;
	type = -1;
	type = t;
}

public function get showLevel():Boolean
{
	return _showLevel;
}
public function set showLevel(value:Boolean):void
{
	if ( _showLevel == value )
		return;
	
	_showLevel = value;
	if( levelDisplayFactory != null )
		levelDisplayFactory();
	if ( levelDisplay )
		levelDisplay.visible = !_locked && _showLevel;
}
protected function defaultLevelDisplayFactory():void
{
	if( !_showLevel || _locked || levelDisplay != null )
		return;
	
	var padding:int = 16 * appModel.scale;
	levelDisplay = new RTLLabel("Level "+ _level, 0, "center", null, false, null, 0.8);
	levelDisplay.alpha = 0.9;
	levelDisplay.height = 56 * appModel.scale;
	levelDisplay.layoutData = new AnchorLayoutData(padding, padding, NaN, padding);
	addChild(levelDisplay);			
}

public function get level():int
{
	return _level;
}
public function set level(value:int):void
{
	if ( _level == value )
		return;
	
	_level = value;
	if ( showLevel && levelDisplay )
		levelDisplay.text = "Level " + _level;
}

public function get showSlider():Boolean
{
	return _showSlider;
}
public function set showSlider(value:Boolean):void
{
	if ( _showSlider == value )
		return;
	_showSlider = value;
	if( sliderDisplayFactory != null )
		sliderDisplayFactory();
	if ( sliderDisplay )
		sliderDisplay.visible = !_locked && _showSlider;
}
protected function defaultSliderDisplayFactory():void
{
	if( !_showSlider || _locked || sliderDisplay != null )
		return;
	
	sliderDisplay = new BuildingSlider();
	sliderDisplay.layoutData = new AnchorLayoutData(NaN, 0, 0, 0);
	sliderDisplay.height = 56 * appModel.scale;
	addChild(sliderDisplay);			
}


public function set locked(value:Boolean):void
{
	if ( _locked == value )
		return;
	
	_locked = value;
	if ( sliderDisplay )
		sliderDisplay.visible = !_locked && showSlider;

	if ( skin )
		skin.defaultTexture = skin.getTextureForState(_locked?"locked":"normal");
	if ( iconDisplay )
		iconDisplay.alpha = _locked ? 0.7 : 1;
	if( levelDisplay )
		levelDisplay.visible = !_locked && showLevel;
}


public function get type():int
{
	return _type;
}
public function set type(value:int):void
{
	/*if(_type == value)
		return;*/
	
	_type = value;
	if(_type < 0)
		return;
	
	var building:Building = player.buildings.get(_type);
	
	if ( iconDisplay )
		iconDisplay.source = Assets.getTexture("building-"+_type, "gui");
	
	locked = building == null;
	if( building == null )
		return;
	
	var upgradeCards:int = building.get_upgradeCards();
	var numBuildings:int = player.resources.get(type);
	
	if( showSlider && sliderDisplay )
	{
		sliderDisplay.maximum = upgradeCards;
		sliderDisplay.value = numBuildings;
	}
	
	level = building.get_level();
}
}
}