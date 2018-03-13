package com.gerantech.towercraft.controls
{
	import feathers.controls.List;
	import feathers.controls.ScrollBarDisplayMode;
	
	public class FastList extends List
	{
		public function FastList()
		{
			super();
			_fixedThrowDuration = 1;
			scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
		}
	}
}