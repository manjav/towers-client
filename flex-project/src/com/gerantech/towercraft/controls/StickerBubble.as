package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.models.Assets;
	
	import flash.geom.Rectangle;
	
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalLayout;
	
	import starling.display.Image;

	public class StickerBubble extends TowersLayout
	{
		private var _label:String = "";
		private var _type:int;
		
		private var labelDisplay:RTLLabel;
		private var inverse:Boolean;
		
		public function StickerBubble(inverse:Boolean = false)
		{
			super();
			this.inverse = inverse;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			var sk:Image = new Image(Assets.getTexture("sticker-bubble-"+(inverse?"opponent":"me"), "gui"));
			sk.scale9Grid = new Rectangle(inverse?19:7, inverse?17:7, 1, 1);
			backgroundSkin = sk;
			
			var hlayout:HorizontalLayout = new HorizontalLayout();
			hlayout.padding = 36*appModel.scale;
			hlayout.paddingTop = (inverse?60:24)*appModel.scale;
			hlayout.paddingBottom = (inverse?36:72)*appModel.scale;
			layout = hlayout;
			
			labelDisplay = new RTLLabel(_label, 0, "center", null, false, null, 1.2);
			labelDisplay.pixelSnapping = false;
			addChild(labelDisplay);
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
			if(labelDisplay)
				labelDisplay.text = _label;
		}
		
		public function get type():int
		{
			return _type;
		}
		public function set type(value:int):void
		{
			if(_type == value)
				return;
			_type = value;
			label = loc( "sticker_" + _type );
		}
		
	}
}