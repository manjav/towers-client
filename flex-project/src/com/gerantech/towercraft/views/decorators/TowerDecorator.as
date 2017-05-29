package com.gerantech.towercraft.views.decorators
{
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.Game;
	import com.gt.towers.buildings.Place;
	import com.gt.towers.constants.TroopType;
	
	import flash.display3D.textures.Texture;
	import flash.utils.setTimeout;
	
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.text.BitmapFontTextFormat;
	
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.filters.ColorMatrixFilter;
	
	public class TowerDecorator extends Sprite
	{
		public var place:Place;
		
		private var imageDisplay:Image;
		private var plotDisplay:Image;
		
		private var populationIndicator:BitmapFontTextRenderer;
		private var editMode:Boolean;
		private var buidingTexture:String;
		
		private var animation:MovieClip;
		private var plotTexture:String;
		public function TowerDecorator(place:Place, editMode:Boolean=false)
		{
			this.place = place;
			this.editMode = editMode;
			
			plotDisplay = new Image(Assets.getTexture("building-plot-0"));
			plotDisplay.touchable = false;
			
			imageDisplay = new Image(Assets.getTexture("building-0-0"));
			imageDisplay.touchable = editMode;
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			alignPivot();
			
			
			/*animation = new MovieClip(Assets.getTextures("shot"), 20);
			addChild(animation);*/
		}
		
		
		private function addedToStageHandler():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			
			plotDisplay.pivotX = plotDisplay.width/2
			plotDisplay.pivotY = plotDisplay.height/2
			plotDisplay.width = stage.stageWidth/5;
			plotDisplay.scaleY = plotDisplay.scaleX;
			
			imageDisplay.pivotX = imageDisplay.width/2
			imageDisplay.pivotY = imageDisplay.height - imageDisplay.width*0.4;
			imageDisplay.width = stage.stageWidth/6;
			imageDisplay.scaleY = imageDisplay.scaleX;
			if(editMode)
			{
				//addChild(plotDisplay);
				addChild(imageDisplay);
			}
			else
			{
				plotDisplay.x = parent.x;
				plotDisplay.y = parent.y +6;
				parent.parent.addChildAt(plotDisplay, 4);
				
				imageDisplay.x = parent.x;
				imageDisplay.y = parent.y - 4;
				parent.parent.addChild(imageDisplay);
			}
			
			if(!editMode)
			{
				populationIndicator = new BitmapFontTextRenderer();//imageDisplay.width, imageDisplay.width/2, "");
				populationIndicator.textFormat = new BitmapFontTextFormat(Assets.getFont(), 12, 0xFFFFFF)
				populationIndicator.alignPivot();
				populationIndicator.width = imageDisplay.width;
				populationIndicator.height = imageDisplay.width/2;
				populationIndicator.touchable = false;
				populationIndicator.x = parent.x - 5;
				populationIndicator.y = parent.y + imageDisplay.width/2;
				setTimeout(parent.parent.addChild, 100, populationIndicator);
			}
		}
		
		public function updateElements(population:int, troopType:int):void
		{
			populationIndicator.text = population+"/"+place.building.get_capacity();
			
			var txt:String = "building-" + (place.building.get_type()+1) + "-" + place.building.level;
			if(buidingTexture != txt)
			{			
				buidingTexture = txt;
				imageDisplay.texture = Assets.getTexture(buidingTexture)	
			}
			
			var txt2:String = "building-plot-" + (place.building.troopType+1);
			if(place.building.troopType > -1)
				txt2 = "building-plot-" + (place.building.troopType == Game.get_instance().get_player().troopType?"1":"2");
			if(plotTexture != txt2)
			{			
				plotTexture = txt2;
				plotDisplay.texture = Assets.getTexture(plotTexture)	
			}
		}
		
	}
}