package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;

import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;

import starling.events.Event;

public class LobbyItemRenderer extends BaseCustomItemRenderer
{
	private static const DEFAULT_TEXT_COLOR:uint = 0xDDFFFF;
	
	private var nameDisplay:RTLLabel;
	private var nameShadowDisplay:RTLLabel;
	private var pointDisplay:RTLLabel;
	private var populationDisplay:RTLLabel;

	private var mySkin:ImageSkin;

	private var activenessDisplay:RTLLabel;

	override protected function initialize():void
	{
		super.initialize();
		
		layout = new AnchorLayout();
		var padding:int = 36 * appModel.scale;
		
		mySkin = new ImageSkin(appModel.theme.itemRendererUpSkinTexture);
		mySkin.scale9Grid = BaseMetalWorksMobileTheme.ITEM_RENDERER_SCALE9_GRID
		backgroundSkin = mySkin;
		
		nameShadowDisplay = new RTLLabel("", 0, null, null, false, null, 0.9);
		nameShadowDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN, NaN, 0);
		nameShadowDisplay.pixelSnapping = false;
		addChild(nameShadowDisplay);
		
		nameDisplay = new RTLLabel("", DEFAULT_TEXT_COLOR, null, null, false, null, 0.9);
		nameDisplay.pixelSnapping = false;
		nameDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN, NaN, -padding/12);
		addChild(nameDisplay);
		
		activenessDisplay = new RTLLabel("", 1, "center", null, false, null, 0.9);
		activenessDisplay.width = padding * 4;
		activenessDisplay.pixelSnapping = false;
		activenessDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?padding*11:NaN, NaN, appModel.isLTR?NaN:padding*11, NaN, 0);
		addChild(activenessDisplay);
		
		populationDisplay = new RTLLabel("", 0, "center", null, false, null, 0.9);
		populationDisplay.width = padding * 4;
		populationDisplay.pixelSnapping = false;
		populationDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?padding*6:NaN, NaN, appModel.isLTR?NaN:padding*6, NaN, 0);
		addChild(populationDisplay);
		
		pointDisplay = new RTLLabel("", 1, appModel.isLTR?"right":"left", null, false, null, 0.9);
		pointDisplay.pixelSnapping = false;
		pointDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding, NaN, 0);
		addChild(pointDisplay);
		
		/*pointIconDisplay = new ImageLoader();
		pointIconDisplay.source = Assets.getTexture("res-1001", "gui");
		pointIconDisplay.layoutData = new AnchorLayoutData(padding/3, appModel.isLTR?padding/2:NaN, padding/2, appModel.isLTR?NaN:padding/2);
		addChild(pointIconDisplay);*/
		
		addEventListener(Event.TRIGGERED, item_triggeredHandler);
	}
	
	override protected function commitData():void
	{
		super.commitData();
		if(_data ==null || _owner==null)
			return;
		
		height = 120 * appModel.scale;
		nameDisplay.text = _data.name ;
		nameShadowDisplay.text = _data.name ;
		activenessDisplay.text = "" + _data.act;
		pointDisplay.text = "" + _data.sum;
		populationDisplay.text = _data.num + "/" + _data.max;
	}
	
	private function item_triggeredHandler():void
	{
		owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, this);
	}
} 
}