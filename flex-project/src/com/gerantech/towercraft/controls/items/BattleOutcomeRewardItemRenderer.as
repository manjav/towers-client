package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.controls.BuildingCard;
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.constants.ResourceType;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.text.BitmapFontTextFormat;
	
	import starling.events.Event;

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
			
			/*buildingCrad = new BuildingCard();
			buildingCrad.layoutData = new AnchorLayoutData(0,0,0,0);
			buildingCrad.showLevel = false;
			buildingCrad.showSlider = false;*/
		}
		
		override protected function commitData():void
		{
			super.commitData();
			
			removeChildren();
			/*if( ResourceType.isBuilding(_data.t) )
			{
				buildingCrad.type = _data.t;
				addChild(buildingCrad)
			}
			else
			{*/
				iconDisplay.source = Assets.getTexture("res-" + _data.t, "gui");
				addChild(iconDisplay)
			//}
			
			labelDisplay.text = _data.c.toString();
			addChild(labelDisplay);
		}
		
		override protected function feathersControl_removedFromStageHandler(event:Event):void
		{
			if( _data.c != 0 )
			{
				var rect:Rectangle = getBounds(stage);
				appModel.navigator.dispatchEventWith("itemAchieved", true, {index:index, x:rect.x+rect.width/2, y:rect.y+rect.height/2, type:_data.t, count:_data.c});
			}
			super.feathersControl_removedFromStageHandler(event);
		}
		
		
	}
}