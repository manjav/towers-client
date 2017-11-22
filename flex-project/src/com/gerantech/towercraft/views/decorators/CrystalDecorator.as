package com.gerantech.towercraft.views.decorators
{
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.views.PlaceView;
	import com.gerantech.towercraft.views.TroopView;
	import com.gt.towers.buildings.Crystal;
	import com.gt.towers.constants.BuildingType;
	
	import flash.utils.setTimeout;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.utils.MathUtil;
	
	public class CrystalDecorator extends BuildingDecorator
	{
		private var crystalTexture:String;
		private var crystalDisplay:MovieClip;
		private var radiusDisplay:Image;
		private var rayImage:Image;
		private var raySprite:Sprite;
		private var lightingDisplay:MovieClip;
		
		public function CrystalDecorator(placeView:PlaceView)
		{
			super(placeView);
		}
		
		override public function updateElements(population:int, troopType:int):void
		{
			super.updateElements(population, troopType);
			
			/*var txt:String = "building-cr-" + place.building.type;
			if(crystalTexture != txt)
			{
				crystalTexture = txt;
				
				// crystal :
				if(crystalDisplay != null)
				{
					Starling.juggler.remove(crystalDisplay);
					crystalDisplay.removeFromParent(true);
				}
				crystalDisplay = new MovieClip(Assets.getTextures(crystalTexture));
				crystalDisplay.play();
				crystalDisplay.touchable = false;
				crystalDisplay.pivotX = crystalDisplay.width * 0.5;
				crystalDisplay.pivotY = crystalDisplay.height;
				crystalDisplay.x = parent.x;

				
				crystalDisplay.y = parent.y - get_crystalHeight() ;
				Starling.juggler.add(crystalDisplay);
				fieldView.buildingsContainer.addChild(crystalDisplay);
			}
			*/
			// radius :
			createRadiusDisplay();
			radiusDisplay.width = place.building.get_damageRadius() * 2;
			radiusDisplay.scaleY = radiusDisplay.scaleX * 0.8;
		
			// ray
			createRayDisplay();
			rayImage.scale = place.building.get_damage() * 1.5;
			
			// lighting
			createLightingDisplay();
			lightingDisplay.scale = place.building.get_damage() * 2;
		}
		
		private function get_crystalHeight():Number
		{
			if ( place.building.type == BuildingType.B42_CRYSTAL )
				return 90;
			else if ( place.building.type == BuildingType.B43_CRYSTAL )
				return 96;
			else if ( place.building.type == BuildingType.B44_CRYSTAL )
				return 102;
			return 84;
		}
		
		private function createRadiusDisplay():void
		{
			if(radiusDisplay != null)
				return;
			
			radiusDisplay = new Image(Assets.getTexture("damage-range"));
			radiusDisplay.touchable = false;
			radiusDisplay.alignPivot()
			radiusDisplay.x = parent.x;
			radiusDisplay.y = parent.y;
			fieldView.buildingsContainer.addChildAt(radiusDisplay, 0);
		}
		
		private function createRayDisplay():void
		{
			if( raySprite != null )
				return;
			
			raySprite = new Sprite();
			raySprite.visible = raySprite.touchable = false;
			raySprite.x = parent.x;
			raySprite.y = parent.y - get_crystalHeight();
			fieldView.buildingsContainer.addChild(raySprite);
			
			rayImage = new Image(Assets.getTexture("crystal-ray"));
			rayImage.alignPivot("center", "bottom");
			raySprite.addChild(rayImage);
			
			placeView.defensiveWeapon.addEventListener(Event.TRIGGERED, defensiveWeapon_triggeredHandler);
		}
		
		private function createLightingDisplay():void
		{
			if( lightingDisplay != null )
				return;
			
			lightingDisplay = new MovieClip(Assets.getTextures("crystal-lighting"));
			lightingDisplay.touchable = false;
			lightingDisplay.pivotX = lightingDisplay.width * 0.5;
			lightingDisplay.pivotY = lightingDisplay.height * 0.5;
			fieldView.buildingsContainer.addChild(lightingDisplay);
		}
		
		
		private function defensiveWeapon_triggeredHandler(event:Event):void
		{
			var troop:TroopView = event.data as TroopView;
			
			raySprite.visible = true;
			var dx:Number = troop.x-raySprite.x;
			var dy:Number = troop.y-raySprite.y;
			rayImage.height = Math.sqrt( dx*dx + dy*dy );
			raySprite.rotation = MathUtil.normalizeAngle(-Math.atan2(-dx, -dy));
			
			lightingDisplay.x = troop.x;
			lightingDisplay.y = troop.y;
			lightingDisplay.play();
			lightingDisplay.visible = true;
			Starling.juggler.add(lightingDisplay);
			
			setTimeout(function():void { raySprite.visible = false;}, 100);
			setTimeout(function():void { 
				
				Starling.juggler.remove(lightingDisplay);
				lightingDisplay.stop();
				lightingDisplay.visible = false; 
			}, 300);
		}
		

		
		override public function dispose():void
		{
 			if(crystalDisplay != null)
				crystalDisplay.removeFromParent(true);
			if(radiusDisplay != null)
				radiusDisplay.removeFromParent(true);
			if(placeView.defensiveWeapon != null)
				placeView.defensiveWeapon.removeEventListener(Event.TRIGGERED, defensiveWeapon_triggeredHandler);
			super.dispose();
		}
	}
}