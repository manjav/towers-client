package com.gerantech.towercraft.controls.headers
{
	import com.gerantech.towercraft.controls.TowersLayout;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.models.Assets;
	
	import flash.geom.Rectangle;
	
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.display.Image;
	
	public class ExchangeHeader extends TowersLayout
	{
		
		private var fontSize:int;
		private var skin:Image;
		private var labelDisplay:RTLLabel;
		private var _label:String;
		
		public function ExchangeHeader(texture:String, scale9Grid:Rectangle, fontSize:int)
		{
			this.fontSize = fontSize;
			skin = new Image(Assets.getTexture(texture, "gui"));
			skin.scale9Grid = scale9Grid;
		}
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout(); 

			backgroundSkin = skin;
			
			labelDisplay = new RTLLabel(_label, 1, null, null, false, null, fontSize, null, "bold");
			labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -10*appModel.scale);
			addChild(labelDisplay);
		}
		
		public function set label(value:String):void
		{
			if(_label == value)
				return;
			
			_label = value;
			if(labelDisplay)
				labelDisplay.text = _label;
		}
	}
}