package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	
	import feathers.controls.ProgressBar;
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.text.BitmapFontTextFormat;
	
	public class BuildingSlider extends ProgressBar
	{
		private var labelDisplay:BitmapFontTextRenderer;
		public function BuildingSlider()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			labelDisplay = new BitmapFontTextRenderer();
			labelDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 48*AppModel.instance.scale, 0xFFFFFF, "center");
			//labelDisplay.x = 0;
			//labelDisplay.y = height*0.7;
		}
		
		override protected function draw():void
		{
			labelDisplay.width = width;
			super.draw();
		}
		
		
		
		override public function set value(newValue:Number):void
		{
			super.value = Math.max(0, Math.min( newValue, maximum ) );
			labelDisplay.text = newValue + " / " + maximum;
			addChild(labelDisplay);
			isEnabled = newValue >= maximum;
		}
		
		
		
		
	}
}