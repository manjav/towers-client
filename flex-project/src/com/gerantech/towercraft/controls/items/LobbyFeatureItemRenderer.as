package com.gerantech.towercraft.controls.items
{
	public class LobbyFeatureItemRenderer extends FeatureItemRenderer
	{
		override protected function commitData():void
		{
			if(_owner == null || _data == null)
				return;
			
			super.commitData();
			titleDisplay.text = loc("lobby_" + _data.key);
			valueDisplay.text = _data.value;
		}
	}
}