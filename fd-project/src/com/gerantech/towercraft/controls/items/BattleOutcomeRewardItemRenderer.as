package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.controls.BuildingCard;
	import com.gerantech.towercraft.models.Assets;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.text.BitmapFontTextFormat;
	
	import starling.events.Event;

	public class BattleOutcomeRewardItemRenderer extends AbstractTouchableListItemRenderer
	{
		private var iconDisplay:ImageLoader;
		private var labelDisplay:BitmapFontTextRenderer;
		private var reward:SFSObject;
		private var buildingCrad:BuildingCard;
		
		public function BattleOutcomeRewardItemRenderer(){}
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			width = 200 * appModel.scale;
			
			iconDisplay = new ImageLoader();
			iconDisplay.layoutData = new AnchorLayoutData(NaN,NaN,NaN,NaN,0,-40*appModel.scale);
			iconDisplay.scale = appModel.scale * 2;
			addChild(iconDisplay)
			
			labelDisplay = new BitmapFontTextRenderer();//imageDisplay.width, imageDisplay.width/2, "");
			labelDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 64*appModel.scale, 0xFFFFFF, "center")
			labelDisplay.layoutData = new AnchorLayoutData(NaN,NaN,NaN,NaN,0,60*appModel.scale);
			addChild(labelDisplay);

		}
		
		override protected function commitData():void
		{
			super.commitData();
			iconDisplay.source = Assets.getTexture("res-" + _data.t, "gui");
			labelDisplay.text = _data.c.toString();
		}
		
		override protected function feathersControl_removedFromStageHandler(event:Event):void
		{
			if( _data.c != 0 )// && !SFSConnection.instance.mySelf.isSpectator
			{
				var rect:Rectangle = getBounds(stage);
				appModel.navigator.dispatchEventWith("itemAchieved", true, {index:index, x:rect.x+rect.width/2, y:rect.y+rect.height/2, type:_data.t, count:_data.c});
			}
			super.feathersControl_removedFromStageHandler(event);
		}
		
		
	}
}