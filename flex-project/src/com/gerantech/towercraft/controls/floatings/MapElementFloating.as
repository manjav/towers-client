package com.gerantech.towercraft.controls.floatings
{
	import com.gerantech.towercraft.controls.RTLLabel;
	import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.events.Event;

	public class MapElementFloating extends BaseFloating
	{
		public var element:DisplayObject;
		public function MapElementFloating(element:DisplayObject)
		{
			this.element = element;
			super();
		}
		
		
		override protected function initialize():void
		{
			super.initialize();
			overlay.visible = false;
		
			layout = new AnchorLayout();
			
			width = 320*appModel.scale;
			height = 140*appModel.scale;
			
			
			var simpleLayoutButton:SimpleLayoutButton = new SimpleLayoutButton();
			simpleLayoutButton.layoutData = new AnchorLayoutData(0, 0, 0, 0);
			simpleLayoutButton.addEventListener(Event.TRIGGERED, buttonTrigeredHandler);
			addChild(simpleLayoutButton);
			
			var skin:Image = new Image(appModel.theme.buttonUpSkinTexture);
			skin.scale9Grid = BaseMetalWorksMobileTheme.BUTTON_SCALE9_GRID;
			simpleLayoutButton.backgroundSkin = skin;
			
			var txt:RTLLabel = new RTLLabel(loc("map-"+element.name), 0, "center", null, false, null, 0, null, "bold");
			txt.touchable = false
			txt.pixelSnapping = false;
			txt.layoutData = new AnchorLayoutData(NaN, 0, NaN, 0, NaN, 0);
			addChild(txt);
		}
		
		private function buttonTrigeredHandler(event:Event):void
		{
			dispatchEventWith(Event.SELECT, false, element);
		}
	}
}