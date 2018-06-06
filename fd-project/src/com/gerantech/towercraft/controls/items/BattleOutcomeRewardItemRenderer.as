package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.constants.ResourceType;
import com.smartfoxserver.v2.entities.data.SFSObject;
import dragonBones.starling.StarlingArmatureDisplay;
import feathers.controls.ImageLoader;
import feathers.controls.text.BitmapFontTextRenderer;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.text.BitmapFontTextFormat;
import flash.geom.Rectangle;
import flash.utils.setTimeout;
import starling.events.Event;

public class BattleOutcomeRewardItemRenderer extends AbstractTouchableListItemRenderer
{
private var iconDisplay:ImageLoader;
private var labelDisplay:BitmapFontTextRenderer;
private var reward:SFSObject;
private var buildingCrad:BuildingCard;
private var armatureDisplay:StarlingArmatureDisplay;

public function BattleOutcomeRewardItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	height = width = 200 * appModel.scale;
}

override protected function commitData():void
{
	super.commitData();
	
	if( ResourceType.isBook(_data.t) )
	{
		armatureDisplay = OpenBookOverlay.factory.buildArmatureDisplay("book-" + _data.t);
		armatureDisplay.animation.gotoAndStopByProgress("appear", 1);
		armatureDisplay.animation.timeScale = 0;
		armatureDisplay.x = width * 0.5;
		armatureDisplay.y = height * 0.5;
		armatureDisplay.scale = appModel.scale * 0.8;
		addChild(armatureDisplay);
	}
	else
	{
		iconDisplay = new ImageLoader();
		iconDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -40 * appModel.scale);
		iconDisplay.source = Assets.getTexture("res-" + _data.t, "gui");
		iconDisplay.scale = appModel.scale * 2;
		addChild(iconDisplay);
		
		labelDisplay = new BitmapFontTextRenderer();//imageDisplay.width, imageDisplay.width/2, "");
		labelDisplay.text = _data.c.toString();
		labelDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 64 * appModel.scale, 0xFFFFFF, "center");
		labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 60 * appModel.scale);
		addChild(labelDisplay);	
	}
}

override protected function feathersControl_removedFromStageHandler(event:Event):void
{
	if( _data.c != 0 )// && !SFSConnection.instance.mySelf.isSpectator
	{
		var rect:Rectangle = getBounds(stage);
		setTimeout(appModel.navigator.dispatchEventWith, 200, "itemAchieved", true, {index:index, x:rect.x + rect.width * 0.5, y:rect.y + rect.height * 0.5, type:_data.t, count:_data.c});
	}
	super.feathersControl_removedFromStageHandler(event);
}
}
}