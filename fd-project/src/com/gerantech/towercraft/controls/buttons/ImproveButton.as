package com.gerantech.towercraft.controls.buttons
{
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.battle.units.Card;
	import com.gt.towers.constants.CardTypes;
	
	import feathers.controls.ImageLoader;
	
	import starling.display.Image;
	import starling.filters.ColorMatrixFilter;

	public class ImproveButton extends SimpleButton
	{
		public var building:Card;
		public var type:int;
		
		private var disableFilter:ColorMatrixFilter;
		
		private var iconDisplay:ImageLoader;
		
		private var backgroundDisplay:Image;
		public var locked:Boolean;
		public var enabled:Boolean;
		
		public function ImproveButton(building:Card, type:int)
		{
			super();
			this.building = building;
			this.type = type;
			locked = !building.unlocked(type);
			//touchable = !locked;
			
			var padding:int = 8;
			var size:int = 128;
			
			backgroundDisplay = new Image(Assets.getTexture("improve-button-" + (locked?"disabled":"up"), "gui"));
			backgroundDisplay.x = backgroundDisplay.y = -size * 0.5;
			backgroundDisplay.width = backgroundDisplay.height = size;
			addChild(backgroundDisplay);
			
			disableFilter = new ColorMatrixFilter();
			disableFilter.adjustSaturation(-0.7);
			//disableFilter.resolution = 0.8;
			
			var t:int = type;
			if( t == CardTypes.IMPROVE )
				t = CardTypes.get_improve(building.type) + 1;
			
			iconDisplay = new ImageLoader();
			iconDisplay.source = Assets.getTexture("improve-" + t, "gui");
			iconDisplay.width = iconDisplay.height = size-padding * 2;
			iconDisplay.x = iconDisplay.y = -size * 0.5 + padding;
			iconDisplay.filter = locked ? disableFilter : null;
			iconDisplay.touchable = false;
			addChild(iconDisplay);
			
			if( locked )
			{
				var lockDisplay:ImageLoader = new ImageLoader();
				lockDisplay.width = lockDisplay.height = size * 0.6;
				lockDisplay.x = lockDisplay.y = -size * 0.7;
				lockDisplay.source = Assets.getTexture("improve-lock", "gui");
				lockDisplay.touchable = false;
				addChild(lockDisplay);
			}
			
			renable();
		}
		
		public function renable():void
		{
			setEnable ( building.improvable(type) );
		}
		private function setEnable(value:Boolean):void
		{
			//trace(type, "enabled:", enabled, "value", value, "locked", locked)
			//if( enabled == value )
				//return;
			enabled = value;
			iconDisplay.filter = value ? null : disableFilter;
			backgroundDisplay.texture = Assets.getTexture("improve-button-"+(value?"up":"disabled"), "gui");
		}
	}
}