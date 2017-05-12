package com.gerantech.towercraft
{
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Player;
	import com.gerantech.towercraft.screens.BattleScreen;
	import com.gerantech.towercraft.screens.DeckScreen;
	import com.gerantech.towercraft.screens.MainScreen;
	import com.gerantech.towercraft.themes.MetalWorksMobileTheme;
	
	import feathers.controls.Drawers;
	import feathers.controls.StackScreenNavigator;
	import feathers.controls.StackScreenNavigatorItem;
	import feathers.core.IFeathersControl;
	import feathers.motion.Slide;
	
	import starling.events.Event;
	
	public class Main extends Drawers
	{
		public static const MAIN_SCREEN:String = "mainScreen";
		public static const DECK_SCREEN:String = "deckScreen";
		public static const BATTLE_SCREEN:String = "battleScreen";
		
		public function Main(content:IFeathersControl=null)
		{
			Player.instance;
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

			
			var mainItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(MainScreen);
		//	mainItem.addPopEvent(Event.COMPLETE);
			AppModel.instance.navigator.addScreen(MAIN_SCREEN, mainItem);
			
			var deckItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(DeckScreen);
			deckItem.addPopEvent(Event.COMPLETE);
			AppModel.instance.navigator.addScreen(DECK_SCREEN, deckItem);
			
			var battleItem:StackScreenNavigatorItem = new StackScreenNavigatorItem(BattleScreen);
			battleItem.addPopEvent(Event.COMPLETE);
			AppModel.instance.navigator.addScreen(BATTLE_SCREEN, battleItem);
			
			AppModel.instance.navigator.rootScreenID = MAIN_SCREEN;
			AppModel.instance.navigator.pushTransition = Slide.createSlideUpTransition();
			AppModel.instance.navigator.popTransition = Slide.createSlideDownTransition();
		}
	}
}