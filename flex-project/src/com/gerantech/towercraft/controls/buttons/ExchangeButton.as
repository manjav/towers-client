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
		private var _label:String = "";

		private var padding:Number;

		private var hasIcon:Boolean;

		private var labelLayoutData:AnchorLayoutData;
		private var shadowLayoutData:AnchorLayoutData;

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
			
			shadowLayoutData = new AnchorLayoutData(NaN, padding, NaN, padding, NaN, -padding*0.60);
			shadowDisplay = new RTLLabel(_label, 0x002200, "center");
			shadowDisplay.touchable = false;
			shadowDisplay.layoutData = shadowLayoutData;
			addChild(shadowDisplay);
		
			labelLayoutData = new AnchorLayoutData(NaN, padding, NaN, padding, NaN, 0);
			labelDisplay = new RTLLabel(_label, 0XEEFFEE, "center");
			labelDisplay.touchable = false;
			labelDisplay.layoutData = labelLayoutData;
			addChild(labelDisplay);
			
			iconDisplay = new ImageLoader();
			labelDisplay.touchable = false;
			iconDisplay.layoutData = new AnchorLayoutData(padding, padding, padding*2, NaN);
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
			
			hasIcon = _type > 0 && _type!= ResourceType.CURRENCY_REAL;
			if( hasIcon )
			{
				iconDisplay.source = Assets.getTexture("res-"+_type, "gui");
				addChild(iconDisplay);
			}
			else
			{
				iconDisplay.removeFromParent();
			}
			labelLayoutData.right = (hasIcon?10:1)*padding;
			shadowLayoutData.right = (hasIcon?10:1)*padding;
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
			if( labelDisplay )
				labelDisplay.text = _label
			if( shadowDisplay )
				shadowDisplay.text = _label
		}
		
		override public function set currentState(value:String):void
		{
			if(super.currentState == value)
				return;
			
			super.currentState = value;
			shadowLayoutData.verticalCenter = -padding*(value==ButtonState.DOWN?0.2:0.6)
		}
	}
}