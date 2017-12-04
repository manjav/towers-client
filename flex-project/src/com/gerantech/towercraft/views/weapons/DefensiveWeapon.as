package com.gerantech.towercraft.views.weapons
{
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.views.PlaceView;
import com.gerantech.towercraft.views.TroopView;

import flash.utils.clearTimeout;
import flash.utils.setInterval;

import starling.events.Event;
import starling.events.EventDispatcher;

public class DefensiveWeapon extends EventDispatcher
{
private var placeView:PlaceView;
private var hitTimeoutId:uint;
private var disposed:Boolean;

public function DefensiveWeapon(placeView:PlaceView)
{
	this.placeView = placeView;
	hitTimeoutId = setInterval(hitTestTroopsInterval, placeView.place.building.damageGap);
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
			troop.hit(placeView);
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
	if( distance > placeView.place.building.damageRangeMin && distance < placeView.place.building.damageRangeMax )
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