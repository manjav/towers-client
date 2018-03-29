package com.gerantech.towercraft.controls.items.lobboy
{
	import com.gerantech.towercraft.controls.items.FeatureItemRenderer;
	import com.gerantech.towercraft.controls.texts.LTRLable;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	
	import feathers.layout.AnchorLayoutData;

public class LobbyFeatureItemRenderer extends FeatureItemRenderer
{
override protected function commitData():void
{
	if(_owner == null || _data == null)
		return;
	
	super.commitData();
	titleDisplay.text = loc("lobby_" + _data.key);
	valueDisplay.text = _data.key == "pri" ? loc("lobby_pri_" + _data.value) : _data.value;
}

override protected function addValueLabel():void
{
	if( valueDisplay != null )
		return;
	valueDisplay = new RTLLabel("", 1, "left", null, false, null, 0.8);
	valueDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?0:NaN, NaN, appModel.isLTR?NaN:0, NaN, 0);
	addChild(valueDisplay);
}
}
}