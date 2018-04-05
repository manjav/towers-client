package com.gerantech.towercraft.views.weapons
{
import com.gerantech.towercraft.managers.BaseManager;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.views.PlaceView;
import com.gerantech.towercraft.views.TroopView;
import com.gt.towers.constants.BuildingFeatureType;

import flash.utils.clearTimeout;
import flash.utils.setInterval;

import starling.events.Event;
import starling.events.EventDispatcher;

public class DefensiveWeapon extends BaseManager
{
private var placeView:PlaceView;
private var hitTimeoutId:uint;
private var disposed:Boolean;

private var damage:Number;
private var damageGap:Number;
private var damageRadiusMin:Number;
private var damageRadiusMax:Number;

public function DefensiveWeapon(placeView:PlaceView)
{
	this.placeView = placeView;
	damage			= game.calculator.get(BuildingFeatureType.F21_DAMAGE,			placeView.place.building.type, placeView.place.building.get_level(), placeView.place.building.improveLevel);
	damageGap		= game.calculator.get(BuildingFeatureType.F22_DAMAGE_GAP,		placeView.place.building.type, placeView.place.building.get_level(), placeView.place.building.improveLevel);
	damageRadiusMin = game.calculator.get(BuildingFeatureType.F23_RANGE_RADIUS_MIN,	placeView.place.building.type, placeView.place.building.get_level(), placeView.place.building.improveLevel);
	damageRadiusMax = game.calculator.get(BuildingFeatureType.F24_RANGE_RADIUS_MAX, placeView.place.building.type, placeView.place.building.get_level(), placeView.place.building.improveLevel);
	hitTimeoutId = setInterval(hitTestTroopsInterval, damageGap);
}

private function hitTestTroopsInterval():void
{
	if(disposed)
		return;
	//trace(placeView.place.index, "hitTest Troops Interval.")
	var tlen:int = AppModel.instance.battleFieldView.troopsList.length;
	var troop:TroopView;
	for(var i:int=0; i<tlen; i++)
	{
		troop = AppModel.instance.battleFieldView.troopsList[i];
		if( checkTriggerd(troop) )
		{
			AppModel.instance.sounds.addAndPlaySound("shot-tower");
			troop.hit(damage);
			dispatchEventWith(Event.TRIGGERED, false, troop);
			//dispatchEventWith(Event.TRIGGERED, false, troop);
			return;
		}	
	}
}		

private function checkTriggerd(troop:TroopView):Boolean
{
	if( troop.type == placeView.place.building.troopType )
		return false;
	
	var distance:Number = Math.sqrt(Math.pow(placeView.x-troop.x, 2) + Math.pow((placeView.y-troop.y)*1.25, 2));
	if( distance > damageRadiusMin && distance < damageRadiusMax )
		return true
	
	return false;
}

public function dispose():void
{
	disposed = true;
	clearTimeout(hitTimeoutId);
}
}
}