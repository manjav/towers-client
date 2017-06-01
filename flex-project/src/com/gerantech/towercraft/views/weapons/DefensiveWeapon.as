package com.gerantech.towercraft.views.weapons
{
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.views.PlaceView;
	import com.gerantech.towercraft.views.TroopView;
	
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	public class DefensiveWeapon extends EventDispatcher
	{
		private var placeView:PlaceView;
		private var hitTimeoutId:uint;

		public function DefensiveWeapon(placeView:PlaceView)
		{
			this.placeView = placeView;
			hitTimeoutId = setInterval(hitTestTroopsInterval, placeView.place.building.get_damageGap());
		}
		
		private function hitTestTroopsInterval():void
		{
			var tlen:int = AppModel.instance.battleField.troopsContainer.length;
			var troop:TroopView;
			for(var i:int=0; i<tlen; i++)
			{
				troop = AppModel.instance.battleField.troopsContainer[i];
				if(checkTriggerd(troop))
				{
					troop.hit(placeView.place.building.get_damage());
					dispatchEventWith(Event.TRIGGERED, false, troop);
					return;
				}	
			}
		}		
		
		private function checkTriggerd(troop:TroopView):Boolean
		{
			if(troop.type == placeView.place.building.troopType || troop.muted)
				return false;
			
			var distance:Number = Math.sqrt(Math.pow(troop.x-placeView.x, 2) + Math.pow(troop.y-placeView.y, 2));
			if(distance < 50 && distance > 0.5)
				return true
			
			return false;
		}		
		
		public function dispose():void
		{
			clearTimeout(hitTimeoutId);
		}
	}
}