package com.gerantech.towercraft
{
	import com.gerantech.towercraft.controls.screens.BattleScreen;
	import com.gerantech.towercraft.controls.screens.DashboardScreen;
	import com.gerantech.towercraft.controls.screens.QuestsScreen;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.themes.MetalWorksMobileTheme;
	
	import feathers.controls.Drawers;
	import feathers.controls.StackScreenNavigator;
	import feathers.controls.StackScreenNavigatorItem;
	import feathers.core.IFeathersControl;
	import feathers.motion.Iris;
	
	import starling.events.Event;
	
	public class Main extends Drawers
	{
		public static const DASHBOARD_SCREEN:String = "dashboardScreen";
		public static const BATTLE_SCREEN:String = "battleScreen";
		public static const QUESTS_SCREEN:String = "questsScreen";
		
		public function Main(content:IFeathersControl=null)
		{
			AppModel.instance.theme = new MetalWorksMobileTheme();
			super(content);
		}
		
		override protected function initialize():void
		{
			//never forget to call super.initialize()
			super.initialize();
			
			//EmbeddedAssets.initialize();
			AppModel.instance.navigator =  new StackScreenNavigator();
			this.content = AppModel.instance.navigator;

			var item:StackScreenNavigatorItem = new StackScreenNavigatorItem(DashboardScreen);
		//	mainItem.addPopEvent(Event.COMPLETE);
			AppModel.instance.navigator.addScreen(DASHBOARD_SCREEN, item);
			
			
			item = new StackScreenNavigatorItem(QuestsScreen);
			item.addPopEvent(Event.COMPLETE);
			AppModel.instance.navigator.addScreen(QUESTS_SCREEN, item);
			
			item = new StackScreenNavigatorItem(BattleScreen);
			//item.pushTransition = null;
			//item.popTransition = null;
			item.addPopEvent(Event.COMPLETE);
			AppModel.instance.navigator.addScreen(BATTLE_SCREEN, item);
			
			AppModel.instance.navigator.rootScreenID = DASHBOARD_SCREEN;
			//AppModel.instance.navigator.pushTransition = Iris.createIrisOpenTransition();
			//AppModel.instance.navigator.popTransition = Iris.createIrisCloseTransition();
		}
	}
}