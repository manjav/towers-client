package com.gerantech.towercraft.views.decorators 
{
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.views.PlaceView;
import com.gerantech.towercraft.views.TroopView;
import com.gt.towers.constants.BuildingType;
import flash.geom.Point;
import flash.utils.setTimeout;
import starling.core.Starling;
import starling.display.Canvas;
import starling.display.Image;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.events.Event;
import starling.utils.MathUtil;
/**
 * ...
 * @author Mansour Djawadi
 */
public class TeslaDecorator extends DefenderDecorator
{
private var rays:Vector.<LightRay>;
private var lightingDisplay:MovieClip;
public function TeslaDecorator(placeView:PlaceView) { super(placeView); }
override protected function update(population:int, troopType:int, occupied:Boolean) : void
{
	super.update(population, troopType, occupied);
	
	// rays
	createLightRays();

	// lighting
	createLightingDisplay();
	lightingDisplay.scale = damage;
	
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

override protected function defensiveWeapon_triggeredHandler(event:Event):void
{
	var coilIndex:int = event.data[0] as int;
	var troop:TroopView = event.data[1] as TroopView;
	var dx:Number = troop.x - rays[coilIndex].x;
	var dy:Number = troop.y - rays[coilIndex].y;
	
	rays[coilIndex].show(MathUtil.normalizeAngle( -Math.atan2( -dx, -dy)), Math.sqrt( dx * dx + dy * dy ));
	
	lightingDisplay.x = troop.x;
	lightingDisplay.y = troop.y;
	lightingDisplay.play();
	lightingDisplay.visible = true;
	Starling.juggler.add(lightingDisplay);
	
	setTimeout(function():void { if( rays != null ) rays[coilIndex].hide();}, 100);
	setTimeout(function():void { 	
		Starling.juggler.remove(lightingDisplay);
		lightingDisplay.stop();
		lightingDisplay.visible = false; 
	}, 240);
}

private function createLightRays() : void
{
	if( rays != null )
		return;
	
	var coils:Vector.<Point> = new Vector.<Point>();
	switch( place.building.type )
	{
		case BuildingType.B44_CRYSTAL:
			coils.push(new Point( -27, -24)); coils.push(new Point( -27, 24)); coils.push( new Point(27, -24)); coils.push( new Point(27, 24));
			break;
		case BuildingType.B43_CRYSTAL:
			coils.push(new Point( -24, 22)); coils.push(new Point( 24, 22)); coils.push( new Point(0, -17));
			break;
		case BuildingType.B42_CRYSTAL:
			coils.push(new Point( -20, -17)); coils.push(new Point( 20, 17));
			break;
		case BuildingType.B41_CRYSTAL:
			coils.push(new Point(0, 0));
			break;
	}
	
	var ray:LightRay;
	rays = new Vector.<LightRay>();
	for each ( var p:Point in coils )
	{
		ray = new LightRay();
		ray.x = place.x + p.x;
		ray.y = place.y + p.y - 84;
		fieldView.buildingsContainer.addChild(ray);
		rays.push(ray);
	}
}

override public function dispose():void
{
	if( rays != null )
	{
		for each ( var l:LightRay in rays )
			l.removeFromParent(true);
		rays = null;
	}
	
	if( lightingDisplay != null )
		lightingDisplay.removeFromParent(true);
	super.dispose();
}
}
}