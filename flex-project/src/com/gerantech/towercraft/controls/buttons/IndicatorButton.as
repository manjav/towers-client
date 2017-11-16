package com.gerantech.towercraft.controls.buttons
{
	import com.gerantech.towercraft.controls.Devider;
	
	import feathers.layout.AnchorLayoutData;

	public class IndicatorButton extends CustomButton
	{
		public function IndicatorButton()
		{
			super();
		}
		
		override protected function initialize():void
		{
			label = "+";
			fontsize = 1.6;
			
			super.initialize();
			
			var padding:int = 16 * appModel.scale;
			var overlay:Devider = new Devider(0, 1);
			overlay.alpha = 0;
			overlay.layoutData = new AnchorLayoutData(-padding, -padding, -padding, -padding);
			addChild(overlay);
		}
		
		
	}
}