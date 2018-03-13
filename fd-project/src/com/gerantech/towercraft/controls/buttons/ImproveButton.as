package com.gerantech.towercraft.controls.buttons
{
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.buildings.Building;
	import com.gt.towers.constants.BuildingType;
	
	import feathers.controls.ImageLoader;
	
	import starling.display.Image;
	import starling.filters.ColorMatrixFilter;

	public class ImproveButton extends SimpleButton
	{
		public var building:Building;
		public var type:int;

		private var disableFilter:ColorMatrixFilter;

		private var iconDisplay:ImageLoader;

		private var backgroundDisplay:Image;
		public var locked:Boolean;
		
		public function ImproveButton(building:Building, type:int)
		{
			super();
			this.building = building;
			this.type = type;
			locked = !building.unlocked(type);
			touchable = !locked;

			var padding:int = 8 * AppModel.instance.scale;
			var size:int = 128 * AppModel.instance.scale;
			
			backgroundDisplay = new Image(Assets.getTexture("improve-button-" + (locked?"disabled":"up"), "gui"));
			backgroundDisplay.x = backgroundDisplay.y = -size/2;
			backgroundDisplay.width = backgroundDisplay.height = size;
			addChild(backgroundDisplay);
			
			disableFilter = new ColorMatrixFilter();
			disableFilter.adjustSaturation(-0.7);
			//disableFilter.resolution = 0.8;
			
			var t:int = type;
			if( t == BuildingType.IMPROVE )
				t = BuildingType.get_improve(building.type) + 1;
			
			iconDisplay = new ImageLoader();
			iconDisplay.source = Assets.getTexture("improve-" + t, "gui");
			iconDisplay.width = iconDisplay.height = size-padding*2;
			iconDisplay.x = iconDisplay.y = -size/2+padding;
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
			//trace(type, "enabled:", value, touchable, locked)
			if( touchable == value || locked )
				return;
			touchable = value;
			iconDisplay.filter = value ? null : disableFilter;
			backgroundDisplay.texture = Assets.getTexture("improve-button-"+(value?"up":"disabled"), "gui");
		}

	}
}