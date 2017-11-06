package com.gerantech.towercraft.views.decorators
{
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.views.PlaceView;
	import com.gt.towers.constants.BuildingType;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	
	public class BarracksDecorator extends BuildingDecorator
	{
		private var bodyDisplay:Image;
		private var bodyTexture:String;
		
		private var troopTypeDisplay:Image;
		private var troopTypeTexture:String;
		
		private var flagDisplay:MovieClip;
		private var flagTexture:String;
		
		public function BarracksDecorator(placeView:PlaceView)
		{
			super(placeView);
			
			bodyDisplay = new Image(Assets.getTexture("building-0-1"));
			bodyDisplay.touchable = false;
			
			troopTypeDisplay = new Image(Assets.getTexture("building-0-1-0"));
			troopTypeDisplay.touchable = false;
		}
		
		override protected function addedToStageHandler():void
		{
			bodyDisplay.pivotX = bodyDisplay.width * 0.5;
			bodyDisplay.pivotY = bodyDisplay.height * 0.85;
			bodyDisplay.x = parent.x;
			bodyDisplay.y = parent.y;	
			fieldView.buildingsContainer.addChild(bodyDisplay);
			
			troopTypeDisplay.pivotX = troopTypeDisplay.width * 0.5;
			troopTypeDisplay.pivotY = troopTypeDisplay.height * 0.85;
			troopTypeDisplay.x = parent.x;
			troopTypeDisplay.y = parent.y;
			fieldView.buildingsContainer.addChild(troopTypeDisplay);
			
			super.addedToStageHandler();
		}
		
		override public function updateElements(population:int, troopType:int):void
		{
			super.updateElements(population, troopType);
			
			var cate:int = BuildingType.get_category(place.building.type);
			var txt:String = "building-" + ((cate/10) + "-" +place.building.improveLevel)// + "-" + place.building.level;
			if( bodyTexture != txt )
			{
				bodyTexture = txt;
				bodyDisplay.texture = Assets.getTexture(bodyTexture)	
			}
		//	trace(place.index, place.building.type, troopType, place.building.troopType)

			if( troopType > -1 )
				txt += "-" + (troopType == player.troopType ? "0" : "1");
			
			if( troopTypeTexture != txt )
			{
				troopTypeTexture = txt;
				troopTypeDisplay.texture = Assets.getTexture(troopTypeTexture);
				
				// play change troop sounds
				if( cate == BuildingType.B00_CAMP )
				{
					var tsound:String = troopType == player.troopType?"battle-capture":"battle-lost";
					if(appModel.sounds.soundIsAdded(tsound))
						appModel.sounds.playSound(tsound);
					else
						appModel.sounds.addSound(tsound);
				}
			}
			if( cate == BuildingType.B10_BARRACKS )
			{
				txt = "building-flag-11-" + place.building.improveLevel;
				if( troopType > -1 )
					txt += "-" + (troopType == player.troopType ? "0" : "1");
				if( flagTexture != txt )
				{
					flagTexture = txt;
					createFlagDisply();
				}
			}
			else if( flagDisplay != null )
			{
				Starling.juggler.remove(flagDisplay);
				flagDisplay.removeFromParent(true);
				flagDisplay = null;
			}
		}
		
		private function createFlagDisply():Boolean
		{
			if( flagDisplay != null )
				return true;
			
			flagDisplay = new MovieClip(Assets.getTextures(flagTexture));
			flagDisplay.touchable = false;
			flagDisplay.loop = true;
			flagDisplay.pivotX = flagDisplay.width * 0.5;
			flagDisplay.pivotY = flagDisplay.height * 0.85;
			flagDisplay.x = parent.x;
			flagDisplay.y = parent.y;	
			fieldView.buildingsContainer.addChild(flagDisplay);
			Starling.juggler.add(flagDisplay);

			return false;
		}
		
		override public function dispose():void
		{
			if( flagDisplay )
				flagDisplay.removeFromParent(true);
			bodyDisplay.removeFromParent(true);
			troopTypeDisplay.removeFromParent(true);
			super.dispose();
		}
	}
}