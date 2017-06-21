package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.models.AppModel;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.LayoutGroup;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.display.Image;
	
	public class ExchangeHeader extends LayoutGroup
	{
		
		private var fontSize:int;
		private var skin:Image;
		private var labelDisplay:RTLLabel;
		
		public function ExchangeHeader(texture:String, scale9Grid:Rectangle, fontSize:int)
		{
			this.fontSize = fontSize;
			skin = new Image(AppModel.instance.assetsManager.getTexture(texture));
			skin.scale9Grid = scale9Grid;
		}
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout(); 

			backgroundSkin = skin;
			
			labelDisplay = new RTLLabel("", 1, null, null, false, null, fontSize, null, "bold");
			labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -8*AppModel.instance.scale);
			addChild(labelDisplay);
		}
		
		public function set label(value:String):void
		{
			labelDisplay.text = value;
		}
	}
}