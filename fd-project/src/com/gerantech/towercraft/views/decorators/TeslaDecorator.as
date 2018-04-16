package com.gerantech.towercraft.views.decorators 
{
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.views.PlaceView;
import com.gerantech.towercraft.views.TroopView;
import com.gt.towers.constants.BuildingType;
import flash.geom.Point;
import flash.utils.setTimeout;
import starling.core.Starling;
import starling.display.Image;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.events.Event;
import starling.utils.MathUtil;
/**
 * ...
 * @author MAnsour Djawadi
 */
public class TeslaDecorator extends DefenderDecorator
{
	
private var rayImage:Image;
private var raySprite:Sprite;
private var lightingDisplay:MovieClip;
private var coils:Vector;

public function TeslaDecorator(placeView:PlaceView) { super(placeView); }

override public function updateElements(population:int, troopType:int):void
{
	super.updateElements(population, troopType);
	
	// ray
	createRayDisplay();
	rayImage.scale = damage * 0.7;

	// lighting
	createLightingDisplay();
	lightingDisplay.scale = damage ;
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
	
	//coils = new Vector.<Point>();

}

override protected function defensiveWeapon_triggeredHandler(event:Event):void
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

}
}