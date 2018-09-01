package com.gerantech.towercraft
{
import com.gerantech.towercraft.controls.StackNavigator;
import com.gerantech.towercraft.controls.screens.*;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.themes.MainTheme;
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
public static const OPERATIONS_SCREEN:String = "operationsScreen";
public static const FACTIONS_SCREEN:String = "factionsScreen";
public static const SETTINGS_SCREEN:String = "settingsScreen";
public static const ADMIN_SCREEN:String = "adminScreen";
public static const SPECTATE_SCREEN:String = "spectateScreen";
public static const INBOX_SCREEN:String = "inboxScreen";
public static const ISSUES_SCREEN:String = "issuesScreen";
public static const OFFENDS_SCREEN:String = "offendsScreen";
public static const PLAYERS_SCREEN:String = "playersScreen";
public static const CHALLENGE_SCREEN:String = "challengeScreen";

public function Main(content:IFeathersControl=null)
{
	AppModel.instance.theme = new MainTheme();
	super(content);
}

override protected function initialize():void
{
	//never forget to call super.initialize()
	super.initialize();
	
	AppModel.instance.navigator =  new StackNavigator();
	this.content = AppModel.instance.navigator;

	addScreen(DASHBOARD_SCREEN,	DashboardNewScreen);
	addScreen(FACTIONS_SCREEN,	FactionsScreen, false, false);
	addScreen(OPERATIONS_SCREEN,OperationsScreen, true, false);
	addScreen(BATTLE_SCREEN, 	BattleScreen, false, false);
	addScreen(SETTINGS_SCREEN, 	SettingsScreen);
	addScreen(ADMIN_SCREEN, 	AdminScreen);
	addScreen(SPECTATE_SCREEN, 	SpectateScreen);
	addScreen(INBOX_SCREEN, 	InboxScreen);
	addScreen(ISSUES_SCREEN, 	IssuesScreen);
	addScreen(OFFENDS_SCREEN,	OffendsScreen);
	addScreen(PLAYERS_SCREEN, 	PlayersScreen);
	addScreen(CHALLENGE_SCREEN, ChallengeScreen);
	AppModel.instance.navigator.rootScreenID = DASHBOARD_SCREEN;
}		
private function addScreen(screenType:String, screenClass:Object, hasPushTranstion:Boolean = true, hasPopTranstion:Boolean = true):void
{
	var item:StackScreenNavigatorItem = new StackScreenNavigatorItem(screenClass);
	if( hasPushTranstion )
		item.pushTransition = Cover.createCoverUpTransition();
	if( hasPopTranstion )
		item.popTransition = Reveal.createRevealDownTransition();
	item.addPopEvent(Event.COMPLETE);
	AppModel.instance.navigator.addScreen(screenType, item);			
}
}
}