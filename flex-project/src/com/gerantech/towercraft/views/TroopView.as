package com.gerantech.towercraft.views
{
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.Game;
	import com.gt.towers.buildings.Building;
	import com.gt.towers.buildings.Place;
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
		private var textureType:String;
	
		public function TroopView(building:Building, path:PlaceList)
		{
			this.id = building.place.getIncreasedId();
			this.type = building.troopType;
			this.building = building;
			this.health = building.get_troopPower();
			
			textureType = type == Game.get_instance().get_player().troopType?"0/troop-0-move-":"1/troop-1-move-";
			super(Assets.getTextures(textureType+"down", "troops"), 20);
			this.scale = AppModel.instance.scale * 2;
			alignPivot();
			
			touchable = false;
			
			this.path = new Vector.<PlaceView>();
			for (var p:uint=0; p<path.size(); p++)
				this.path.push(AppModel.instance.battleFieldView.places[path.get(p).index]);
		}
		
		public function rush(source:Place):void
		{
			var next:PlaceView = path.shift();
			if(next == null)
			{
				removeFromParent(true);
				return;
			}
			
			switchAnimation(source, next.place);
			visible = true;
			Starling.juggler.add(this);
			
			var distance:Number = Math.sqrt(Math.pow(source.x-next.place.x, 2) + Math.pow(source.y-next.place.y, 2)) / 300; //trace(source.x, next.place.x, source.y, next.place.y, distance)
			Starling.juggler.tween(this, (building.get_troopSpeed()/1000) * distance, {x:next.x, y:next.y - 30 * AppModel.instance.scale, onComplete:onTroopArrived, onCompleteArgs:[next]});
		}
		private function onTroopArrived(next:PlaceView):void
		{
			visible = false;
			Starling.juggler.remove(this);
			if(next.place.building.troopType == type)
				rushTimeoutId = setTimeout(next.rush, building.get_exitGap(), this);
		}
		
		private function switchAnimation(source:Place, destination:Place):void
		{
			var rad:Number = Math.atan2(destination.x-source.x, destination.y-source.y);//trace(rad)
			var flipped:Boolean = false;
			var dir:String = "down";

			if(rad >= Math.PI * -0.125 && rad < Math.PI * 0.125)
				dir = "down";
			else if(rad <= Math.PI * -0.125 && rad > Math.PI * -0.375)//625 875
				dir = "leftdown";
			else if(rad <= Math.PI * -0.375 && rad > Math.PI * -0.625)
				dir = "left";
			else if(rad <= Math.PI * -0.625 && rad > Math.PI * -0.875)
				dir = "leftup";
			else if(rad >= Math.PI * 0.125 && rad < Math.PI * 0.375)
				dir = "rightdown";
			else if(rad >= Math.PI * 0.375 && rad < Math.PI * 0.625)
				dir = "right";
			else if(rad >= Math.PI * 0.625 && rad < Math.PI * 0.875)
				dir = "rightup";
			else
				dir = "up";
			
			if(dir == "leftdown" || dir == "left" || dir == "leftup")
			{
				dir = dir.replace("left", "right");
				flipped = true;
			}

			scaleX = (flipped ? -1 : 1 ) * Math.abs(scaleX);
			
			if(direction == dir)
				return;

			fps = 40000/building.get_troopSpeed();
			direction = dir;
			//trace(textureType + direction)
			for(var i:int=0; i < numFrames; i++)
				setFrameTexture(i, Assets.getTexture(textureType + direction+(i>8 ? "-0"+(i+1) : "-00"+(i+1)), "troops"));
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