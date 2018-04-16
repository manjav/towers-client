package com.gerantech.towercraft.views.decorators
{
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.views.PlaceView;
import com.gt.towers.constants.BuildingFeatureType;
import starling.display.Image;
import starling.events.Event;

public class DefenderDecorator extends BuildingDecorator
{
protected var damage:Number;
protected var damageRadiusMin:Number;
protected var damageRadiusMax:Number;
private var radiusDisplay:Image;

public function DefenderDecorator(placeView:PlaceView) { super(placeView); }
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

protected function defensiveWeapon_triggeredHandler(event:Event):void { }
override public function dispose():void
{
	if( radiusDisplay != null )
		radiusDisplay.removeFromParent(true);
	if( placeView.defensiveWeapon != null )
		placeView.defensiveWeapon.removeEventListener(Event.TRIGGERED, defensiveWeapon_triggeredHandler);
	super.dispose();
}
}
}