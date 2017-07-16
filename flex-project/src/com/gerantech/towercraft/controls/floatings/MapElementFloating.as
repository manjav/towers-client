package com.gerantech.towercraft.controls.floatings
{
	import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.events.Event;

	public class MapElementFloating extends BaseFloating
	{
		public var element:DisplayObject;
		public var locked:Boolean;
		
		public function MapElementFloating(element:DisplayObject, locked)
		{
			this.element = element;
			this.locked = locked;
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			overlay.visible = false;
			layout = new AnchorLayout();
			
			var simpleLayoutButton:SimpleLayoutButton = new SimpleLayoutButton();
			simpleLayoutButton.layoutData = new AnchorLayoutData(0, 0, 0, 0);
			simpleLayoutButton.addEventListener(Event.TRIGGERED, buttonTrigeredHandler);
			addChild(simpleLayoutButton);
			
			var skin:Image = new Image(locked?appModel.theme.buttonDisabledSkinTexture:appModel.theme.buttonUpSkinTexture);
			skin.scale9Grid = BaseMetalWorksMobileTheme.BUTTON_SCALE9_GRID;
			simpleLayoutButton.backgroundSkin = skin;
			
			var txt:RTLLabel = new RTLLabel(loc("map-"+element.name), 0, "center", null, false, null, 0, null, "bold");
			txt.touchable = false
			txt.pixelSnapping = false;
			txt.layoutData = new AnchorLayoutData(NaN, locked?height*0.5:0, NaN, 0, NaN, 0);
			addChild(txt);
			
			if( locked )
			{
				var lockDisplay:ImageLoader = new ImageLoader();
				lockDisplay.width = lockDisplay.height = height*0.6;
				lockDisplay.source = Assets.getTexture("improve-lock", "gui");
				lockDisplay.layoutData = new AnchorLayoutData(NaN, height*0.15, NaN, NaN, NaN, 0);
				lockDisplay.touchable = false;
				addChild(lockDisplay);
			}
		}
		
		private function buttonTrigeredHandler(event:Event):void
		{
			dispatchEventWith(Event.SELECT, false, element);
		}
	}
}