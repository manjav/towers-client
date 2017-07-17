package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.buildings.Building;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.skins.ImageSkin;
	
	public class BuildingCard extends TowersLayout
	{
		
		private var iconDisplay:ImageLoader;
		private var slider:BuildingSlider;

		private var _type:int = -1;
		private var _locked:Boolean = false;
		private var _showSlider:Boolean = true;
		
		private var skin:ImageSkin;
		
		public function BuildingCard()
		{
			super();
		}


		override protected function initialize():void
		{
			super.initialize();
			
			skin = new ImageSkin(Assets.getTexture("building-button", "skin"));
			skin.setTextureForState("normal", Assets.getTexture("building-button", "skin"));
			skin.setTextureForState("locked", Assets.getTexture("building-button-disable", "skin"));
			skin.scale9Grid = new Rectangle(10, 10, 56, 37);
			backgroundSkin = skin;
			
			layout= new AnchorLayout();
			var progressHeight:int = 56 * appModel.scale;
			
			iconDisplay = new ImageLoader();
			iconDisplay.layoutData = new AnchorLayoutData(0, 0, progressHeight/2, 0);
			addChild(iconDisplay);
			
			slider = new BuildingSlider();
			slider.layoutData = new AnchorLayoutData(NaN, 0, 0, 0);
			slider.visible = !_locked && _showSlider;
			slider.height = progressHeight;
			addChild(slider);

			var t:int = type;
			type = -1;
			type = t;
		}
		
		public function get showSlider():Boolean
		{
			return _showSlider;
		}
		public function set showSlider(value:Boolean):void
		{
			if ( _showSlider == value )
				return;
			_showSlider = value;
			if ( slider )
				slider.visible = !_locked && _showSlider;
		}
		
		public function set locked(value:Boolean):void
		{
			if ( _locked == value )
				return;
			
			_locked = value;
			if ( slider )
				slider.visible = !_locked && showSlider;

			skin.defaultTexture = skin.getTextureForState(_locked?"locked":"normal");
			iconDisplay.alpha = _locked ? 0.7 : 1;
		}
		
		
		public function get type():int
		{
			return _type;
		}
		public function set type(value:int):void
		{
			if(_type == value)
				return;
			
			_type = value;
			if(_type == -1)
				return;
			
			var building:Building = player.buildings.get(_type);
			
			if ( iconDisplay )
				iconDisplay.source = Assets.getTexture("building-"+_type, "gui");
			
			locked = building == null;
			if( building == null )
				return;
			
			var upgradeCards:int = building.get_upgradeCards();
			var numBuildings:int = player.resources.get(type);
			
			if( slider && showSlider )
			{
				slider.maximum = upgradeCards;
				slider.value = numBuildings;
			}
		}
	}
}