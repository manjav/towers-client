package com.gerantech.towercraft.views.decorators
{
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.views.BattleFieldView;
	import com.gerantech.towercraft.views.PlaceView;
	import com.gt.towers.Game;
	import com.gt.towers.Player;
	import com.gt.towers.buildings.Place;
	
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	
	import feathers.controls.text.TextFieldTextRenderer;
	
	import starling.display.Sprite;
	import starling.events.Event;
	
	public dynamic class BuildingDecorator extends Sprite
	{
		protected var placeView:PlaceView;
		protected var place:Place;
		
		private var populationIndicator:TextFieldTextRenderer;
/*		private var plotTexture:String;
		private var plotDisplay:Image;*/
		
		public function BuildingDecorator(placeView:PlaceView)
		{
			this.placeView = placeView;
			this.place = placeView.place;
			this.placeView.addEventListener(Event.SELECT, placeView_selectHandler);
			
			/*plotDisplay = new Image(Assets.getTexture("building-plot-0"));
			plotDisplay.touchable = false;*/

			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			alignPivot();
		}
		
		protected function placeView_selectHandler(event:Event):void
		{
		}
		
		protected function addedToStageHandler():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			/*plotDisplay.pivotX = plotDisplay.width/2
			plotDisplay.pivotY = plotDisplay.height/2
			plotDisplay.width = stage.stageWidth/5;
			plotDisplay.scaleY = plotDisplay.scaleX;
			
			plotDisplay.x = parent.x;
			plotDisplay.y = parent.y;
			BattleFieldView(parent.parent).buildingsContainer.addChild(plotDisplay);*/

			populationIndicator = new TextFieldTextRenderer()//BitmapFontTextRenderer();//imageDisplay.width, imageDisplay.width/2, "");
			populationIndicator.textFormat = new TextFormat(null, null, 0xFFFFFF);//BitmapFontTextFormat(Assets.getFont(), 12, 0xFFFFFF)
			//populationIndicator.alignPivot();
			populationIndicator.width = stage.stageWidth/5;
			populationIndicator.height = stage.stageWidth/10;
			populationIndicator.touchable = false;
			populationIndicator.x = parent.x - 5;
			populationIndicator.y = parent.y + stage.stageWidth/10;
			setTimeout(BattleFieldView(parent.parent).buildingsContainer.addChild, 100, populationIndicator);
		}
		
		public function updateElements(population:int, troopType:int):void
		{
			populationIndicator.text = population+"/"+place.building.get_capacity();
			
			/*var txt2:String = "building-plot-" + (place.building.troopType+1);
			if(place.building.troopType > -1)
				txt2 = "building-plot-" + (place.building.troopType == Game.get_instance().player.troopType?"1":"2");
			if(plotTexture != txt2)
			{			
				plotTexture = txt2;
				plotDisplay.texture = Assets.getTexture(plotTexture)	
			}*/
		}
		
		override public function dispose():void
		{
			//plotDisplay.removeFromParent(true);
			populationIndicator.removeFromParent(true);
			placeView.removeEventListener(Event.SELECT, placeView_selectHandler);
			super.dispose();
		}
		
		protected function get appModel():		AppModel		{	return AppModel.instance;	}
		protected function get game():			Game			{	return appModel.game;		}
		protected function get player():		Player			{	return game.player;			}
	}
}