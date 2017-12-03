package com.gerantech.towercraft.controls
{
import com.gerantech.towercraft.controls.sliders.BuildingSlider;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.buildings.Building;
import com.gt.towers.constants.CardTypes;

import flash.geom.Rectangle;

import feathers.controls.ImageLoader;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;

import starling.display.Quad;

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

private var padding:int;

private var levelBackground:ImageLoader;

private var rarityDisplay:ImageLoader;

public function BuildingCard()
{
	super();
}

override protected function initialize():void
{
	super.initialize();
	
	/*skin = new ImageSkin(Assets.getTexture("theme/building-button", "gui"));
	skin.pixelSnapping = false;
	skin.setTextureForState("normal", Assets.getTexture("theme/building-button", "gui"));
	skin.setTextureForState("locked", Assets.getTexture("theme/building-button-disable", "gui"));
	skin.scale9Grid = new Rectangle(10, 10, 56, 37);
	backgroundSkin = skin;*/
	
	layout= new AnchorLayout();
	padding = 16 * appModel.scale;
	
	iconDisplay = new ImageLoader();
	iconDisplay.pixelSnapping = false;
	iconDisplay.layoutData = new AnchorLayoutData(padding, padding, padding, padding);
	addChild(iconDisplay);
	
	var coverDisplay:ImageLoader = new ImageLoader();
	coverDisplay.scale = appModel.scale * 2;
	coverDisplay.scale9Grid = new Rectangle(30,34,2,3);
	coverDisplay.source = Assets.getTexture("cards/bevel-card", "gui");
	coverDisplay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChild(coverDisplay);
	
	if( levelDisplayFactory == null )
		levelDisplayFactory = defaultLevelDisplayFactory;
	levelDisplayFactory();

	if( sliderDisplayFactory == null )
		sliderDisplayFactory = defaultSliderDisplayFactory;
	sliderDisplayFactory();

	var t:int = type;
	type = -1;
	type = t;
	addEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);
}

private function createCompleteHandler():void
{
	removeEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);
	height = width * 1.295;
}

protected function defaultRarityDisplayFactory():void
{
	if( rarityDisplay != null )
		return;
	
	var rarity:int = CardTypes.get_rarity(_type);
	if( rarity == 0 ) 
		return;
	
	rarityDisplay = new ImageLoader();
	rarityDisplay.scale = appModel.scale * 2;
	rarityDisplay.scale9Grid = new Rectangle(30,34,2,3);
	rarityDisplay.source = Assets.getTexture("cards/rarity-" + rarity, "gui");
	rarityDisplay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChildAt(rarityDisplay, 0);
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
	if ( levelBackground )
		levelBackground.visible = !_locked && _showLevel;
}
protected function defaultLevelDisplayFactory():void
{
	if( !_showLevel || _locked || levelDisplay != null )
		return;
	
	var rarity:int = CardTypes.get_rarity(_type);
	
	levelBackground = new ImageLoader();
	levelBackground.maintainAspectRatio = false
	levelBackground.source = Assets.getTexture("cards/rarity-skin-" + rarity, "gui");
	levelBackground.alpha = 0.7;
	levelBackground.height = padding * 4;
	levelBackground.layoutData = new AnchorLayoutData(NaN, padding, padding, padding);
	addChildAt(levelBackground, 2);			
	
	levelDisplay = new RTLLabel("Level "+ _level, rarity==0?1:0, "center", null, false, null, 0.8);
	levelDisplay.alpha = 0.7;
	levelDisplay.height = 56 * appModel.scale;
	levelDisplay.layoutData = new AnchorLayoutData(NaN, padding, padding, padding);
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
	sliderDisplay.height = padding * 4;
	sliderDisplay.layoutData = new AnchorLayoutData(NaN, padding*0.3, -padding*3.6, padding*0.3);
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
		iconDisplay.alpha = _locked ? 0.6 : 1;
	if( levelDisplay )
		levelDisplay.visible = !_locked && showLevel;
	if( levelBackground )
		levelBackground.visible = !_locked && showLevel;
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
		iconDisplay.source = Assets.getTexture("cards/" + _type, "gui");
	
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
	
	defaultRarityDisplayFactory()
	level = building.get_level();
}
}
}