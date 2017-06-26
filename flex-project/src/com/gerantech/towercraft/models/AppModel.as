package com.gerantech.towercraft.models
{
	import com.gerantech.towercraft.managers.net.LoadingManager;
	import com.gerantech.towercraft.models.vo.Descriptor;
	import com.gerantech.towercraft.themes.MetalWorksMobileTheme;
	import com.gerantech.towercraft.views.BattleFieldView;
	
	import flash.desktop.NativeApplication;
	
	import feathers.controls.StackScreenNavigator;
	
	import starling.utils.AssetManager;
	import com.gt.towers.Game;

	public class AppModel
	{
		private static var _instance:AppModel;
		
		public var theme:MetalWorksMobileTheme;
		public var navigator:StackScreenNavigator;
		public var loadingManager:LoadingManager;
		public var battleFieldView:BattleFieldView;

		public var game:Game;
		public var descriptor:Object;
		public var scale:Number;
		public var offsetY:Number;
		public var align:String = "right";
		public var direction:String = "rtl";
		public var isLTR:Boolean = false;
		public var assetsManager:AssetManager;
		
		public function AppModel()
		{
			descriptor = new Descriptor(NativeApplication.nativeApplication.applicationDescriptor);
			assetsManager = new AssetManager(2);
			assetsManager.verbose = false
		}
		
		
		public static function get instance():AppModel
		{
			if(_instance == null)
				_instance = new AppModel();
			return _instance;
		}
	}
}