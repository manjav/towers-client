package com.gerantech.towercraft.controls
{
import com.gerantech.towercraft.controls.sliders.BuildingSlider;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.buildings.Building;
import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.controls.text.BitmapFontTextRenderer;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;
import flash.geom.Rectangle;
import starling.events.Event;

public class BuildingCard extends TowersLayout
{
public static var VERICAL_SCALE:Number = 1.295;
public var levelDisplayFactory:Function;
public var elixirDisplayFactory:Function;
public var sliderDisplayFactory:Function;
public var countDisplayFactory:Function;
public var data:Object;

private var _type:int = -1;
private var _level:int = 0;
private var _elixir:int = 0;
private var _rarity:int = 0;
private var _count:int = 0;

private var _showElixir:Boolean = true;
private var _locked:Boolean = false;
private var _showSlider:Boolean = true;
private var _showLevel:Boolean = true;
private var _showCount:Boolean = false;

private var padding:int;
private var skin:ImageSkin;
private var levelDisplay:RTLLabel;
private var countDisplay:BitmapFontTextRenderer;
private var iconDisplay:ImageLoader;
private var sliderDisplay:BuildingSlider;
private var levelBackground:ImageLoader;
private var rarityDisplay:ImageLoader;
private var labelsContainer:LayoutGroup;

public function BuildingCard()
{
	super();
	labelsContainer = new LayoutGroup();
}

override protected function initialize():void
{
	super.initialize();
	
	layout= new AnchorLayout();
	padding = 16 * appModel.scale;
	
	iconDisplay = new ImageLoader();
	iconDisplay.pixelSnapping = false;
	iconDisplay.layoutData = new AnchorLayoutData(padding, padding, padding, padding);
	addChild(iconDisplay);
	
	var coverDisplay:ImageLoader = new ImageLoader();
	coverDisplay.scale9Grid = new Rectangle(60, 68, 4, 6);
	coverDisplay.source = Assets.getTexture("cards/bevel-card", "gui");
	coverDisplay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChild(coverDisplay);
	
	labelsContainer.layout = new AnchorLayout();
	labelsContainer.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	
	if( levelDisplayFactory == null )
		levelDisplayFactory = defaultLevelDisplayFactory;
	
	if( sliderDisplayFactory == null )
		sliderDisplayFactory = defaultSliderDisplayFactory;
	
/*	if( elixirDisplayFactory == null )
		elixirDisplayFactory = defaultElixirDisplayFactory;
	
	if( countDisplayFactory == null )
		countDisplayFactory = defaultCountDisplayFactory;*/

	var t:int = type;
	type = -1;
	type = t;
	addEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);
	addEventListener(Event.ADDED, addedHandler);
}

private function addedHandler():void
{
	if( labelsContainer )
		addChild(labelsContainer);	
}

private function createCompleteHandler():void
{
	removeEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);
	height = width * VERICAL_SCALE;
}


//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  TYPE  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
public function get type():int
{
	return _type;
}
public function set type(value:int):void
{
	/*if(_type == value)
	return;*/
	
	_type = value;
	if( _type < 0 )
		return;
	
	var building:Building = player.buildings.get(_type);
	if( iconDisplay )
		iconDisplay.source = Assets.getTexture("cards/" + _type, "gui");
	
	locked = building == null;
	if( building == null )
		return;
	
	if( sliderDisplayFactory != null )
		sliderDisplayFactory();
	
	rarity = 0//building.rarity;
	level = building.get_level();
	//count = building.troopsCount;
	//elixir = building.elixirSize;
}

//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  LOCKED  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
public function set locked(value:Boolean):void
{
	if( _locked == value )
		return;
	
	_locked = value;
	if( sliderDisplay )
		sliderDisplay.visible = !_locked && showSlider;
	
	if( skin )
		skin.defaultTexture = skin.getTextureForState(_locked?"locked":"normal");
	if( iconDisplay )
		iconDisplay.alpha = _locked ? 0.7 : 1;
	if( levelDisplay )
		levelDisplay.visible = !_locked && showLevel;
	if( levelBackground )
		levelBackground.visible = !_locked && showLevel;
}

//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  LEVEL  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
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
	if( levelDisplay )
		levelDisplay.visible = !_locked && _showLevel;
	if( levelBackground )
		levelBackground.visible = !_locked && _showLevel;
}
protected function defaultLevelDisplayFactory():void
{
	if( !_showLevel || _locked || _type < 0 || _level <= 0 )
		return;
	
	if( levelDisplay != null )
	{
		levelDisplay.text = "Level "+ _level;
		return;
	}
	
	levelDisplay = new RTLLabel("Level " + _level, _rarity == 0?1:0, "center", null, false, null, 0.8);
	levelDisplay.alpha = 0.8;
	levelDisplay.height = 52 * appModel.scale;
	levelDisplay.layoutData = new AnchorLayoutData(NaN, padding, padding, padding);
	labelsContainer.addChild(levelDisplay);
}

public function get level():int
{
	return _level;
}
public function set level(value:int):void
{
	if( _level == value )
		return;
	_level = value;
	if( levelDisplayFactory != null )
		levelDisplayFactory();
	if( sliderDisplayFactory != null )
		sliderDisplayFactory();
}

//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  SLIDER  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
public function get showSlider():Boolean
{
	return _showSlider;
}
public function set showSlider(value:Boolean):void
{
	if( _showSlider == value )
		return;
	_showSlider = value;
	if( sliderDisplayFactory != null )
		sliderDisplayFactory();
	if( sliderDisplay )
		sliderDisplay.visible = !_locked && _showSlider;
}
protected function defaultSliderDisplayFactory():void
{
	if( !_showSlider || _locked || _level <= 0 )
		return;
	
	var building:Building = player.buildings.get(_type);
	if( building == null )
		return;
	var upgradeCards:int = building.get_upgradeCards();
	var numBuildings:int = player.resources.get(type);
	if( sliderDisplay != null )
	{
		sliderDisplay.maximum = upgradeCards;
		sliderDisplay.value = numBuildings;
		return;
	}
	sliderDisplay = new BuildingSlider();
	sliderDisplay.height = padding * 4;
	sliderDisplay.layoutData = new AnchorLayoutData(NaN, padding * 0.3, -padding * 4.2, padding * 0.3);
	sliderDisplay.addEventListener(FeathersEventType.CREATION_COMPLETE, function():void{
		sliderDisplay.labelDisplay.layoutData = new AnchorLayoutData(NaN, padding * 2, -padding * 3.7, padding * (building.upgradable(0)?5:2));
		labelsContainer.addChild(sliderDisplay.labelDisplay);
		sliderDisplay.maximum = upgradeCards;
		sliderDisplay.value = numBuildings;
	});
	addChild(sliderDisplay);
}

//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  RARITY  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
public function get rarity():int
{
	return _rarity;
}
public function set rarity(value:int):void
{
	_rarity = value;
	defaultRarityDisplayFactory();
}
protected function defaultRarityDisplayFactory():void
{
	if( !_locked && showLevel )
	{
		if( levelBackground == null )
		{
			levelBackground = new ImageLoader();
			levelBackground.maintainAspectRatio = false
			levelBackground.source = Assets.getTexture("cards/rarity-skin-" + _rarity, "gui");
			levelBackground.alpha = 0.7;
			levelBackground.height = padding * 3;
			levelBackground.layoutData = new AnchorLayoutData(NaN, padding, padding, padding);
			addChildAt(levelBackground, Math.min(1, numChildren));
		}
		else
		{
			levelBackground.source = Assets.getTexture("cards/rarity-skin-" + _rarity, "gui");
		}
	}
	
	if( rarityDisplay != null )
	{
		rarityDisplay.visible = _rarity > 0;
		if( _rarity > 0 )
			rarityDisplay.source = Assets.getTexture("cards/rarity-" + _rarity, "gui");
		return;
	}
	if( rarity == 0 ) 
		return;
	
	rarityDisplay = new ImageLoader();
	rarityDisplay.scale = appModel.scale * 2;
	rarityDisplay.scale9Grid = new Rectangle(30,34,2,3);
	rarityDisplay.source = Assets.getTexture("cards/rarity-" + _rarity, "gui");
	rarityDisplay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChildAt(rarityDisplay, 0);
}

/*
//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  ELIXIR SIZE  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
public function get showElixir():Boolean
{
	return _showElixir;
}
public function set showElixir(value:Boolean):void
{
	if ( _showElixir == value )
		return;
	
	_showElixir = value;
	if( elixirDisplayFactory != null )
		elixirDisplayFactory();
}
protected function defaultElixirDisplayFactory():void
{
	if( !_showElixir || _locked || _type < 0 || _level <= 0 )
		return;
	
	var elixirBackground:ImageLoader = new ImageLoader();
	elixirBackground.source = Assets.getTexture("cards/elixir-"+_elixir, "gui");
	elixirBackground.scale = appModel.scale * 2.4;
	elixirBackground.layoutData = new AnchorLayoutData(-padding*0.3, NaN, NaN, -padding*0.3);
	addChild(elixirBackground);
}

public function get elixir():int
{
	return _elixir;
}
public function set elixir(value:int):void
{
	if ( _elixir == value )
		return;
	
	_elixir = value;
	elixirDisplayFactory();
}

//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  COUNT  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
public function get showCount():Boolean
{
	return _showCount;
}
public function set showCount(value:Boolean):void
{
	if ( _showCount == value )
		return;
	
	_showCount = value;
	if( countDisplayFactory != null )
		countDisplayFactory();
}
protected function defaultCountDisplayFactory():void
{
	if( !_showCount || _locked || _type < 0 || _level <= 0 )
		return;
	
	if( countDisplay == null )
	{
		countDisplay = new BitmapFontTextRenderer();//imageDisplay.width, imageDisplay.width/2, "");
		countDisplay.touchable = false;
		countDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 64*appModel.scale, 0xFFFFFF, "right");
		countDisplay.layoutData = new AnchorLayoutData(NaN, padding*2, padding*1.5);
		labelsContainer.addChild(countDisplay);
	}

	countDisplay.text = "x "+ _count;
}

public function get count():int
{
	return _count;
}
public function set count(value:int):void
{
	if ( _count == value )
		return;
	
	_count = value;
	countDisplayFactory();
}*/
}
}