package com.gerantech.towercraft.views.decorators
{
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.Game;
	import com.gt.towers.buildings.Place;
	import com.gt.towers.constants.TroopType;
	
	import flash.utils.setTimeout;
	
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.text.BitmapFontTextFormat;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.filters.ColorMatrixFilter;
	
	public class TowerDecorator extends Sprite
	{
		private var imageDisplay:Image;
		public var place:Place;

		private var cmf:ColorMatrixFilter;
		private var populationIndicator:BitmapFontTextRenderer;
		private var editMode:Boolean;
		private var texture:String;
		
		public function TowerDecorator(place:Place, editMode:Boolean=false)
		{
			this.place = place;
			this.editMode = editMode;
			//place.building.addEventListener(Event.UPDATE, tower_updateHandler);
			imageDisplay = new Image(Assets.getTexture("tower-type-0"));
			imageDisplay.touchable = editMode;
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			alignPivot();
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
				populationIndicator.alignPivot();
				populationIndicator.width = imageDisplay.width;
				populationIndicator.height = imageDisplay.width/2;
				populationIndicator.touchable = false;
				populationIndicator.x = parent.x;
				populationIndicator.y = parent.y + imageDisplay.width/3;
				setTimeout(parent.parent.addChild, 100, populationIndicator);
			}
		}
		
		public function updateElements(population:int, troopType:int):void
		{
			populationIndicator.text = population+"/"+place.building.get_capacity();
			
			var txt:String = "tower-type-" + place.building.get_type();
			if(troopType != TroopType.NONE)
				txt += ( troopType == Game.get_instance().get_player().troopType ? "-b" : "-r" );
			
			if(texture == txt)
				return;
			texture = txt;
			imageDisplay.texture = Assets.getTexture(txt)			
		}

	}
}