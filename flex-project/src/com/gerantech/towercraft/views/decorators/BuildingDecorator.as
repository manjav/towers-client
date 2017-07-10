package com.gerantech.towercraft.views.decorators
{
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.views.BattleFieldView;
	import com.gerantech.towercraft.views.PlaceView;
	import com.gt.towers.Game;
	import com.gt.towers.Player;
	import com.gt.towers.buildings.Place;
	import com.gt.towers.utils.lists.IntList;
	
	import flash.utils.setTimeout;
	
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.text.BitmapFontTextFormat;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public dynamic class BuildingDecorator extends Sprite
	{
		protected var placeView:PlaceView;
		protected var place:Place;
		
		private var populationIndicator:BitmapFontTextRenderer;
/*		private var plotTexture:String;
		private var plotDisplay:Image;*/

		private var improvableIcon:Image;
		
		public function BuildingDecorator(placeView:PlaceView)
		{
			this.placeView = placeView;
			this.place = placeView.place;
			this.placeView.addEventListener(Event.SELECT, placeView_selectHandler);
			if(place.building.troopType == player.troopType)
				this.placeView.addEventListener(Event.UPDATE, placeView_updateHandler);
			
			/*plotDisplay = new Image(Assets.getTexture("building-plot-0"));
			plotDisplay.touchable = false;*/

			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			alignPivot();
		}
		
		private function placeView_updateHandler(event:Event):void
		{
			var improvable:Boolean = false;
			var options:IntList = placeView.place.building.get_options();
			for (var i:int=0; i < options.size(); i++) 
			{
				trace(options.get(i), place.building.improvable(options.get(i)))
				if(place.building.improvable(options.get(i)) && options.get(i)!=1)
				{
					improvable = true;
					break;
				}
			}
			improvableIcon.visible = improvable;
		}
		
		protected function placeView_selectHandler(event:Event):void
		{
		}
		
		protected function addedToStageHandler():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);

			populationIndicator = new BitmapFontTextRenderer();//imageDisplay.width, imageDisplay.width/2, "");
			populationIndicator.textFormat = new BitmapFontTextFormat(Assets.getFont(), 32*appModel.scale, 0xFFFFFF, "center")
			populationIndicator.width = 180*appModel.scale;
			populationIndicator.touchable = false;
			populationIndicator.x = parent.x - populationIndicator.width/2;
			populationIndicator.y = parent.y + 32*appModel.scale;
			setTimeout(BattleFieldView(parent.parent).buildingsContainer.addChild, 100, populationIndicator);
			
			if(place.building.troopType == player.troopType)
			{
			improvableIcon = new Image(Assets.getTexture("improve--2", "gui"));
			improvableIcon.visible = false;
			addChild(improvableIcon);
			}
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