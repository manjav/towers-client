package com.gerantech.towercraft.managers.socials
{
	import flash.events.Event;
	
	public class SocialEvent extends Event
	{
		
		public static const INIT:String = "init";
		public static const AUTHENTICATE:String = "authenticate";
		public static const FAILURE:String = "failure";
		
		public var errorMessage:String;
		
		public function SocialEvent(type:String, errorMessage:String=null)
		{
			this.errorMessage = errorMessage;
			super(type, false, false);
		}
	}
}