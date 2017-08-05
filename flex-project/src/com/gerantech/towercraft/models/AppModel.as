package com.gerantech.towercraft.models
{
	import com.gerantech.towercraft.controls.StackNavigator;
	import com.gerantech.towercraft.managers.net.LoadingManager;
	import com.gerantech.towercraft.models.vo.Descriptor;
	import com.gerantech.towercraft.themes.MetalWorksMobileTheme;
	import com.gerantech.towercraft.views.BattleFieldView;
	import com.gt.towers.Game;
	
	import flash.desktop.NativeApplication;
	import flash.system.Capabilities;
	
	import starling.utils.AssetManager;
	import com.gerantech.towercraft.managers.SoundManager;

	public class AppModel
	{
		private static var _instance:AppModel;
		
		public var theme:MetalWorksMobileTheme;
		public var navigator:StackNavigator;
		public var loadingManager:LoadingManager;
		public var battleFieldView:BattleFieldView;
		
		public static const PLATFORM_WINDOWS:int = 0;
		public static const PLATFORM_MAC:int = 1;
		public static const PLATFORM_ANDROID:int = 2;
		public static const PLATFORM_IOS:int = 3;
		public var platform:int;

		public var game:Game;
		public var descriptor:Descriptor;
		public var scale:Number;
	//	public var offsetY:Number;
		public var align:String = "right";
		public var direction:String = "rtl";
		public var isLTR:Boolean = false;
		
		public var assets:AssetManager;
		public var sounds:SoundManager;
		
		
		public function AppModel()
		{
			descriptor = new Descriptor(NativeApplication.nativeApplication.applicationDescriptor);
			assets = new AssetManager(2);
			assets.verbose = false;
			
			sounds = new SoundManager();
			
			switch( Capabilities.os.substr(0, 5) )
			{
				case "Mac O": platform = PLATFORM_MAC; break;
				case "Linux": platform = PLATFORM_ANDROID; break;
				case "iPhon": platform = PLATFORM_IOS; break;
			}
		}
		
		
		public static function get instance():AppModel
		{
			if(_instance == null)
				_instance = new AppModel();
			return _instance;
		}
	}
}