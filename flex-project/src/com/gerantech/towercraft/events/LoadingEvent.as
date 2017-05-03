package com.gerantech.towercraft.events
{
	import flash.events.Event;
	
	public class LoadingEvent extends Event
	{
		public static const LOADED:String = "loaded";
		public static const LOGIN_ERROR:String = "loginError";
		public static const NOTICE_UPDATE:String = "noticeUpdate";
		public static const FORCE_UPDATE:String = "forceUpdate";
		public static const NETWORK_ERROR:String = "networkError";
		
		public var message:String;
		
		public function LoadingEvent(type:String, message:String="", bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.message =  message;
			super(type, bubbles, cancelable);
		}
	}
}