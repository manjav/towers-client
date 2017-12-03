package com.gerantech.towercraft.views.decorators
{
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.views.PlaceView;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	
	public class BarracksDecorator extends BuildingDecorator
	{
		private var flagDisplay:MovieClip;
		private var flagTexture:String;
		
		public function BarracksDecorator(placeView:PlaceView)
		{
			super(placeView);
		}
		
		override public function updateElements(population:int, troopType:int):void
		{
			super.updateElements(population, troopType);

			if( place.building.category == 0 ) 
				return;
			var txt:String = "building-flag-14"// + place.building.type;
			if( troopType > -1 )
				txt += troopType == player.troopType ? "-0" : "-1";
			else
				txt += "-n";
					
			if( flagTexture != txt )
			{
				flagTexture = txt;
				createFlagDisply();
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
			flagDisplay.pivotY = flagDisplay.height * 0.8;
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
			super.dispose();
		}
	}
}