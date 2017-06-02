package com.gerantech.towercraft.views.decorators
{
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.views.PlaceView;
	import com.gt.towers.Game;
	import com.gt.towers.buildings.Place;
	
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	
	import feathers.controls.text.TextFieldTextRenderer;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public dynamic class BuildingDecorator extends Sprite
	{
		protected var placeView:PlaceView;
		protected var place:Place;
		
		private var populationIndicator:TextFieldTextRenderer;
		private var plotTexture:String;
		private var plotDisplay:Image;
		
		public function BuildingDecorator(placeView:PlaceView)
		{
			this.placeView = placeView;
			this.place = placeView.place;
			this.placeView.addEventListener(Event.SELECT, placeView_selectHandler);
			
			plotDisplay = new Image(Assets.getTexture("building-plot-0"));
			plotDisplay.touchable = false;

			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			alignPivot();
		}
		
		protected function placeView_selectHandler(event:Event):void
		{
		}
		
		protected function addedToStageHandler():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			plotDisplay.pivotX = plotDisplay.width/2
			plotDisplay.pivotY = plotDisplay.height/2
			plotDisplay.width = stage.stageWidth/5;
			plotDisplay.scaleY = plotDisplay.scaleX;
			
			plotDisplay.x = parent.x;
			plotDisplay.y = parent.y +6;
			parent.parent.addChildAt(plotDisplay, 4);

			populationIndicator = new TextFieldTextRenderer()//BitmapFontTextRenderer();//imageDisplay.width, imageDisplay.width/2, "");
			populationIndicator.textFormat = new TextFormat(null, null, 0xFFFFFF);//BitmapFontTextFormat(Assets.getFont(), 12, 0xFFFFFF)
			//populationIndicator.alignPivot();
			populationIndicator.width = plotDisplay.width;
			populationIndicator.height = plotDisplay.width/2;
			populationIndicator.touchable = false;
			populationIndicator.x = parent.x - 5;
			populationIndicator.y = parent.y + plotDisplay.width/2;
			setTimeout(parent.parent.addChild, 100, populationIndicator);
		}
		
		public function updateElements(population:int, troopType:int):void
		{
			populationIndicator.text = population+"/"+place.building.get_capacity();
			
			var txt2:String = "building-plot-" + (place.building.troopType+1);
			if(place.building.troopType > -1)
				txt2 = "building-plot-" + (place.building.troopType == Game.get_instance().get_player().troopType?"1":"2");
			if(plotTexture != txt2)
			{			
				plotTexture = txt2;
				plotDisplay.texture = Assets.getTexture(plotTexture)	
			}
		}
		
		override public function dispose():void
		{
			plotDisplay.removeFromParent(true);
			populationIndicator.removeFromParent(true);
			placeView.removeEventListener(Event.SELECT, placeView_selectHandler);
			super.dispose();
		}
		
		
	}
}