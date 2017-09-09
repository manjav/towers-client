package com.gerantech.towercraft.models.vo
{
	public class SettingsData
	{
		public static const MUSIC:int = 0;
		public static const SFX:int = 1;
		public static const NOTIFICATION:int = 2;
		public static const LOCALE:int = 3;
		
		public static const LINK_DEVICE:int = 10;
		public static const LEGALS:int = 11;
		
		public static const TYPE_TOGGLE:int = 0;
		public static const TYPE_BUTTON:int = 1;
		public static const TYPE_LABEL_BUTTONS:int = 2;
		public static const TYPE_ICON_BUTTONS:int = 3;
		
		public static const BUG_REPORT:int = 21;
		public static const QUESTIONS:int = 22;

		public static const SOCIAL_TELEGRAM:int = 311;
		public static const SOCIAL_INSTAGRAM:int = 312;
		public static const SOCIAL_FACEBOOOK:int = 313;
		public static const SOCIAL_YOUTUBE:int = 314;
		public static const RATING:int = 315;

		public var index:int;
		public var key:int;
		public var type:int;
		public var value:Object;
		
		public function SettingsData(key:int, type:int, value:Object)
		{
			this.key = key;
			this.type = type;
			this.value = value;
		}
	}
}