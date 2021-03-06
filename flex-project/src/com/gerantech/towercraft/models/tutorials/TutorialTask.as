package com.gerantech.towercraft.models.tutorials
{
	import com.gt.towers.utils.lists.PlaceDataList;

	public class TutorialTask
	{
		public static const TYPE_MESSAGE:int = 0;
		public static const TYPE_SWIPE:int = 1;
		public static const TYPE_TOUCH:int = 2;
		public static const TYPE_CONFIRM:int = 3;
		
		public var index:int;
		public var type:int;
		public var message:String;
		public var places:PlaceDataList;
		public var startAfter:int;
		public var skipableAfter:int;
		public var data:Object;

		
		public function TutorialTask(type:int, message:String, places:PlaceDataList=null, startAfter:int = 1000, enableAfter:int = 1000, data:Object=null)
		{
			this.type = type;
			this.message = message;
			this.places = places;
			this.startAfter = startAfter;
			this.skipableAfter = enableAfter;
			this.data = data;
		}
	}
}