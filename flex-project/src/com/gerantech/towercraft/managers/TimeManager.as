package com.gerantech.towercraft.managers
{
	import flash.utils.setInterval;
	
	import starling.events.Event;
	import starling.events.EventDispatcher;

	public class TimeManager extends EventDispatcher
	{
		private var _now:uint;
		private var intervalId:uint;
		private static var _instance:TimeManager;
		public function TimeManager(now:uint)
		{
			_instance = this;
			_now = now;
			intervalId = setInterval(timeCounterCallback, 1000);
		}
		
		public function get now():uint
		{
			return _now;
		}

		private function set now(value:uint):void
		{
			_now = value;
		}

		private function timeCounterCallback():void
		{
			_now ++;
			dispatchEventWith(Event.CHANGE, false, _now)
		}
		
		public static function get instance():TimeManager
		{
			return _instance;
		}
	}
}