package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.constants.ResourceType;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.text.BitmapFontTextFormat;

	public class BattleOutcomeRewardItemRenderer extends BaseCustomItemRenderer
	{
		private var iconDisplay:ImageLoader;
		private var labelDisplay:BitmapFontTextRenderer;
		private var reward:SFSObject;
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			
			iconDisplay = new ImageLoader();
			iconDisplay.layoutData = new AnchorLayoutData(0,0,0,0);
			backgroundSkin = iconDisplay;
			
			labelDisplay = new BitmapFontTextRenderer();//imageDisplay.width, imageDisplay.width/2, "");
			labelDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 32*appModel.scale, 0xFFFFFF, "center")
			labelDisplay.layoutData = new AnchorLayoutData(NaN,0,-72*appModel.scale,0);
			addChild(labelDisplay);
		}
		
		override protected function commitData():void
		{
			super.commitData();
			height = width = _owner.height/2;
			
			iconDisplay.source = Assets.getTexture((ResourceType.isBuilding(_data.t)?"building-":"res-") + _data.t, "gui");
			labelDisplay.text = _data.c.toString();
		}
	}
}