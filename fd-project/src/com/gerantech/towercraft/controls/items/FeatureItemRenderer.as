package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.texts.LTRLable;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.core.Starling;

public class FeatureItemRenderer extends AbstractTouchableListItemRenderer
{
protected var titleDisplay:RTLLabel  ;
protected var valueDisplay:*;
protected var _firstCommit:Boolean = true;

public function FeatureItemRenderer(){}
override protected function initialize():void
{
	super.initialize();

	layout = new AnchorLayout();

	titleDisplay = new RTLLabel("", 1, null, null,	false, null, 0.9);
	titleDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:0, NaN, appModel.isLTR?0:NaN, NaN, 0);
	addChild(titleDisplay);
}

override protected function commitData():void
{
	if(_owner == null || _data == null)
		return;
	
	if(_firstCommit)
	{
		_firstCommit = false;
		height = 64 * appModel.scale;
	}
	addValueLabel();
	
	alpha = 0;
	Starling.juggler.tween(this, 0.2, {delay:index/30, alpha:1});
}

protected function addValueLabel():void
{
	if( valueDisplay != null )
		return;
	valueDisplay = new LTRLable("", 1, "left");
	valueDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?0:NaN, NaN, appModel.isLTR?NaN:0, NaN, 0);
	addChild(valueDisplay);
}
}
}