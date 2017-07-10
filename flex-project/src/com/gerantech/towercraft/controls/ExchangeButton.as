package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	import com.gt.towers.constants.ResourceType;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.LayoutGroup;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.HorizontalLayoutData;
	import feathers.layout.VerticalAlign;
	
	import starling.display.Image;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	
	public class ExchangeButton extends LayoutGroup
	{
		private var labelDisplay:RTLLabel;
		private var iconDisplay:ImageLoader;
		
		private var _type:int;
		private var _price:int;
		
		override protected function initialize():void
		{
			super.initialize();
			minWidth = 220 * AppModel.instance.scale;
			minHeight = 72 * AppModel.instance.scale;
			
			var skin:Image = new Image(AppModel.instance.theme.buttonUpSkinTexture);
			skin.scale9Grid = BaseMetalWorksMobileTheme.BUTTON_SCALE9_GRID;
			backgroundSkin = skin;
			
			var hlayout:HorizontalLayout = new HorizontalLayout();
			hlayout.padding = hlayout.gap = 10 * AppModel.instance.scale
			hlayout.verticalAlign = VerticalAlign.MIDDLE;
			layout = hlayout;
			
			labelDisplay = new RTLLabel("", 1, "center", null, false, null, 0, null, "bold");
			labelDisplay.layoutData = new HorizontalLayoutData(100);
			addChild(labelDisplay);
			
			iconDisplay = new ImageLoader();
			iconDisplay.layoutData = new HorizontalLayoutData(NaN, 80);
		}
		
		
		public function set price(value:int):void
		{
			if(_price == value)
				return;
			_price = value;
			
			if(_price == -1)
				labelDisplay.text = "Open";
			else if(_price == 0)
				labelDisplay.text = "Free";
			else
				labelDisplay.text = _price.toString();
			
		}
		
		public function set type(value:int):void
		{
			if(_type == value)
				return;
			_type = value;
			
			if(_type > 0 && _type!= ResourceType.CURRENCY_REAL)
			{
				iconDisplay.source = Assets.getTexture("res-"+_type, "gui");
				addChild(iconDisplay);
			}
			else
			{
				iconDisplay.removeFromParent();
			}
		}
	}
}