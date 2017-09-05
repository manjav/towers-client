package com.gerantech.towercraft.views.decorators
{
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.views.BattleFieldView;
	import com.gerantech.towercraft.views.PlaceView;
	import com.gerantech.towercraft.views.TroopView;
	import com.gt.towers.constants.BuildingType;
	
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.utils.MathUtil;
	
	public class CrystalDecorator extends BarracksDecorator
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
			
			var txt:String = "building-ex-" + ((BuildingType.get_category(place.building.type)/10) + "-" +place.building.improveLevel)// + "-" + place.building.level;
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
				crystalDisplay.pivotX = crystalDisplay.width/2;
				crystalDisplay.pivotY = crystalDisplay.height;
				crystalDisplay.scale = appModel.scale * 2;
				crystalDisplay.x = parent.x;
				crystalDisplay.y = parent.y - 24 ;
				Starling.juggler.add(crystalDisplay);
				BattleFieldView(parent.parent).buildingsContainer.addChild(crystalDisplay);
			}
			
			// radius :
			createRadiusDisplay();
			radiusDisplay.width = place.building.get_damageRadius() * appModel.scale;
			radiusDisplay.scaleY = radiusDisplay.scaleX * 0.7;
		
			// ray
			createRayDisplay();
			rayImage.scale = appModel.scale * place.building.get_damage() * 1.5;
			
			// lighting
			createLightingDisplay();
			lightingDisplay.scale = appModel.scale * place.building.get_damage() * 2;
		}
		
		private function createRadiusDisplay():void
		{
			if(radiusDisplay != null)
				return;
			
			radiusDisplay = new Image(Assets.getTexture("damage-range"));
			radiusDisplay.touchable = false;
			radiusDisplay.pivotX = radiusDisplay.width/2
			radiusDisplay.pivotY = radiusDisplay.height/2;
			radiusDisplay.x = parent.x;
			radiusDisplay.y = parent.y;
			parent.parent.addChild(radiusDisplay);
		}
		
		private function createRayDisplay():void
		{
			if( raySprite != null )
				return;
			
			raySprite = new Sprite();
			raySprite.visible = raySprite.touchable = false;
			raySprite.x = parent.x;
			raySprite.y = parent.y - 132*appModel.scale ;
			BattleFieldView(parent.parent).buildingsContainer.addChild(raySprite);
			
			rayImage = new Image(Assets.getTexture("crystal-ray"));
		//	flameDisplay.scale9Grid = new Rectangle(1, 1, 3, 2);
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
			lightingDisplay.pivotX = lightingDisplay.width/2;
			lightingDisplay.pivotY = lightingDisplay.height/2;
			BattleFieldView(parent.parent).buildingsContainer.addChild(lightingDisplay);
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