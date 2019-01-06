package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.controls.texts.RTLLabel;
public class ProfileFeatureItemRenderer extends FeatureItemRenderer
{
override protected function commitData():void
{
	if( _owner == null || _data == null )
		return;
	
	super.commitData();
	height = 44;
	keyDisplay.text = loc("resource_title_" + _data.getInt("type"));
	valueDisplay.text = _data.getInt("count");
}

override protected function keyLabelFactory(scale:Number = 0.7, color:uint = 0):RTLLabel
{
	return super.keyLabelFactory(scale, color);
}

override protected function valueLabelFactory(scale:Number = 0.7, color:uint = 0):void
{
	return super.valueLabelFactory(scale, color);
}
}
}