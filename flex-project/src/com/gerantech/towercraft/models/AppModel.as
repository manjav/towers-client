package com.gerantech.towercraft.models
{
	import com.gerantech.towercraft.models.vo.Descriptor;
	import com.gerantech.towercraft.themes.MetalWorksMobileTheme;
	
	import flash.desktop.NativeApplication;
	
	import feathers.controls.StackScreenNavigator;
	import com.gerantech.towercraft.views.BattleFieldView;

	public class AppModel
	{
		private static var _instance:AppModel;
		
		public var theme:MetalWorksMobileTheme;
		public var navigator:StackScreenNavigator;
		public var descriptor:Object;
		public var battleField:BattleFieldView;
		
		public function AppModel()
		{
			descriptor = new Descriptor(NativeApplication.nativeApplication.applicationDescriptor);
		}
		
		
		public static function get instance():AppModel
		{
			if(_instance == null)
				_instance = new AppModel();
			return _instance;
		}
	}
}