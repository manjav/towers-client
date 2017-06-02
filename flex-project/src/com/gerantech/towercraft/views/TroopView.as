package com.gerantech.towercraft.views
{
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.Game;
	import com.gt.towers.buildings.Building;
	import com.gt.towers.utils.lists.PlaceList;
	
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.events.Event;
	
	public class TroopView extends MovieClip
	{
		public var id:int;
		public var type:int;
		public var health:Number;
		
		private var path:Vector.<PlaceView>;
		private var building:Building;
		
		private var direction:String;
		private var rushTimeoutId:uint;
	
		public function TroopView(building:Building, path:PlaceList)
		{
			this.id = building.place.getIncreasedId();
			this.type = building.troopType;
			this.building = building;
			this.health = building.get_troopPower();
			
			var ttype:String = type == Game.get_instance().get_player().troopType?"DwarfBaseUp_":"Dwarf4A_";
			super(Assets.getTextures(ttype+"Move_Up"), 20);
			alignPivot();
			
			touchable = false;
			
			this.path = new Vector.<PlaceView>();
			for (var p:uint=0; p<path.size(); p++)
				this.path.push(AppModel.instance.battleField.places[path.get(p).index]);
		}
		
		public function rush():void
		{
			var next:PlaceView = path.shift();
			if(next == null)
			{
				removeFromParent(true);
				return;
			}
			
			switchAnimation(next);
			//play();
			visible = true;
			Starling.juggler.add(this);
			Starling.juggler.tween(this, building.get_troopSpeed()/1000, {x:next.x, y:next.y, onComplete:onTroopArrived, onCompleteArgs:[next]});
		}
		private function onTroopArrived(next:PlaceView):void
		{
			visible = false;
			Starling.juggler.remove(this);
			//stop();
			if(next.place.building.troopType == type)
				rushTimeoutId = setTimeout(next.rush, building.get_exitGap(), this);
		}
		
		private function switchAnimation(next:PlaceView):void
		{
			var dir:String = "Up";
			if(x == next.x)
			{
				if(scaleX < 0 )
					scaleX *= -1;
				if(y > next.y)
					dir = "Down";
			}
			else
			{
				dir = "Right";
				scaleX *= (x > next.x ? -1 : 1);
			}
			if(direction == dir)
				return;
			fps = 40000/building.get_troopSpeed();
			direction = dir;
			var ttype:String = type == Game.get_instance().get_player().troopType?"DwarfBaseUp_Move_":"Dwarf4A_Move_";
			//trace(ttype+direction+(i>8 ? "_0"+(i+1) : "_00"+(i+1)))
			for(var i:int=0; i < numFrames; i++)
				setFrameTexture(i, Assets.getTexture(ttype+direction+(i>8 ? "_0"+(i+1) : "_00"+(i+1))));
		}

		
		public function hit(damage:Number):void
		{
			health -= damage;
			if(health > 0)
				return;
			
			muted = true;
			dispatchEventWith(Event.TRIGGERED);
			
			Starling.juggler.remove(this);
			Starling.juggler.removeTweens(this);
			Starling.juggler.tween(this, 0.2, {x:x+50, y:y-40, onComplete:onTroopKilled, transition:Transitions.EASE_OUT});
		}
		private function onTroopKilled():void
		{
			removeFromParent(true);
		}
		
		override public function dispose():void
		{
			clearTimeout(rushTimeoutId);
			super.dispose();
		}
	}
}