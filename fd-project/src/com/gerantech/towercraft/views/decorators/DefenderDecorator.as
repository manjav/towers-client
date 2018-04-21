package com.gerantech.towercraft.views.decorators
{
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.views.PlaceView;
import com.gt.towers.constants.BuildingFeatureType;
import com.gt.towers.constants.TroopType;
import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.events.Event;

public class DefenderDecorator extends BuildingDecorator
{
protected var damage:Number;
protected var damageRadiusMax:Number;
protected var damageRadiusMin:Number;
private var radiusMaxDisplay:Image;
private var radiusMinDisplay:Image;
private var radiusScale:Number;

public function DefenderDecorator(placeView:PlaceView) { super(placeView); }
override public function updateElements(population:int, troopType:int):void
{
	super.updateElements(population, troopType);

	damage			= game.calculator.get(BuildingFeatureType.F21_DAMAGE,			placeView.place.building.type, placeView.place.building.get_level(), placeView.place.building.improveLevel);
	damageRadiusMax = game.calculator.get(BuildingFeatureType.F24_RANGE_RADIUS_MAX, placeView.place.building.type, placeView.place.building.get_level(), placeView.place.building.improveLevel);
	damageRadiusMin = game.calculator.get(BuildingFeatureType.F23_RANGE_RADIUS_MIN,	placeView.place.building.type, placeView.place.building.get_level(), placeView.place.building.improveLevel);
	
	// radius :
	createRadiusDisplay(troopType);
}

private function createRadiusDisplay(troopType:int):void
{
	if( radiusMaxDisplay == null )
	{
		radiusMaxDisplay = new Image(Assets.getTexture("redius-max", "troops"));
		radiusMaxDisplay.name = "max"
		radiusMaxDisplay.touchable = false;
		radiusMaxDisplay.alignPivot()
		radiusMaxDisplay.x = place.x;
		radiusMaxDisplay.y = place.y;
		radiusMaxDisplay.alpha = 0.5;
		radiusMaxDisplay.width = damageRadiusMax * 2;
		radiusMaxDisplay.scaleY = radiusMaxDisplay.scaleX;
		fieldView.roadsContainer.addChild(radiusMaxDisplay);
		fade(radiusMaxDisplay, 0.4, 2, false);
	}
	if( radiusMinDisplay == null )
	{
		radiusMinDisplay = new Image(Assets.getTexture("redius-min", "troops"));
		radiusMinDisplay.name = "min"
		radiusMinDisplay.touchable = false;
		radiusMinDisplay.alignPivot()
		radiusMinDisplay.x = place.x;
		radiusMinDisplay.y = place.y;
		radiusMinDisplay.alpha = 0.5;
		radiusMinDisplay.width = damageRadiusMin * 5;
		radiusScale = radiusMinDisplay.scaleY = radiusMinDisplay.scaleX;
		fieldView.roadsContainer.addChild(radiusMinDisplay);
		fade(radiusMinDisplay, 0.4, 3, true);
	}

	radiusMaxDisplay.color = TroopType.getColor(troopType);
	radiusMinDisplay.color = TroopType.getColor(troopType);
}

private function fade(display:DisplayObject, _alpha:Number, _delay:Number, _scalable:Boolean) : void
{
	var tw:Tween = new Tween(display, 3, Transitions.EASE_IN_OUT);
	tw.delay = _delay;
	tw.fadeTo(_alpha);
	if( _scalable )
		tw.scaleTo(display.scale == radiusScale ? radiusScale * 2 : radiusScale);
	tw.onComplete = fade;
	tw.onCompleteArgs = [display, _alpha == 1?0.4:1, 2, _scalable];
	Starling.juggler.add(tw);
}

protected function defensiveWeapon_triggeredHandler(event:Event):void { }
override public function dispose():void
{
	if( radiusMaxDisplay != null )
	{
		Starling.juggler.removeTweens(radiusMaxDisplay);
		radiusMaxDisplay.removeFromParent(true);
	}
	if( radiusMinDisplay != null )
	{
		Starling.juggler.removeTweens(radiusMinDisplay);
		radiusMinDisplay.removeFromParent(true);
	}
	if( placeView.defensiveWeapon != null )
		placeView.defensiveWeapon.removeEventListener(Event.TRIGGERED, defensiveWeapon_triggeredHandler);
	super.dispose();
}
}
}