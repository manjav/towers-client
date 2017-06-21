package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.models.Assets;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;

	public class BattleOutcomeRewardItemRenderer extends BaseCustomItemRenderer
	{
		private var iconDisplay:ImageLoader;
		private var labelDisplay:Label;
		private var reward:SFSObject;
		
		override protected function initialize():void
		{
			super.initialize();
			
			height = width = 120 * appModel.scale;
			
			layout = new AnchorLayout();
			
			iconDisplay = new ImageLoader();
			iconDisplay.layoutData = new AnchorLayoutData(0,0,0,0);
			backgroundSkin = iconDisplay;
			
			labelDisplay = new Label();
			labelDisplay.layoutData = new AnchorLayoutData(NaN,0,-20 * appModel.scale,0);
			addChild(labelDisplay);
		}
		
		override protected function commitData():void
		{
			super.commitData();
			//reward = _data as SFSObject;
			
			iconDisplay.source = Assets.getTexture("res-" + _data.t, "gui");
			labelDisplay.text = _data.c.toString();
		}
	}
}