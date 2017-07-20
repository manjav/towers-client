package com.gerantech.towercraft.controls.buttons
{
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	import com.gt.towers.constants.ResourceType;
	
	import feathers.controls.ButtonState;
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.skins.ImageSkin;
	
	public class ExchangeButton extends SimpleLayoutButton
	{
		private var labelDisplay:RTLLabel;
		private var shadowDisplay:RTLLabel;
		private var iconDisplay:ImageLoader;
		
		private var _type:int;
		private var _count:int;
		public var currency:String = "";
		private var _label:String;

		private var padding:Number;

		override protected function initialize():void
		{
			super.initialize();
			if( width == 0 )
				width = 240 * appModel.scale;
			minWidth = 72 * appModel.scale;
			minHeight = 72 * appModel.scale;
			maxHeight = 96 * appModel.scale;
			padding = 8 * appModel.scale;
			
			skin = new ImageSkin(appModel.theme.buttonUpSkinTexture);
			skin.setTextureForState(ButtonState.UP, appModel.theme.buttonUpSkinTexture);
			skin.setTextureForState(ButtonState.DOWN, appModel.theme.buttonDownSkinTexture);
			skin.setTextureForState(ButtonState.DISABLED, appModel.theme.buttonDisabledSkinTexture);
			skin.scale9Grid = BaseMetalWorksMobileTheme.BUTTON_SCALE9_GRID;
			backgroundSkin = skin;
			
			layout = new AnchorLayout();
			
			shadowDisplay = new RTLLabel("", 0, "center", null, false, null, 0, null, "bold");
			shadowDisplay.touchable = false;
			addChild(shadowDisplay);
			
			labelDisplay = new RTLLabel("", 1, "center", null, false, null, 0, null, "bold");
			labelDisplay.touchable = false;
			addChild(labelDisplay);
			
			iconDisplay = new ImageLoader();
			labelDisplay.touchable = false;
			iconDisplay.layoutData = new AnchorLayoutData(padding, padding, padding*2, NaN);
		//	iconDisplay.layoutData = new HorizontalLayoutData(NaN, 80);
		}
		
		
		public function set count(value:int):void
		{
			if(_count == value)
				return;
			_count = value;
			
			if(_count == -1)
				label = loc("open_label");
			else if(_count == 0)
				label = loc("free_label");
			else
				label = _count.toString() + " " + currency;
		}
		
		public function set type(value:int):void
		{
			if(_type == value)
				return;
			_type = value;
			
			var hasIcon:Boolean = _type > 0 && _type!= ResourceType.CURRENCY_REAL;
			if( hasIcon )
			{
				iconDisplay.source = Assets.getTexture("res-"+_type, "gui");
				addChild(iconDisplay);
			}
			else
			{
				iconDisplay.removeFromParent();
			}
			labelDisplay.layoutData = new AnchorLayoutData(NaN, (hasIcon?10:1)*padding, NaN, padding, NaN, -padding*0.6);
			shadowDisplay.layoutData = new AnchorLayoutData(NaN, (hasIcon?10:1)*padding, NaN, padding, NaN, 0);
		}
		
		
		public function get label():String
		{
			return _label;
		}
		public function set label(value:String):void
		{
			if(_label == value)
				return;
			_label = value;
			labelDisplay.text = _label
			shadowDisplay.text = _label
		}

	}
}