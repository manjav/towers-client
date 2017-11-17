package com.gerantech.towercraft
{
	import com.gerantech.towercraft.controls.StackNavigator;
	import com.gerantech.towercraft.controls.screens.*;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.themes.MetalWorksMobileTheme;
	
	import feathers.controls.Drawers;
	import feathers.controls.StackScreenNavigatorItem;
	import feathers.core.IFeathersControl;
	import feathers.motion.Cover;
	import feathers.motion.Reveal;
	
	import starling.events.Event;
	
	public class Main extends Drawers
	{
		public static const DASHBOARD_SCREEN:String = "dashboardScreen";
		public static const BATTLE_SCREEN:String = "battleScreen";
		public static const QUESTS_SCREEN:String = "questsScreen";
		public static const ARENA_SCREEN:String = "arenaScreen";
		public static const SOCIAL_SCREEN:String = "socialScreen";
		public static const SETTINGS_SCREEN:String = "settingsScreen";
		public static const ADMIN_SCREEN:String = "adminScreen";
		public static const SPECTATE_SCREEN:String = "spectateScreen";
		public static const INBOX_SCREEN:String = "inboxScreen";
		public static const ISSUES_SCREEN:String = "issuesScreen";
		public static const PLAYERS_SCREEN:String = "playersScreen";
		
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
			addScreen(QUESTS_SCREEN, 	QuestMapScreen);
			addScreen(BATTLE_SCREEN, 	BattleScreen, false);
			addScreen(SETTINGS_SCREEN, 	SettingsScreen);
			addScreen(ADMIN_SCREEN, 	AdminScreen);
			addScreen(SPECTATE_SCREEN, 	SpectateScreen);
			addScreen(INBOX_SCREEN, 	InboxScreen);
			addScreen(ISSUES_SCREEN, 	IssuesScreen);
			addScreen(PLAYERS_SCREEN, 	PlayersScreen);
			AppModel.instance.navigator.rootScreenID = DASHBOARD_SCREEN;
		}		
		private function addScreen(screenType:String, screenClass:Object, hasTranstion:Boolean = true):void
		{
			var item:StackScreenNavigatorItem = new StackScreenNavigatorItem(screenClass);
			if( hasTranstion )
				item.pushTransition = Cover.createCoverUpTransition();
			item.popTransition = Reveal.createRevealDownTransition();
			item.addPopEvent(Event.COMPLETE);
			AppModel.instance.navigator.addScreen(screenType, item);			
		}
	}
}