package com.gerantech.towercraft.views
{
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.views.decorators.PlaceDecorator;
	import com.gt.towers.Game;
	import com.gt.towers.buildings.Building;
	import com.gt.towers.utils.lists.PlaceList;
	
	import flash.utils.setTimeout;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	
	public class TroopView extends MovieClip
	{
		private var type:int;
		private var building:Building;
		private var path:Vector.<PlaceDecorator>;
		private var direction:String;
	
		public function TroopView(building:Building, path:PlaceList)
		{
			this.building = building;
			this.type = building.troopType;
			
			var ttype:String = type == Game.get_instance().get_player().troopType?"DwarfBaseUp_":"Dwarf4A_Move_";
			super(Assets.getTextures(ttype+"Move_Up"), 30);
			alignPivot();
			
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
			swtchAnimation(next);
			//play();
			Starling.juggler.add(this);
			Starling.juggler.tween(this, building.get_troopSpeed()/1000, {x:next.x, y:next.y, onComplete:onTroopArrived, onCompleteArgs:[next]});
			return true;
		}
		
		private function swtchAnimation(next:PlaceDecorator):void
		{
			var dir:String = "Up";
			if(x == next.x)
			{
				scaleX = 1;
				if(y > next.y)
					dir = "Down";
			}
			else
			{
				dir = "Right";
				scaleX = x > next.x ? -1 : 1;
			}
			
			if(direction == dir)
				return;
			
			direction = dir;
			var ttype:String = type == Game.get_instance().get_player().troopType?"DwarfBaseUp_Move_":"Dwarf4A_Move_";
			//trace(ttype+direction+(i>8 ? "_0"+(i+1) : "_00"+(i+1)))
			for(var i:int=0; i < numFrames; i++)
				setFrameTexture(i, Assets.getTexture(ttype+direction+(i>8 ? "_0"+(i+1) : "_00"+(i+1))));
		}
		private function onTroopArrived(next:PlaceDecorator):void
		{
			Starling.juggler.remove(this);
			//stop();
			setTimeout(next.rush, building.get_exitGap(), this);
		}
	}
}