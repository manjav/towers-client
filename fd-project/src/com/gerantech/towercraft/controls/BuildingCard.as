package com.gerantech.towercraft.controls
{
import com.gerantech.towercraft.controls.sliders.BuildingSlider;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.buildings.Building;
import com.gt.towers.constants.BuildingType;
import com.gt.towers.constants.ResourceType;
import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.controls.text.BitmapFontTextRenderer;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;
import flash.geom.Rectangle;
import starling.events.Event;
import starling.filters.ColorMatrixFilter;

public class BuildingCard extends TowersLayout
{
public static var VERICAL_SCALE:Number = 1.295;
//public var data:Object;

public var backgroundDisplayFactory:Function;
public var iconDisplayFactory:Function;
public var levelDisplayFactory:Function;
public var sliderDisplayFactory:Function;
public var countDisplayFactory:Function;
public var elixirDisplayFactory:Function;
public var coverDisplayFactory:Function;

protected var type:int = -1;
protected var level:int = 0;
protected var rarity:int = 0;
protected var count:int = 0;
protected var elixirSize:int = 0;
protected var availablity:int = 0;

protected var showLevel:Boolean = true;
protected var showSlider:Boolean = true;
protected var showCount:Boolean = false;
protected var showElixir:Boolean = true;

protected var padding:int;
protected var backgroundDisaplay:ImageLoader;
protected var iconDisplay:ImageLoader;
protected var labelsContainer:LayoutGroup;
protected var levelDisplay:RTLLabel;
protected var levelBackground:ImageLoader;
protected var sliderDisplay:BuildingSlider;
protected var coverDisplay:ImageLoader;
protected var rarityDisplay:ImageLoader;
protected var countDisplay:BitmapFontTextRenderer;

public function BuildingCard(showLevel:Boolean, showSlider:Boolean, showCount:Boolean, showElixir:Boolean)
{
	super();
	this.showLevel = showLevel;
	this.showSlider = showSlider;
	this.showCount = showCount;
	this.showElixir = showElixir;
	labelsContainer = new LayoutGroup();
}

override protected function initialize():void
{
	super.initialize();
	
	layout= new AnchorLayout();
	padding = 16 * appModel.scale;
	
	labelsContainer.layout = new AnchorLayout();
	labelsContainer.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	
	if( backgroundDisplayFactory == null )
		backgroundDisplayFactory = defaultBackgroundDisplayFactory;
	if( iconDisplayFactory == null )
		iconDisplayFactory = defaultIconDisplayFactory;
	if( levelDisplayFactory == null )
		levelDisplayFactory = defaultLevelDisplayFactory;
	if( sliderDisplayFactory == null )
		sliderDisplayFactory = defaultSliderDisplayFactory;
	/*if( countDisplayFactory == null )
		countDisplayFactory = defaultCountDisplayFactory;
	if( elixirDisplayFactory == null )
		elixirDisplayFactory = defaultElixirDisplayFactory;*/
	if( coverDisplayFactory == null )
		coverDisplayFactory = defaultCoverDisplayFactory;

	addEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);
	addEventListener(Event.ADDED, addedHandler);
	callFactories();
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

//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  DATA  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
public function setData(type:int, level:int = 1):void
{
	if( this.type == type )
		return;
	
	if( type < 0 )
		return;
	
	this.type = type;
	this.availablity = game.getBuildingAvailablity(type);
	if( ResourceType.isBuilding(type) )
		this.level = this.availablity == BuildingType.AVAILABLITY_EXISTS && level == 1 ? player.buildings.get(type).get_level() : level;
	this.rarity = 0;//building.rarity;;
	//this.count = building.troopsCount;
	//this.elixirSize = building.elixirSize;
	callFactories();
}

public function getType():int 
{
	return type;
}

private function callFactories() : void 
{
	if( backgroundDisplayFactory != null )
		backgroundDisplayFactory();
	if( iconDisplayFactory != null )
		iconDisplayFactory();
	if( levelDisplayFactory != null )
		levelDisplayFactory();
	if( coverDisplayFactory != null )
		coverDisplayFactory();
	if( sliderDisplayFactory != null )
		sliderDisplayFactory();
	if( countDisplayFactory != null )
		countDisplayFactory();
	if( elixirDisplayFactory != null )
		elixirDisplayFactory();
}

//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  BACKGROUND  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
protected function defaultBackgroundDisplayFactory() : ImageLoader 
{
	if( availablity != BuildingType.AVAILABLITY_NOT && type < 1000 )
		return null;
	
	if( backgroundDisaplay == null )
	{
		backgroundDisaplay = new ImageLoader();
		backgroundDisaplay.layoutData = new AnchorLayoutData(padding, padding, padding, padding);
		backgroundDisaplay.maintainAspectRatio = false;
		addChild(backgroundDisaplay);		
		backgroundDisaplay.source = Assets.getTexture("cards/popup-inside-background-skin", "gui");
	}
	return backgroundDisaplay;
}

//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  ICON  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
protected function defaultIconDisplayFactory() : ImageLoader 
{
	if( iconDisplay == null )
	{
		iconDisplay = new ImageLoader();
		iconDisplay.pixelSnapping = false;
		iconDisplay.layoutData = new AnchorLayoutData(padding, padding, padding, padding);
		addChild(iconDisplay);
	}

	if( availablity == BuildingType.AVAILABLITY_NOT )
	{
		iconDisplay.source = Assets.getTexture("cards/99", "gui");
	}
	else
	{
		if( availablity == BuildingType.AVAILABLITY_WAIT )
		{
			if( iconDisplay.filter == null )
			{
				var f:ColorMatrixFilter = new ColorMatrixFilter();
				f.adjustSaturation( -1 );
				iconDisplay.filter = f;
			}
		}
		iconDisplay.source = Assets.getTexture("cards/" + type, "gui");
	}
	return iconDisplay;
}


//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  LEVEL  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
protected function defaultLevelDisplayFactory() : RTLLabel
{
	if( !showLevel || !ResourceType.isBuilding(type) || availablity != BuildingType.AVAILABLITY_EXISTS || type < 0 || level <= 0 )
		return null;
	
	if( levelDisplay == null )
	{
		levelDisplay = new RTLLabel("Level " + level, rarity == 0?1:0, "center", null, false, null, 0.8);
		levelDisplay.alpha = 0.8;
		levelDisplay.height = 52 * appModel.scale;
		levelDisplay.layoutData = new AnchorLayoutData(NaN, padding, padding, padding);
		labelsContainer.addChild(levelDisplay);
	}
	else
	{
		levelDisplay.text = "Level "+ level;
	}
	
	if( levelBackground == null )
	{
		levelBackground = new ImageLoader();
		levelBackground.maintainAspectRatio = false
		levelBackground.source = Assets.getTexture("cards/rarity-skin-" + rarity, "gui");
		levelBackground.alpha = 0.7;
		levelBackground.height = padding * 3;
		levelBackground.layoutData = new AnchorLayoutData(NaN, padding, padding, padding);
		addChildAt(levelBackground, Math.min(1, numChildren));
	}
	else
	{
		levelBackground.source = Assets.getTexture("cards/rarity-skin-" + rarity, "gui");
	}
	return levelDisplay;
}


//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  COVER  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
private function defaultCoverDisplayFactory() : ImageLoader 
{
	if( coverDisplay == null )
	{
		coverDisplay = new ImageLoader();
		coverDisplay.scale9Grid = new Rectangle(60, 68, 4, 6);
		coverDisplay.source = Assets.getTexture("cards/bevel-card", "gui");
		coverDisplay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		addChild(coverDisplay);
	}
	return coverDisplay;
}

//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  SLIDER  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
protected function defaultSliderDisplayFactory() : BuildingSlider
{
	if( !showSlider || availablity || level <= 0 )
		return null;
	
	var building:Building = player.buildings.get(type);
	if( building == null )
		return null;
	var upgradeCards:int = building.get_upgradeCards();
	var numBuildings:int = player.resources.get(type);
	if( sliderDisplay != null )
	{
		sliderDisplay.maximum = upgradeCards;
		sliderDisplay.value = numBuildings;
		return sliderDisplay;
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
	return sliderDisplay;
}

//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  RARITY  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
protected function defaultRarityDisplayFactory() : ImageLoader
{
	if( rarity == 0 || availablity != BuildingType.AVAILABLITY_EXISTS )
		return null;
	
	if( rarityDisplay == null )
	{
		rarityDisplay = new ImageLoader();
		rarityDisplay.scale = appModel.scale;
		rarityDisplay.scale9Grid = new Rectangle(60, 68, 4, 6);
		rarityDisplay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		addChildAt(rarityDisplay, 0);
	}
	rarityDisplay.source = Assets.getTexture("cards/rarity-" + rarity, "gui");
	return levelBackground;
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