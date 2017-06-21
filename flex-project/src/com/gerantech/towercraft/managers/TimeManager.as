package com.gerantech.towercraft.managers
{
	import flash.utils.setInterval;
	
	import starling.events.Event;
	import starling.events.EventDispatcher;

	public class TimeManager extends EventDispatcher
	{
		public var now:uint;
		private var intervalId:uint;
		private static var _instance:TimeManager;
		public function TimeManager(now:uint)
		{
			_instance = this;
			this.now = now;
			intervalId = setInterval(timeCounterCallback, 1000);
		}
		
		private function timeCounterCallback():void
		{
			now ++;
			dispatchEventWith(Event.CHANGE, false, now)
		}
		
		public static function get instance():TimeManager
		{
			return _instance;
		}
	}
}