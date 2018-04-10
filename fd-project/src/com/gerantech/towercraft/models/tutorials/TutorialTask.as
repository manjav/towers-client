package com.gerantech.towercraft.models.tutorials
{
	import com.gt.towers.utils.lists.PlaceDataList;

	public class TutorialTask
	{
		public static const TYPE_MESSAGE:int = 0;
		public static const TYPE_SWIPE:int = 1;
		public static const TYPE_TOUCH:int = 2;
		public static const TYPE_CONFIRM:int = 3;
		public static const TYPE_TASK:int = 4;
		
		public var index:int;
		public var type:int;
		public var message:String;
		public var places:PlaceDataList;
		public var startAfter:int;
		public var skipableAfter:int;
		public var data:Object;
		public var parent:TutorialData;

		
		public function TutorialTask(type:int, message:String, places:PlaceDataList=null, startAfter:int = 500, skipableAfter:int = 1500, data:Object=null)
		{
			this.type = type;
			this.message = message;
			this.places = places;
			this.startAfter = startAfter;
			this.skipableAfter = skipableAfter;
			this.data = data;
		}
	}
}