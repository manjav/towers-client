package com.gerantech.towercraft.models
{
	import com.gerantech.towercraft.themes.MetalWorksMobileTheme;
	import feathers.controls.StackScreenNavigator;

	public class AppModel
	{
		private static var _instance:AppModel;
		
		public var theme:MetalWorksMobileTheme;
		public var navigator:StackScreenNavigator;
		
		public function AppModel()
		{
		}
		
		
		public static function get instance():AppModel
		{
			if(_instance == null)
				_instance = new AppModel();
			return _instance;
		}
	}
}