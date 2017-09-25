package com.gerantech.towercraft.controls.items
{
	public class ProfileFeatureItemRenderer extends FeatureItemRenderer
	{
		override protected function commitData():void
		{
			if(_owner == null || _data == null)
				return;
			
			super.commitData();
			titleDisplay.text = loc("resource_title_" + _data.type);
			valueDisplay.text = _data.count;
		}
	}
}