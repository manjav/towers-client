package com.gerantech.towercraft.views.weapons
{
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.views.PlaceView;
	import com.gerantech.towercraft.views.TroopView;
	
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	
	public class DefensiveWeapon 
	{
		private var placeView:PlaceView;
		private var hitTimeoutId:uint;
		private var disposed:Boolean;

		public function DefensiveWeapon(placeView:PlaceView)
		{
			//trace(placeView.place.index, "DefensiveWeapon")
			this.placeView = placeView;
			hitTimeoutId = setInterval(hitTestTroopsInterval, placeView.place.building.get_damageGap());
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
				if(checkTriggerd(troop))
				{
					AppModel.instance.sounds.addAndPlaySound("shot-tower");
					troop.hit(placeView);
					//dispatchEventWith(Event.TRIGGERED, false, troop);
					return;
				}	
			}
		}		
		
		private function checkTriggerd(troop:TroopView):Boolean
		{
			if( troop.type == placeView.place.building.troopType )
				return false;
			
			var distance:Number = Math.sqrt(Math.pow(placeView.x-troop.x, 2) + Math.pow((placeView.y-troop.y)*1.2, 2));
			if(distance < placeView.place.building.get_damageRadius() && distance > 0.5)
				return true
			
			return false;
		}		
		
		public function dispose():void
		{
			//trace(placeView.place.index, "defensive weapon disposed.")
			disposed = true;
			clearTimeout(hitTimeoutId);
		}
	}
}