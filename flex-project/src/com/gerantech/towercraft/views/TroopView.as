package com.gerantech.towercraft.views
{
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.views.decorators.PlaceDecorator;
	import com.gt.towers.Game;
	import com.gt.towers.others.BalancingData;
	import com.gt.towers.utils.lists.PlaceList;
	
	import flash.utils.setTimeout;
	
	import starling.core.Starling;
	import starling.display.Image;
	
	public class TroopView extends Image
	{
		private var troopType:int;
		private var path:Vector.<PlaceDecorator>;
	
		public function TroopView(troopType:int, path:PlaceList)
		{
			super(Assets.getTexture("troop" + (troopType == Game.get_instance().get_player().troopType?"-b":"-r")));
			alignPivot();
			
			this.troopType = troopType;
			
			touchable = false;
			this.path = new Vector.<PlaceDecorator>();
			for (var p:uint=0; p<path.size(); p++)
				this.path.push(AppModel.instance.battleField.places[path.get(p).index]);

		}
		
		public function rush():Boolean
		{
			var next:PlaceDecorator = path.shift();
			if(next == null)
			{
				removeFromParent(true);
				//trace("fine", type);
				return false;
			}
			
			Starling.juggler.tween(this, BalancingData.RUSH_TIME/1000, {x:next.x, y:next.y, onComplete:onTroopArrived, onCompleteArgs:[next]});
			return true;
		}
		private function onTroopArrived(next:PlaceDecorator):void
		{
			setTimeout(next.rush, BalancingData.RUSH_GAP, this);
		}
	}
}