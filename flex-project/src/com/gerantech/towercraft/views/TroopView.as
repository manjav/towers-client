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
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class TroopView extends Sprite
	{
		public var id:int;
		public var type:int;
		private var _health:Number;
		
		private var path:Vector.<PlaceView>;
		private var building:Building;
		
		private var direction:String;
		private var rushTimeoutId:uint;
		private var textureType:String;
		
		private var movieClip:MovieClip;
		private var healthDisplay:HealthBar;
		private var battleSide:int = 0;
	
		public function TroopView(building:Building, path:PlaceList)
		{
			this.id = building.place.getIncreasedId();
			this.type = building.troopType;
			this.battleSide = type == AppModel.instance.game.player.troopType?0:1;
			this.building = building;
			this.health = building.get_troopPower();
			
			textureType = type == AppModel.instance.game.player.troopType?"0/troop-0-move-":"1/troop-1-move-";
			movieClip = new MovieClip(Assets.getTextures(textureType+"down", "troops"), 20);
			movieClip.pivotX = movieClip.width/2;
			movieClip.pivotY = movieClip.height;
			addChild(movieClip);
			
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
			movieClip.muted = false;
			Starling.juggler.add(movieClip);

			var distance:Number = Math.sqrt(Math.pow(source.x-next.place.x, 2) + Math.pow(source.y-next.place.y, 2)) / 300; //trace(source.x, next.place.x, source.y, next.place.y, distance)
			Starling.juggler.tween(this, (building.get_troopSpeed()/1000) * distance, {x:next.x, y:next.y, onComplete:onTroopArrived, onCompleteArgs:[next]});
		}
		private function onTroopArrived(next:PlaceView):void
		{
			visible = false;
			movieClip.muted = true;
			Starling.juggler.remove(movieClip);
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

			movieClip.scaleX = (flipped ? -1 : 1 )// * Math.abs(scaleX);
			
			if(direction == dir)
				return;

			movieClip.fps = 40000/building.get_troopSpeed();
			direction = dir;
			//trace(textureType + direction)
			for(var i:int=0; i < movieClip.numFrames; i++)
				movieClip.setFrameTexture(i, Assets.getTexture(textureType + direction+(i>8 ? "-0"+(i+1) : "-00"+(i+1)), "troops"));
		}

		public function hit(placeView:PlaceView):void
		{
			var damage:Number = placeView.place.building.get_damage()
			health -= damage;
			//trace("damage", damage, "health", health)
			placeView.arrowContainer.visible = true;
			placeView.arrowTo(x-placeView.x, y-placeView.y)
			setTimeout(function():void { placeView.arrowContainer.visible = false; }, 200);

			if(health > 0)
				return;
			
			movieClip.muted = true;
			/*dispatchEventWith(Event.TRIGGERED);
			
			Starling.juggler.remove(movieClip);
			Starling.juggler.removeTweens(this);
			Starling.juggler.tween(this, 0.2, {x:x+50, y:y-40, onComplete:onTroopKilled, onCompleteArgs:[placeView], transition:Transitions.EASE_OUT});
*/
			var blood:Image = new Image(Assets.getTexture("blood"));
			blood.pivotX = blood.width/2;
			blood.pivotY = blood.height/2;
			blood.x = x;
			blood.y = y;
			parent.addChildAt(blood, 1);
			Starling.juggler.tween(blood, 2, {delay:1, alpha:0, onComplete:blood.removeFromParent, onCompleteArgs:[true]});
			Starling.juggler.tween(blood, 0.05, {scale:scale, transition:Transitions.EASE_OUT});
			blood.scale = 0;

			removeFromParent(true);

		
		}
		private function onTroopKilled(placeView:PlaceView):void
		{
			removeFromParent(true);
		}
		
		
		public function get health():Number
		{
			return _health;
		}
		public function set health(value:Number):void
		{
			if ( _health == value )
				return;
			
			_health = value;
			//trace(_health)
			if( _health < building.get_troopPower() )
				updateHealthDisplay(_health);

				
		}
		
		private function updateHealthDisplay(health:Number):void
		{
			if( health > 0 )
			{
				if( healthDisplay == null )
				{
					healthDisplay = new HealthBar(battleSide, health, building.get_troopPower());
					addChild(healthDisplay);
					healthDisplay.y = -80;
					healthDisplay.scale = scale;
				}
				else
				{
					healthDisplay.value = health;
				}
			}
			else
			{
				if( healthDisplay )
					healthDisplay.removeFromParent(true);	
			}
			
		}
		
		public function get muted():Boolean
		{
			return movieClip.muted;
		}
		
		
		override public function dispose():void
		{
			clearTimeout(rushTimeoutId);
			super.dispose();
		}
	}
}