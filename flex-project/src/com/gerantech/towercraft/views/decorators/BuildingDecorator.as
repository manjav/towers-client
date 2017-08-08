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
	
	import starling.display.Sprite;
	import starling.events.Event;
	
	public dynamic class BuildingDecorator extends Sprite
	{
		protected var placeView:PlaceView;
		protected var place:Place;
		
		private var populationIndicator:BitmapFontTextRenderer;
		private var improvablePanel:ImprovablePanel;
		
		public function BuildingDecorator(placeView:PlaceView)
		{
			this.placeView = placeView;
			this.place = placeView.place;
			this.placeView.addEventListener(Event.SELECT, placeView_selectHandler);
			this.placeView.addEventListener(Event.UPDATE, placeView_updateHandler);

			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			alignPivot();
		}
		
		private function placeView_updateHandler(event:Event):void
		{
			if(place.building.troopType != player.troopType)
				return;
			
			var improvable:Boolean = false;
			if( !player.inTutorial() )
			{
				var options:IntList = place.building.get_options();
				for (var i:int=0; i < options.size(); i++) 
				{
					//trace("index:", place.index, "option:", options.get(i), "improvable:", place.building.improvable(options.get(i)), "_population:", place.building._population)
					if(place.building.improvable(options.get(i)) && options.get(i)!=1)
					{
						improvable = true;
						break;
					}
				}
			}
			improvablePanel.enabled = improvable;
		}
		
		protected function placeView_selectHandler(event:Event):void
		{
		}
		
		protected function addedToStageHandler():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);

			populationIndicator = new BitmapFontTextRenderer();//imageDisplay.width, imageDisplay.width/2, "");
			populationIndicator.textFormat = new BitmapFontTextFormat(Assets.getFont(), 48*appModel.scale, 0xFFFFFF, "center")
			populationIndicator.width = 220*appModel.scale;
			populationIndicator.touchable = false;
			populationIndicator.x = parent.x - populationIndicator.width/2;
			populationIndicator.y = parent.y + 32*appModel.scale;
			setTimeout(BattleFieldView(parent.parent).buildingsContainer.addChild, 100, populationIndicator);

			improvablePanel = new ImprovablePanel();
			improvablePanel.scale = appModel.scale * 2;
			improvablePanel.x = parent.x - improvablePanel.width/2;
			improvablePanel.y = parent.y + 32*appModel.scale;
			setTimeout(BattleFieldView(parent.parent).buildingsContainer.addChild, 100, improvablePanel);
		}
		
		public function updateElements(population:int, troopType:int):void
		{
			//trace("> " + population+"/"+place.building.get_capacity())
			try{
			populationIndicator.text = "> " + population+"/"+place.building.get_capacity();
			}catch(e:Error){trace(e.message, "> " + population+"/"+place.building.get_capacity())}
		}
		
		override public function dispose():void
		{
			populationIndicator.removeFromParent(true);
			placeView.removeEventListener(Event.SELECT, placeView_selectHandler);
			super.dispose();
		}
		
		protected function get appModel():		AppModel		{	return AppModel.instance;	}
		protected function get game():			Game			{	return appModel.game;		}
		protected function get player():		Player			{	return game.player;			}
	}
}