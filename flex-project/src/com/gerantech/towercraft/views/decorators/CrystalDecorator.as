package com.gerantech.towercraft.views.decorators
{
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.views.PlaceView;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	
	public class CrystalDecorator extends BuildingDecorator
	{
		private var buildingTexture:String;
		private var crystalDisplay:MovieClip;
		private var baseDisplay:Image;
		private var radiusDisplay:Image;
		
		public function CrystalDecorator(placeView:PlaceView)
		{
			super(placeView);
		}
	
		
		override public function updateElements(population:int, troopType:int):void
		{
			super.updateElements(population, troopType);
			
			var txt:String = "building-" + place.building.type;
			if( place.building.type > 0 )
				txt += ( "-" + place.building.level);

			if(buildingTexture != txt)
			{
				buildingTexture = txt;
				
				// radius :
				if(radiusDisplay == null)
					createRadiusDisplay();
				radiusDisplay.width = place.building.get_damageRadius() * 2;
				radiusDisplay.scaleY = radiusDisplay.scaleX;
				
				// base :
				if(baseDisplay == null)
					createBaseDisplay();
				baseDisplay.texture = Assets.getTexture("building-plot-4-"+place.building.level);

				// crystal :
				if(crystalDisplay != null)
				{
					Starling.juggler.remove(crystalDisplay);
					crystalDisplay.removeFromParent(true);
				}
				crystalDisplay = new MovieClip(Assets.getTextures(buildingTexture));
				crystalDisplay.play();
				crystalDisplay.touchable = false;
				crystalDisplay.pivotX = crystalDisplay.width/2
				crystalDisplay.pivotY = crystalDisplay.height - crystalDisplay.width*0.4;
				crystalDisplay.width = stage.stageWidth/6;
				crystalDisplay.scaleY = crystalDisplay.scaleX;
				crystalDisplay.x = parent.x;
				crystalDisplay.y = parent.y - 4 ;
				Starling.juggler.add(crystalDisplay);
				parent.parent.addChild(crystalDisplay);
			}
		}
		
		private function createBaseDisplay():void
		{
			baseDisplay = new Image(Assets.getTexture("building-plot-4-"+place.building.level));
			baseDisplay.touchable = false;
			baseDisplay.pivotX = baseDisplay.width/2
			baseDisplay.pivotY = baseDisplay.height - baseDisplay.width*0.4;
			baseDisplay.width = stage.stageWidth/6;
			baseDisplay.scaleY = baseDisplay.scaleX;
			baseDisplay.x = parent.x;
			baseDisplay.y = parent.y - 4;
			parent.parent.addChild(baseDisplay);			
		}
		
		private function createRadiusDisplay():void
		{
			radiusDisplay = new Image(Assets.getTexture("circle"));
			radiusDisplay.touchable = false;
			radiusDisplay.pivotX = radiusDisplay.width/2
			radiusDisplay.pivotY = radiusDisplay.height - radiusDisplay.width*0.4;
			radiusDisplay.x = parent.x;
			radiusDisplay.y = parent.y;
			parent.parent.addChild(radiusDisplay);			
		}
		
		override public function dispose():void
		{
			crystalDisplay.removeFromParent(true);
			radiusDisplay.removeFromParent(true);
			baseDisplay.removeFromParent(true);
			super.dispose();
		}
	}
}