package com.gerantech.towercraft.views.decorators
{
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.views.PlaceView;
	import com.gt.towers.buildings.Place;
	
	import starling.display.Image;
	
	public class BarracksDecorator extends BuildingDecorator
	{
		private var imageDisplay:Image;
		private var buildingTexture:String;
		
		public function BarracksDecorator(placeView:PlaceView)
		{
			super(placeView);
			
			imageDisplay = new Image(Assets.getTexture("building-0"));
			imageDisplay.touchable = false;;
		}
		
		override protected function addedToStageHandler():void
		{
			super.addedToStageHandler();
			
			imageDisplay.pivotX = imageDisplay.width/2
			imageDisplay.pivotY = imageDisplay.height - imageDisplay.width*0.4;
			imageDisplay.width = stage.stageWidth/6;
			imageDisplay.scaleY = imageDisplay.scaleX;
			imageDisplay.x = parent.x;
			imageDisplay.y = parent.y - 4;
			parent.parent.addChild(imageDisplay);
		}
		
		override public function updateElements(population:int, troopType:int):void
		{
			super.updateElements(population, troopType);
			
			var txt:String = "building-" + place.building.type;
			if( place.building.type > 0 )
				txt += ( "-" + place.building.level );
			if(buildingTexture != txt)
			{
				buildingTexture = txt;
				imageDisplay.texture = Assets.getTexture(buildingTexture)	
			}
		}
		
		override public function dispose():void
		{
			imageDisplay.removeFromParent(true);
			super.dispose();
		}
	}
}