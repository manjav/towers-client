package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.controls.sliders.BuildingSlider;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.controls.texts.ShadowLabel;
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.buildings.Building;
	import com.gt.towers.constants.BuildingType;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.skins.ImageSkin;
	
	import starling.utils.ScaleMode;
	
	public class BuildingCard extends TowersLayout
	{
		private var improveDisplay:ImageLoader;
		private var iconDisplay:ImageLoader;
		private var slider:BuildingSlider;
		private var levelDisplay:ShadowLabel;

		private var _type:int = -1;
		private var _level:int = 0;
		private var _locked:Boolean = false;
		private var _showSlider:Boolean = true;
		private var _showLevel:Boolean = true;
		
		private var skin:ImageSkin;
		
		public function BuildingCard()
		{
			super();
		}

		override protected function initialize():void
		{
			super.initialize();
			
			skin = new ImageSkin(Assets.getTexture("theme/building-button", "gui"));
			skin.setTextureForState("normal", Assets.getTexture("theme/building-button", "gui"));
			skin.setTextureForState("locked", Assets.getTexture("theme/building-button-disable", "gui"));
			skin.scale9Grid = new Rectangle(10, 10, 56, 37);
			backgroundSkin = skin;
			
			layout= new AnchorLayout();
			var progressHeight:int = 56 * appModel.scale;
			var padding:int = 16 * appModel.scale;
			
			iconDisplay = new ImageLoader();
			iconDisplay.pixelSnapping = false;
			iconDisplay.maintainAspectRatio = false;
			iconDisplay.layoutData = new AnchorLayoutData(padding, padding, padding*1.8, padding);
			addChild(iconDisplay);
			
			improveDisplay = new ImageLoader();
			improveDisplay.width = padding * 5;
			improveDisplay.layoutData = new AnchorLayoutData(padding * 2, padding * 2);
			addChild(improveDisplay);
			
			slider = new BuildingSlider();
			slider.layoutData = new AnchorLayoutData(NaN, 0, 0, 0);
			slider.visible = !_locked && _showSlider;
			slider.height = progressHeight;
			addChild(slider);
			
			levelDisplay = new ShadowLabel( _level > 0 ? "lvl "+ _level : "", 1, 0, "right");
			//levelDisplay.alpha = 0.9;
			levelDisplay.visible = !_locked && _showLevel;
			levelDisplay.height = progressHeight;
			levelDisplay.layoutData = new AnchorLayoutData(NaN, padding * 1.8, padding * 4, padding);
			addChild(levelDisplay);

			var t:int = type;
			type = -1;
			type = t;
		}
		
		
		public function get showLevel():Boolean
		{
			return _showLevel;
		}
		public function set showLevel(value:Boolean):void
		{
			if ( _showLevel == value )
				return;
			
			_showLevel = value;
			if ( levelDisplay )
				levelDisplay.visible = !_locked && _showLevel;
		}
		
		public function get level():int
		{
			return _level;
		}
		public function set level(value:int):void
		{
			if ( _level == value )
				return;
			
			_level = value;
			if ( showLevel && levelDisplay && _level > 0 )
				levelDisplay.text = "lvl " + _level;
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
				slider.visible = !_locked && _showSlider && _level > 0;
		}
		
		public function set locked(value:Boolean):void
		{
			if ( _locked == value )
				return;
			
			_locked = value;
			if ( slider )
				slider.visible = !_locked && showSlider && _level > 0;

			if ( skin )
				skin.defaultTexture = skin.getTextureForState(_locked?"locked":"normal");
			if ( iconDisplay )
				iconDisplay.alpha = _locked ? 0.7 : 1;
			if( levelDisplay )
				levelDisplay.visible = !_locked && showLevel;
		}
		
		
		public function get type():int
		{
			return _type;
		}
		public function set type(value:int):void
		{
			/*if(_type == value)
				return;*/
			
			_type = value;
			if( _type < 0 )
				return;
			
			var building:Building = player.buildings.get(_type);
			
			if( iconDisplay )
				iconDisplay.source = Assets.getTexture("cards/"+BuildingType.get_category(_type), "gui");
			
			if( improveDisplay )
				improveDisplay.source = Assets.getTexture("cards/improve-rank-"+BuildingType.get_improve(_type), "gui");
			
			locked = building == null;
			if( building == null )
				return;
			
			var upgradeCards:int = building.get_upgradeCards();
			var numBuildings:int = player.resources.get(type);
			if( showSlider && slider )
			{
				slider.maximum = upgradeCards;
				slider.value = numBuildings;
			}
			
			level = building.get_level();
		}
	}
}