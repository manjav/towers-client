package com.gerantech.towercraft.views.decorators
{
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.views.BattleFieldView;
	import com.gerantech.towercraft.views.PlaceView;
	import com.gt.towers.Game;
	import com.gt.towers.constants.BuildingType;
	
	import starling.display.Image;
	
	public class BarracksDecorator extends BuildingDecorator
	{
		private var bodyDisplay:Image;
		private var bodyTexture:String;
		
		private var troopTypeDisplay:Image;
		private var troopTypeTexture:String;
		
		public function BarracksDecorator(placeView:PlaceView)
		{
			super(placeView);
			
			bodyDisplay = new Image(Assets.getTexture("building-0-1"));
			bodyDisplay.touchable = false;
			
			troopTypeDisplay = new Image(Assets.getTexture("building-0-1-0"));
			troopTypeDisplay.touchable = false;
		}
		
		override protected function addedToStageHandler():void
		{
			super.addedToStageHandler();
			
			bodyDisplay.pivotX = bodyDisplay.width/2
			bodyDisplay.pivotY = bodyDisplay.height * 0.85;
			bodyDisplay.scale = appModel.scale * 2;
			bodyDisplay.x = parent.x;
			bodyDisplay.y = parent.y// - 16;	
			BattleFieldView(parent.parent).buildingsContainer.addChild(bodyDisplay);
			
			troopTypeDisplay.pivotX = troopTypeDisplay.width/2
			troopTypeDisplay.pivotY = troopTypeDisplay.height * 0.85
			troopTypeDisplay.scale = appModel.scale * 2;
			troopTypeDisplay.x = parent.x;
			troopTypeDisplay.y = parent.y// - 16;
			BattleFieldView(parent.parent).buildingsContainer.addChild(troopTypeDisplay);
		}
		
		override public function updateElements(population:int, troopType:int):void
		{
			super.updateElements(population, troopType);
			
			var txt:String = "building-" + ((BuildingType.get_category(place.building.type)/10) + "-" +place.building.improveLevel)// + "-" + place.building.level;
			if(bodyTexture != txt)
			{
				bodyTexture = txt;
				bodyDisplay.texture = Assets.getTexture(bodyTexture)	
			}
			
			if(troopType > -1)
				txt += "-" + (place.building.troopType == Game.get_instance().get_player().troopType?"0":"1");
			
			if(troopTypeTexture != txt)
			{
				troopTypeTexture = txt;
				troopTypeDisplay.texture = Assets.getTexture(troopTypeTexture)	
			}
		}
		
		override public function dispose():void
		{
			bodyDisplay.removeFromParent(true);
			troopTypeDisplay.removeFromParent(true);
			super.dispose();
		}
	}
}