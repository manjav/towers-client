package com.gerantech.towercraft.decorators
{
	import com.gerantech.towercraft.models.vo.Troop;
	import com.gerantech.towercraft.models.Textures;
	import com.gerantech.towercraft.models.TowerPlace;
	import com.gerantech.towercraft.models.towers.Tower;
	
	import feathers.controls.Label;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.filters.ColorMatrixFilter;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class TowerDecorator extends Sprite
	{
		public var tower:Tower;
		private var imageDisplay:Image;
		public var place:TowerPlace;

		private var cmf:ColorMatrixFilter;
		private var populationIndicator:TextField;
		
		public function TowerDecorator(tower:Tower)
		{
			this.tower = tower;
			tower.addEventListener(Event.UPDATE, tower_updateHandler);
			
			imageDisplay = new Image(Textures.get("tower_type_"+tower.type));
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
		}
		
		private function tower_updateHandler(event:Event):void
		{
			populationIndicator.text = tower.population+"/"+tower.capacity;
			
			if(!event.data)
				return;
			
			cmf = new ColorMatrixFilter();
			cmf.tint(tower.troopType, 0.8);
			imageDisplay.filter = cmf;
		}
		
		private function addedToStageHandler():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			imageDisplay.pivotX = imageDisplay.width/2
			imageDisplay.pivotY = imageDisplay.height - imageDisplay.width*0.4;
			imageDisplay.width = stage.stageWidth/6;
			imageDisplay.scaleY = imageDisplay.scaleX;
			addChild(imageDisplay);
			
			
			var tf:TextFormat = new TextFormat("tahoma", imageDisplay.width/5);
			tf.bold = true;
			
			populationIndicator = new TextField(imageDisplay.width, imageDisplay.width/2, "", tf);
			populationIndicator.y = imageDisplay.width/3;
			populationIndicator.alignPivot();
			addChild(populationIndicator)
		}
	}
}