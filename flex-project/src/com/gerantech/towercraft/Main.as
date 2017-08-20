package com.gerantech.towercraft
{
	import com.gerantech.towercraft.controls.StackNavigator;
	import com.gerantech.towercraft.controls.screens.ArenaScreen;
	import com.gerantech.towercraft.controls.screens.BattleScreen;
	import com.gerantech.towercraft.controls.screens.DashboardScreen;
	import com.gerantech.towercraft.controls.screens.QuestsScreen;
	import com.gerantech.towercraft.controls.screens.VillageScreen;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.themes.MetalWorksMobileTheme;
	
	import feathers.controls.Drawers;
	import feathers.controls.StackScreenNavigatorItem;
	import feathers.core.IFeathersControl;
	
	import starling.events.Event;
	
	public class Main extends Drawers
	{
		public static const DASHBOARD_SCREEN:String = "dashboardScreen";
		public static const BATTLE_SCREEN:String = "battleScreen";
		public static const QUESTS_SCREEN:String = "questsScreen";
		public static const ARENA_SCREEN:String = "arenaScreen";
		public static const VILLAGE_SCREEN:String = "villageScreen";
		
		public function Main(content:IFeathersControl=null)
		{
			AppModel.instance.theme = new MetalWorksMobileTheme();
			super(content);
		}
		
		override protected function initialize():void
		{
			//never forget to call super.initialize()
			super.initialize();
			
			AppModel.instance.navigator =  new StackNavigator();
			this.content = AppModel.instance.navigator;

			addScreen(DASHBOARD_SCREEN,	DashboardScreen);
			addScreen(ARENA_SCREEN,		ArenaScreen);
			addScreen(QUESTS_SCREEN, 	QuestsScreen);
			addScreen(BATTLE_SCREEN, 	BattleScreen);
			addScreen(VILLAGE_SCREEN, 	VillageScreen);
			AppModel.instance.navigator.rootScreenID = DASHBOARD_SCREEN;
		}		
		private function addScreen(screenType:String, screenClass:Object):void
		{
			var item:StackScreenNavigatorItem = new StackScreenNavigatorItem(screenClass);
			item.addPopEvent(Event.COMPLETE);
			AppModel.instance.navigator.addScreen(screenType, item);			
		}
	}
}