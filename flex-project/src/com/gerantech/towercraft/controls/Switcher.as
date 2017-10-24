package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.controls.buttons.CustomButton;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.display.Image;
	import starling.events.Event;

	public class Switcher extends TowersLayout
	{
		public var min:int;
		public var max:int;
		public var stepInterval:int;
		private var _value:int;

		private var labelDisplay:RTLLabel;
		
		public function Switcher(min:int = 0, value:int = 5, max:int = 10, stepInterval:int = 1)
		{
			this.min = min;
			this.value = value;
			this.max = max;
			this.stepInterval = stepInterval;
		}


		override protected function initialize():void
		{
			super.initialize();
			
			layout = new AnchorLayout();
			var controlSize:int = 96 * appModel.scale;
			minWidth = 120 * appModel.scale;
			minHeight = controlSize;
			
			var skin:Image = new Image(Assets.getTexture("theme/slider-background", "gui"));
			skin.scale9Grid = BaseMetalWorksMobileTheme.SLIDER_SCALE9_GRID;
			backgroundSkin = skin;
			
			var leftButton:CustomButton = new CustomButton();
			leftButton.label = ">";
			leftButton.width = controlSize;
			leftButton.layoutData = new AnchorLayoutData(0, NaN, 0, 0);
			leftButton.addEventListener(Event.TRIGGERED, leftButton_triggerdHandler);
			addChild(leftButton);
			
			var rightButton:CustomButton = new CustomButton();
			rightButton.label = "<";
			rightButton.width = controlSize;
			rightButton.layoutData = new AnchorLayoutData(0, 0, 0, NaN);
			rightButton.addEventListener(Event.TRIGGERED, rightButton_triggerdHandler);
			addChild(rightButton);
			
			labelDisplay = new RTLLabel(value.toString(), 0, "center", null, false, null, 0.8);
			labelDisplay.layoutData = new AnchorLayoutData(NaN, controlSize, NaN, controlSize, NaN, 0);
			addChild(labelDisplay);
		}
		
		private function leftButton_triggerdHandler(event:Event):void
		{
			value = Math.max(Math.min(max, value-stepInterval), min);
		}
		
		private function rightButton_triggerdHandler(event:Event):void
		{
			value = Math.max(Math.min(max, value+stepInterval), min);
		}
		
		
		public function get value():int
		{
			return _value;
		}
		public function set value(val:int):void
		{
			if( _value == val )
				return;
			
			_value = val;
			if( labelDisplay )
				labelDisplay.text = _value.toString();
		}
		
	}
}