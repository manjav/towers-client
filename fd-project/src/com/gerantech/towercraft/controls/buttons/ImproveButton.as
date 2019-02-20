package com.gerantech.towercraft.controls.buttons
{
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.buildings.Building;
import com.gt.towers.constants.BuildingType;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.filters.ColorMatrixFilter;

public class ImproveButton extends SimpleLayoutButton
{
static public const WIDTH:int = 120;
static public const HEIGHT:int = 136;
public var building:Building;
public var type:int;
private var disableFilter:ColorMatrixFilter;
private var iconDisplay:ImageLoader;
private var coverDisplay:ImageLoader;
public var locked:Boolean;
public var improvable:Boolean = true;

public function ImproveButton(building:Building, type:int)
{
	super();
	this.building = building;
	this.type = type;
	this.width = WIDTH;
	this.height = HEIGHT;
	this.locked = !building.unlocked(type);
}

override protected function initialize() : void
{
	super.initialize();
	layout = new AnchorLayout();
	var t:int = type + 0;
	
	if( t == -2 )
		t = building.category + Math.min(4, building.improveLevel + 1);
	
	disableFilter = new ColorMatrixFilter();
	disableFilter.adjustSaturation(-1);
	
	iconDisplay = new ImageLoader();
	iconDisplay.touchable = false;
	iconDisplay.source = Assets.getTexture("cards/improves/" + t, "gui");
	iconDisplay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChild(iconDisplay);
	
	coverDisplay = new ImageLoader();
	coverDisplay.source = Assets.getTexture("cards/improves/bevel-card", "gui")
	coverDisplay.scale9Grid = new Rectangle(23, 23, 2, 2);
	coverDisplay.layoutData = new AnchorLayoutData(-8, -8, -8, -8);
	addChild(coverDisplay);
	
	if( locked )
	{
		var lockDisplay:ImageLoader = new ImageLoader();
		lockDisplay.touchable = false;
		//lockDisplay.width = lockDisplay.height = size * 0.6;
		//lockDisplay.x = lockDisplay.y = -size * 0.7;
		lockDisplay.source = Assets.getTexture("cards/improves/lock", "gui");
		addChild(lockDisplay);
	}
	
	renable();
}

public function renable():void
{
	setEnable(building.improvable(type));
}
private function setEnable(value:Boolean):void
{
	if( improvable == value || iconDisplay == null )
		return;
	trace(type, "improvable:", improvable, "value", value, "locked", locked)
	improvable = value;
	iconDisplay.filter = improvable ? null : disableFilter;
}
}
}