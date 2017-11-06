package com.gerantech.towercraft.views.decorators
{
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.views.BattleFieldView;
	import com.gerantech.towercraft.views.HealthBar;
	import com.gerantech.towercraft.views.PlaceView;
	import com.gt.towers.Game;
	import com.gt.towers.Player;
	import com.gt.towers.buildings.Place;
	import com.gt.towers.utils.lists.IntList;
	
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.text.BitmapFontTextFormat;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public dynamic class BuildingDecorator extends Sprite
	{
		protected var placeView:PlaceView;
		protected var place:Place;
		
		private var populationIndicator:BitmapFontTextRenderer;
		public var improvablePanel:ImprovablePanel;

		private var populationBar:HealthBar;
		private var populationIcon:Image;
		private var underAttack:MovieClip;
		private var underAttackId:uint;
		
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
			{
				improvablePanel.enabled = false;
				return;
			}
			
			var improvable:Boolean = false;
			if( !player.inTutorial() && !SFSConnection.instance.mySelf.isSpectator )
			{
				var options:IntList = place.building.get_options();
				for (var i:int=0; i < options.size(); i++) 
				{
					//trace("index:", place.index, "option:", options.get(i), "improvable:", place.building.improvable(options.get(i)), "_population:", place.building._population)
					if( place.building.improvable(options.get(i)) && options.get(i)!=1 )
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
			
			populationBar = new HealthBar(place.building.troopType, place.building.get_population(), place.building.get_capacity());
			populationBar.width = 140
			populationBar.height = 38
			populationBar.x = parent.x - populationBar.width/2 + 24;
			populationBar.y = parent.y + 32;
			fieldView.guiImagesContainer.addChild(populationBar);

			populationIndicator = new BitmapFontTextRenderer();
			populationIndicator.textFormat = new BitmapFontTextFormat(Assets.getFont(), 36, 0xFFFFFF, "center")
			populationIndicator.width = populationBar.width;
			populationIndicator.touchable = false;
			populationIndicator.x = place.x - populationIndicator.width/2 + 24 ;
			populationIndicator.y = place.y + 16;
			fieldView.guiTextsContainer.addChild(populationIndicator);
			
			populationIcon = new Image(Assets.getTexture("population-" + place.building.troopType));
			populationIcon.touchable = false;
			populationIcon.x = place.x - populationBar.width/2 - 18;
			populationIcon.y = place.y + 27;
			fieldView.guiImagesContainer.addChild(populationIcon);

			improvablePanel = new ImprovablePanel();
			improvablePanel.x = place.x - improvablePanel.width/2;
			improvablePanel.y = place.y + 32;
			fieldView.guiImagesContainer.addChild(improvablePanel);
			
			underAttack = new MovieClip(Assets.getTextures("war-icon-sword-"), 22);
			underAttack.touchable = false;
			underAttack.visible = false;
			underAttack.x = place.x - underAttack.width * 0.5;
			underAttack.y = place.y - underAttack.height * 2;
			fieldView.guiImagesContainer.addChild(underAttack);
		}
		
		public function updateElements(population:int, troopType:int):void
		{
			populationIndicator.text = population + "/" + place.building.get_capacity();
			populationBar.troopType = troopType==-1 ? -1 : (troopType == player.troopType ? 0 : 1);
			populationBar.value = population;
			populationIcon.texture = Assets.getTexture("population-"+place.building.troopType);
		}
		
		public function showUnderAttack():void
		{
			appModel.sounds.addAndPlaySound("battle-swords");
			underAttack.visible = true;
			clearTimeout(underAttackId);
			underAttackId = setTimeout(underAttack_completeHandler, 1000);
			Starling.juggler.add(underAttack);
			function underAttack_completeHandler():void
			{
				underAttack.visible = false;
				Starling.juggler.remove(underAttack);
			}
		}
		
		override public function dispose():void
		{
			populationIndicator.removeFromParent(true);
			populationIcon.removeFromParent(true);
			populationBar.removeFromParent(true);
			underAttack.removeFromParent(true);
			improvablePanel.removeFromParent(true);
			
			placeView.removeEventListener(Event.SELECT, placeView_selectHandler);
			super.dispose();
		}
		
		protected function get appModel():		AppModel		{	return AppModel.instance;					}
		protected function get game():			Game			{	return appModel.game;						}
		protected function get player():		Player			{	return game.player;							}
		protected function get fieldView():		BattleFieldView {	return AppModel.instance.battleFieldView;	}
	}
}