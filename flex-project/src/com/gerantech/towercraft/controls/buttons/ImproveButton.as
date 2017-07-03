package com.gerantech.towercraft.controls.buttons
{
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.buildings.Building;
	import com.gt.towers.constants.BuildingType;
	
	import feathers.controls.ButtonState;
	import feathers.controls.ImageLoader;
	import feathers.skins.ImageSkin;
	
	import starling.display.Image;
	import starling.filters.ColorMatrixFilter;

	public class ImproveButton extends SimpleButton
	{
		public var building:Building;
		public var type:int;

		private var disableFilter:ColorMatrixFilter;

		private var iconDisplay:ImageLoader;

		private var skin:Image;
		
		public function ImproveButton(building:Building, type:int)
		{
			super();
			this.building = building;
			this.type = type;

			var padding:int = 8 * AppModel.instance.scale;
			var size:int = 128 * AppModel.instance.scale;
			
			skin = new Image(Assets.getTexture("improve-button-up", "gui"));
			skin.x = skin.y = -size/2;
			skin.width = skin.height = size;
			addChild(skin);
			
			disableFilter = new ColorMatrixFilter();
			disableFilter.adjustSaturation(-0.7);
			//disableFilter.resolution = 0.8;
			
			iconDisplay = new ImageLoader();
			iconDisplay.source = Assets.getTexture("improve-"+type, "gui");
			iconDisplay.width = iconDisplay.height = size-padding*2;
			iconDisplay.x = iconDisplay.y = -size/2+padding;
			iconDisplay.touchable = false;
			addChild(iconDisplay);
			
			var lockDisplay:ImageLoader = new ImageLoader();
			lockDisplay.width = lockDisplay.height = size*0.6;
			lockDisplay.x = lockDisplay.y = -size*0.7;
			lockDisplay.source = Assets.getTexture("improve-lock", "gui");
			lockDisplay.visible = !building.unlocked(type);
			lockDisplay.touchable = false;
			addChild(lockDisplay);
			
			renable();
			
		}

		public function renable():void
		{
			enabled = building.improvable(type);
		}
		
		public function set enabled(value:Boolean):void
		{
			if(touchGroup == value)
				return;
			touchGroup = value;
			trace(type, "disableFilter", value)
			iconDisplay.filter = value ? null : disableFilter;
			skin.texture = Assets.getTexture("improve-button-"+(value?"up":"disabled"), "gui");
			skin.readjustSize();
		}
		public function get enabled():Boolean
		{
			return touchGroup;
		}
	}
}