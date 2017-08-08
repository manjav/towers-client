package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.controls.BuildingCard;
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.constants.ResourceType;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.text.BitmapFontTextFormat;

	public class BattleOutcomeRewardItemRenderer extends BaseCustomItemRenderer
	{
		private var iconDisplay:ImageLoader;
		private var labelDisplay:BitmapFontTextRenderer;
		private var reward:SFSObject;
		private var buildingCrad:BuildingCard;
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			width = 200 * appModel.scale;
			height = 240 * appModel.scale;
			
			iconDisplay = new ImageLoader();
			iconDisplay.layoutData = new AnchorLayoutData(width/7,width/7,width/7,width/7);
			
			labelDisplay = new BitmapFontTextRenderer();//imageDisplay.width, imageDisplay.width/2, "");
			labelDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 64*appModel.scale, 0xFFFFFF, "center")
			labelDisplay.layoutData = new AnchorLayoutData(NaN,0,-90*appModel.scale,0);
			addChild(labelDisplay);
			
			buildingCrad = new BuildingCard();
			buildingCrad.layoutData = new AnchorLayoutData(0,0,0,0);
			buildingCrad.showLevel = false;
			buildingCrad.showSlider = false;
		}
		
		override protected function commitData():void
		{
			super.commitData();
			
			removeChildren();
			if( ResourceType.isBuilding(_data.t) )
			{
				buildingCrad.type = _data.t;
				addChild(buildingCrad)
			}
			else
			{
				iconDisplay.source = Assets.getTexture("res-" + _data.t, "gui");
				addChild(iconDisplay)
			}
			
			labelDisplay.text = _data.c.toString();
			addChild(labelDisplay);
		}
	}
}