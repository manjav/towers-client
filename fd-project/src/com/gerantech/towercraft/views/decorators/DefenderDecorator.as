package com.gerantech.towercraft.views.decorators
{
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.views.PlaceView;
import com.gerantech.towercraft.views.TroopView;
import com.gt.towers.constants.BuildingFeatureType;
import com.gt.towers.constants.BuildingType;

import flash.utils.setTimeout;

import starling.core.Starling;
import starling.display.Image;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.events.Event;
import starling.utils.MathUtil;

public class DefenderDecorator extends BuildingDecorator
{
protected var damage:Number;
protected var damageRadiusMin:Number;
protected var damageRadiusMax:Number;
private var crystalTexture:String;
private var crystalDisplay:MovieClip;
private var radiusDisplay:Image;
private var rayImage:Image;
private var raySprite:Sprite;
private var lightingDisplay:MovieClip;

public function DefenderDecorator(placeView:PlaceView)
{
	super(placeView);
}

override public function updateElements(population:int, troopType:int):void
{
	super.updateElements(population, troopType);

	damage			= game.calculator.get(BuildingFeatureType.F21_DAMAGE,			placeView.place.building.type, placeView.place.building.get_level(), placeView.place.building.improveLevel);
	damageRadiusMin = game.calculator.get(BuildingFeatureType.F23_RANGE_RADIUS_MIN,	placeView.place.building.type, placeView.place.building.get_level(), placeView.place.building.improveLevel);
	damageRadiusMax = game.calculator.get(BuildingFeatureType.F24_RANGE_RADIUS_MAX, placeView.place.building.type, placeView.place.building.get_level(), placeView.place.building.improveLevel);
	
	// radius :
	createRadiusDisplay();
	radiusDisplay.width = damageRadiusMax * 2;
	radiusDisplay.scaleY = radiusDisplay.scaleX * 0.8;

	// ray
	createRayDisplay();
	rayImage.scale = damage * 0.7;
	
	// lighting
	createLightingDisplay();
	lightingDisplay.scale = damage ;
}

private function get_crystalHeight():Number
{
	if( place.building.type == BuildingType.B42_CRYSTAL )
		return 90;
	else if( place.building.type == BuildingType.B43_CRYSTAL )
		return 96;
	else if( place.building.type == BuildingType.B44_CRYSTAL )
		return 102;
	return 84;
}

private function createRadiusDisplay():void
{
	if( radiusDisplay != null )
		return;
	
	radiusDisplay = new Image(Assets.getTexture("damage-range"));
	radiusDisplay.touchable = false;
	radiusDisplay.alignPivot()
	radiusDisplay.x = parent.x;
	radiusDisplay.y = parent.y;
	fieldView.buildingsContainer.addChildAt(radiusDisplay, 0);
}

private function createRayDisplay():void
{
	if( raySprite != null )
		return;
	
	raySprite = new Sprite();
	raySprite.visible = false;
	raySprite.touchable = false;
	raySprite.x = parent.x;
	raySprite.y = parent.y - get_crystalHeight();
	fieldView.buildingsContainer.addChild(raySprite);
	
	rayImage = new Image(Assets.getTexture("crystal-ray"));
	rayImage.touchable = false;
	rayImage.alignPivot("center", "bottom");
	raySprite.addChild(rayImage);
	
	placeView.defensiveWeapon.addEventListener(Event.TRIGGERED, defensiveWeapon_triggeredHandler);
}

private function createLightingDisplay():void
{
	if( lightingDisplay != null )
		return;
	
	lightingDisplay = new MovieClip(Assets.getTextures("crystal-lighting"));
	lightingDisplay.visible = false; 
	lightingDisplay.touchable = false;
	lightingDisplay.pivotX = lightingDisplay.width * 0.5;
	lightingDisplay.pivotY = lightingDisplay.height * 0.5;
	fieldView.buildingsContainer.addChild(lightingDisplay);
}


private function defensiveWeapon_triggeredHandler(event:Event):void
{
	var troop:TroopView = event.data as TroopView;
	
	raySprite.visible = true;
	var dx:Number = troop.x-raySprite.x;
	var dy:Number = troop.y-raySprite.y;
	rayImage.height = Math.sqrt( dx*dx + dy*dy );
	raySprite.rotation = MathUtil.normalizeAngle(-Math.atan2(-dx, -dy));
	
	lightingDisplay.x = troop.x;
	lightingDisplay.y = troop.y;
	lightingDisplay.play();
	lightingDisplay.visible = true;
	Starling.juggler.add(lightingDisplay);
	
	setTimeout(function():void { raySprite.visible = false;}, 100);
	setTimeout(function():void { 
		
		Starling.juggler.remove(lightingDisplay);
		lightingDisplay.stop();
		lightingDisplay.visible = false; 
	}, 300);
}



override public function dispose():void
{
	if(crystalDisplay != null)
		crystalDisplay.removeFromParent(true);
	if(radiusDisplay != null)
		radiusDisplay.removeFromParent(true);
	if(placeView.defensiveWeapon != null)
		placeView.defensiveWeapon.removeEventListener(Event.TRIGGERED, defensiveWeapon_triggeredHandler);
	super.dispose();
}
}
}