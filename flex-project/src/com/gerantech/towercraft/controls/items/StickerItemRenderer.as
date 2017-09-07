package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.models.Assets;
	
	import flash.geom.Rectangle;
	
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.display.Image;

	public class StickerItemRenderer extends BaseCustomItemRenderer
	{
		private var labelDisplay:RTLLabel;
		public function StickerItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			var sk:Image = new Image(Assets.getTexture("sticker-item", "gui"));
			sk.scale9Grid = new Rectangle(7, 7, 1, 1);
			backgroundSkin = sk;
			layout = new AnchorLayout();
			
			labelDisplay = new RTLLabel("", 0);
			labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -6*appModel.scale);
			addChild(labelDisplay);
		}
		
		override protected function commitData():void
		{
			super.commitData();
			labelDisplay.text = loc("sticker_" + _data );
		}
		
		
	}
}