package com.gerantech.towercraft.controls
{
import com.gerantech.towercraft.controls.sliders.BuildingSlider;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gt.towers.battle.units.Card;
import com.gt.towers.constants.CardFeatureType;
import com.gt.towers.constants.CardTypes;
import com.gt.towers.constants.ResourceType;
import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;
import starling.textures.TextureSmoothing;

public class BuildingCard extends TowersLayout
{
public static var VERICAL_SCALE:Number = 1.25;

public var backgroundDisplayFactory:Function;
public var iconDisplayFactory:Function;
public var levelDisplayFactory:Function;
public var sliderDisplayFactory:Function;
public var countDisplayFactory:Function;
public var elixirDisplayFactory:Function;
public var rarityDisplayFactory:Function;
public var coverDisplayFactory:Function;

public var type:int = -1;
public var level:int = 0;
public var rarity:int = 0;
public var count:int = 0;
public var elixirSize:int = 0;
public var availablity:int = 0;

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
protected var countDisplay:ShadowLabel;

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
	padding = 16;
	
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
	if( countDisplayFactory == null )
		countDisplayFactory = defaultCountDisplayFactory;
	if( elixirDisplayFactory == null )
		elixirDisplayFactory = defaultElixirDisplayFactory;
	if( rarityDisplayFactory == null )
		rarityDisplayFactory = defaultRarityDisplayFactory;
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
public function setData(type:int, level:int = 1, count:int = 1):void
{
	if( this.type == type && this.level == level && this.count == count )
		return;
	
	if( type < 0 )
		return;
	
	this.type = type;
	this.availablity = game.getBuildingAvailablity(type);
	if( ResourceType.isCard(type) )
		this.level = this.availablity == CardTypes.AVAILABLITY_EXISTS && level == 1 ? player.cards.get(type).level : level;
	this.rarity = game.calculator.getInt(CardFeatureType.F00_RARITY, type, 1);
	this.count = count;// != 1 ? building.troopsCount : count;
	this.elixirSize = game.calculator.getInt(CardFeatureType.F02_ELIXIR_SIZE, type, 1);
	callFactories();
}

private function callFactories() : void 
{
	//if( backgroundDisplayFactory != null )
	//	backgroundDisplayFactory();
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
	if( rarityDisplayFactory != null )
		rarityDisplayFactory();
}

//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  BACKGROUND  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
protected function defaultBackgroundDisplayFactory() : ImageLoader 
{
	if( availablity != CardTypes.AVAILABLITY_NOT && type < 1000 )
		return null;
	
	if( backgroundDisaplay == null )
	{
		backgroundDisaplay = new ImageLoader();
		backgroundDisaplay.color = 0xAAAA77;
		backgroundDisaplay.layoutData = new AnchorLayoutData(padding, padding, padding, padding);
		backgroundDisaplay.scale9Grid = MainTheme.SMALL_BACKGROUND_SCALE9_GRID;
		backgroundDisaplay.source = Assets.getTexture("theme/popup-inside-background-skin", "gui");
		addChildAt(backgroundDisaplay, 0);		
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

	if( availablity != CardTypes.AVAILABLITY_EXISTS )
	{
		if( iconDisplay.filter == null )
		{
		/*	var f:ColorMatrixFilter = new ColorMatrixFilter();
			f.adjustSaturation( -1 );
			iconDisplay.filter = f;*/
		}
	}
	else
	{
		iconDisplay.filter = null;
	}
	iconDisplay.source = Assets.getTexture("cards/" + type, "gui");
	return iconDisplay;
}


//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  LEVEL  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
protected function defaultLevelDisplayFactory() : RTLLabel
{
	if( !showLevel || !ResourceType.isCard(type) || availablity != CardTypes.AVAILABLITY_EXISTS || type < 0 || level <= 0 )
		return null;
	
	if( levelDisplay == null )
	{
		levelDisplay = new RTLLabel("Level " + level, rarity == 0?1:0, "center", null, false, null, 0.8);
		levelDisplay.alpha = 0.8;
		levelDisplay.height = 52;
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
	
	var building:Card = player.cards.get(type);
	if( building == null )
		return null;
	var upgradeCards:int = Card.get_upgradeCards(building.level, building.rarity);
	var numBuildings:int = player.resources.get(type);
	if( sliderDisplay != null )
	{
		sliderDisplay.maximum = upgradeCards;
		sliderDisplay.value = numBuildings;
		return sliderDisplay;
	}
	sliderDisplay = new BuildingSlider();
	sliderDisplay.height = padding * 3;
	sliderDisplay.layoutData = new AnchorLayoutData(NaN, padding * 0.3, -padding * 2.8, padding * 0.3);
	sliderDisplay.addEventListener(FeathersEventType.CREATION_COMPLETE, function():void{
		sliderDisplay.labelDisplay.layoutData = new AnchorLayoutData(NaN, padding * 2, -padding * 3, padding * (building.upgradable(0)?4:2));
		labelsContainer.addChild(sliderDisplay.labelDisplay);
		sliderDisplay.maximum = upgradeCards;
		sliderDisplay.value = numBuildings;
	});
	addChild(sliderDisplay);
	return sliderDisplay;
}
public function punchSlider() : void
{
	if( sliderDisplay != null )
	{
		sliderDisplay.labelDisplay.scale = 1.5;
		Starling.juggler.tween(sliderDisplay.labelDisplay, 0.5, {scale:1, transition:Transitions.EASE_OUT});
	}
}

//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  RARITY  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
protected function defaultRarityDisplayFactory() : ImageLoader
{
	if ( rarity == 0 || availablity != CardTypes.AVAILABLITY_EXISTS )
	{
		if( rarityDisplay != null )
			rarityDisplay.removeFromParent();
		return null;
	}
	if( rarityDisplay == null )
	{
		rarityDisplay = new ImageLoader();
		rarityDisplay.touchable = false;
		rarityDisplay.scale9Grid = new Rectangle(60, 68, 4, 6);
		rarityDisplay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	}
	addChildAt(rarityDisplay, 0);
	rarityDisplay.source = Assets.getTexture("cards/rarity-" + rarity, "gui");
	return rarityDisplay;
}
//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  COUNT  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
protected function defaultCountDisplayFactory() : ShadowLabel
{
	if( !showCount || availablity != CardTypes.AVAILABLITY_EXISTS || type < 0 || count < 1 )
		return null;
	
	if( countDisplay == null )
	{
		countDisplay = new ShadowLabel("x " + count);
		countDisplay.layoutData = new AnchorLayoutData(NaN, padding * 1.6, padding * 0.8);
		labelsContainer.addChild(countDisplay);
		return countDisplay;
	}
	countDisplay.text = "x "+ count;
	return countDisplay;
}


//       _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  ELIXIR SIZE  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
protected function defaultElixirDisplayFactory():void
{
	if( !showElixir || availablity == CardTypes.AVAILABLITY_NOT || level <= 0 )
		return;
	
	var elixirBackground:ImageLoader = new ImageLoader();
	elixirBackground.source = Assets.getTexture("cards/elixir-" + elixirSize, "gui");
	elixirBackground.width = elixirBackground.height = 90;
	elixirBackground.layoutData = new AnchorLayoutData( -padding * 0.5, NaN, NaN, -padding * 0.3);
	addChild(elixirBackground);
}
}
}