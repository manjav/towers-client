package com.gerantech.towercraft.controls.items.lobby
{
import com.gerantech.towercraft.controls.items.FeatureItemRenderer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import feathers.layout.AnchorLayoutData;

public class LobbyFeatureItemRenderer extends FeatureItemRenderer
{
override protected function commitData():void
{
	if( _owner == null || _data == null )
		return;
	
	super.commitData();
	height = 48 * appModel.scale;
	keyDisplay.text = loc("lobby_" + _data.key);
	valueDisplay.text = _data.key == "pri" ? loc("lobby_pri_" + _data.value) : _data.value;
}

override protected function keyLabelFactory():RTLLabel
{
	if( keyDisplay != null )
		return null;
	keyDisplay = new RTLLabel("", 1, null, null,	false, null, 0.8);
	keyDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:0, NaN, appModel.isLTR?0:NaN, NaN, 0);
	addChild(keyDisplay);
	return keyDisplay;
}

override protected function valueLabelFactory():void
{
	if( valueDisplay != null )
		return;
	valueDisplay = new RTLLabel("", 1, "left", null, false, null, 0.8);
	valueDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?0:NaN, NaN, appModel.isLTR?NaN:0, NaN, 0);
	addChild(valueDisplay);
}
}
}