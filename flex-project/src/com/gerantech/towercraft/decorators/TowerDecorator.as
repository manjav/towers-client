package com.gerantech.towercraft.decorators
{
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.models.towers.Tower;
	import com.gerantech.towercraft.models.vo.Troop;
	
	import flash.utils.setTimeout;
	
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.text.BitmapFontTextFormat;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.filters.ColorMatrixFilter;
	
	public class TowerDecorator extends Sprite
	{
		public var tower:Tower;
		private var imageDisplay:Image;
		public var place:PlaceDecorator;

		private var cmf:ColorMatrixFilter;
		private var populationIndicator:BitmapFontTextRenderer;
		private var editMode:Boolean;
		
		public function TowerDecorator(tower:Tower, editMode:Boolean=false)
		{
			this.tower = tower;
			this.editMode = editMode;
			tower.addEventListener(Event.UPDATE, tower_updateHandler);
			imageDisplay = new Image(Assets.getTexture("tower-type-"+tower.type));
			imageDisplay.touchable = editMode;
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			alignPivot();
		}
		
		private function tower_updateHandler(event:Event):void
		{
			populationIndicator.text = tower.population+"/"+tower.capacity;
			
			if(!event.data)
				return;
			
			var txt:String = "tower-type-"+tower.type;
			if(tower.troopType == Troop.TYPE_BLUE)
				txt += "-b";
			else if(tower.troopType == Troop.TYPE_RED)
				txt += "-r";
			
			imageDisplay.texture = Assets.getTexture(txt)
			//cmf = new ColorMatrixFilter();
			//cmf.tint(tower.troopType, 0.8);
		//	imageDisplay.filter = cmf;
		}
		
		private function addedToStageHandler():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			imageDisplay.pivotX = imageDisplay.width/2
			imageDisplay.pivotY = imageDisplay.height - imageDisplay.width*0.4;
			imageDisplay.width = stage.stageWidth/6;
			imageDisplay.scaleY = imageDisplay.scaleX;
			if(editMode)
			{
				addChild(imageDisplay);
			}
			else
			{
				imageDisplay.x = parent.x;
				imageDisplay.y = parent.y;
				parent.parent.addChild(imageDisplay);
			}
			
			if(!editMode)
			{
				populationIndicator = new BitmapFontTextRenderer();//imageDisplay.width, imageDisplay.width/2, "");
				populationIndicator.textFormat = new BitmapFontTextFormat(Assets.getFont(), 12, 0)
				populationIndicator.pivotX = populationIndicator.width/2
				populationIndicator.width = imageDisplay.width;
				populationIndicator.height = imageDisplay.width/2;
				populationIndicator.touchable = false;
				populationIndicator.x = parent.x;
				populationIndicator.y = parent.y + imageDisplay.width/3;
				setTimeout(parent.parent.addChild, 100, populationIndicator);
			}
		}
	}
}