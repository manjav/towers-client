package com.gerantech.towercraft.controls.headers
{
	import com.gerantech.towercraft.controls.TowersLayout;
	import com.gerantech.towercraft.controls.buttons.CustomButton;
	import com.gerantech.towercraft.controls.popups.MessagePopup;
	import com.gerantech.towercraft.controls.texts.ShadowLabel;
	import com.gerantech.towercraft.controls.tooltips.BaseTooltip;
	import com.gerantech.towercraft.models.Assets;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.display.Image;
	import starling.events.Event;
	
	public class ExchangeHeader extends TowersLayout
	{
		private var fontSize:int;
		private var skin:Image;
		private var labelDisplay:ShadowLabel;
		private var _label:String;
		public var data:Object;
		
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
			var padding:int = 24 * appModel.scale;
			
			labelDisplay = new ShadowLabel(_label, 1, 0, null, null, false, null, fontSize, null, "bold");
			labelDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding*1, NaN, appModel.isLTR?padding*1:NaN, NaN, -6*appModel.scale);
			addChild(labelDisplay);
			
			var infoButton:CustomButton = new CustomButton();
			infoButton.label = "i";
			infoButton.width = height -  padding * 2;
			infoButton.layoutData = new AnchorLayoutData(padding, appModel.isLTR?padding:NaN, padding, appModel.isLTR?NaN:padding);
			infoButton.addEventListener(Event.TRIGGERED, infoButton_trigeredHandler);
			addChild(infoButton);
		}
		
		private function infoButton_trigeredHandler(event:Event):void
		{
			appModel.navigator.addChild(new BaseTooltip(loc("tooltip_exchange_" + data), CustomButton(event.currentTarget).getBounds(stage)));
		}
		
		public function set label(value:String):void
		{
			if( _label == value )
				return;
			
			_label = value;
			if( labelDisplay )
				labelDisplay.text = _label;
		}
	}
}