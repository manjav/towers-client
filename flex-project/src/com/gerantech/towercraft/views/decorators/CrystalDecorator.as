package com.gerantech.towercraft.views.decorators
{
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.views.BattleFieldView;
	import com.gerantech.towercraft.views.PlaceView;
	import com.gt.towers.constants.BuildingType;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	
	public class CrystalDecorator extends BarracksDecorator
	{
		private var crystalTexture:String;
		private var crystalDisplay:MovieClip;
		private var radiusDisplay:Image;
		
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
			radiusDisplay.width = place.building.get_damageRadius() * 2;
			radiusDisplay.scaleY = radiusDisplay.scaleX * 0.7;
			
			// plot :
			/*createPlotDisplay();
			plotDisplay.visible = place.building.level == 2 || place.building.level == 3;
			if( plotDisplay.visible )
			{
				txt = "building-plot-4-"+place.building.level;
				if(troopType > -1)
					txt += "-" + troopType;
				plotDisplay.texture = Assets.getTexture(txt);
			}*/
		}
		
		/*private function createPlotDisplay():void
		{
			if(plotDisplay != null)
				return;
			
			plotDisplay = new Image(Assets.getTexture("building-plot-4-"+place.building.level));
			plotDisplay.touchable = false;
			plotDisplay.pivotX = plotDisplay.width/2;
			plotDisplay.pivotY = plotDisplay.height * 0.85;
			plotDisplay.scale = appModel.scale * 2;
			plotDisplay.x = parent.x;
			plotDisplay.y = parent.y;
			BattleFieldView(parent.parent).buildingsContainer.addChild(plotDisplay);
		}
		*/
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
		
		override public function dispose():void
		{
 			if(crystalDisplay != null)
				crystalDisplay.removeFromParent(true);
			if(radiusDisplay != null)
				radiusDisplay.removeFromParent(true);
/*			if(plotDisplay != null)
				plotDisplay.removeFromParent(true);*/
			super.dispose();
		}
	}
}