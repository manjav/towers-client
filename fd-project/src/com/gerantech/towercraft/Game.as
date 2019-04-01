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

public class Game extends Drawers
{
public static const DASHBOARD_SCREEN:String = "dashboardScreen";
public static const BATTLE_SCREEN:String = "battleScreen";
public static const OPERATIONS_SCREEN:String = "operationsScreen";
public static const FACTIONS_SCREEN:String = "factionsScreen";
public static const ADMIN_SCREEN:String = "adminScreen";
public static const SPECTATE_SCREEN:String = "spectateScreen";
public static const INBOX_SCREEN:String = "inboxScreen";
public static const ISSUES_SCREEN:String = "issuesScreen";
public static const BANNEDS_SCREEN:String = "bannedsScreen";
public static const OFFENDS_SCREEN:String = "offendsScreen";
public static const PLAYERS_SCREEN:String = "playersScreen";
static public const CHALLENGES_SCREEN:String = "challengesScreen";
static public const QUESTS_SCREEN:String = "questsScreen";
static public const SEARCH_CHAT_SCREEN:String = "searchChatScreen";

public function Game(content:IFeathersControl=null)
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
	stage.color = 0x3382E7;


	addScreen(DASHBOARD_SCREEN,	DashboardScreen);
	addScreen(FACTIONS_SCREEN,	FactionsScreen, false, false);
	addScreen(BATTLE_SCREEN, 	BattleScreen, false, false);
	addScreen(ADMIN_SCREEN, 	AdminScreen);
	addScreen(SPECTATE_SCREEN, 	SpectateScreen);
	addScreen(INBOX_SCREEN, 	InboxScreen);
	addScreen(ISSUES_SCREEN, 	IssuesScreen);
	addScreen(BANNEDS_SCREEN,	BanndsScreen);
	addScreen(OFFENDS_SCREEN,	OffendsScreen);
	addScreen(PLAYERS_SCREEN, 	SearchPlayersScreen);
	addScreen(CHALLENGES_SCREEN,ChallengesScreen);
	addScreen(QUESTS_SCREEN,	QuestsScreen);
	addScreen(SEARCH_CHAT_SCREEN,SearchChatScreen);
	AppModel.instance.navigator.rootScreenID = DASHBOARD_SCREEN;
}		
private function addScreen(screenType:String, screenClass:Object, hasPushTranstion:Boolean = false, hasPopTranstion:Boolean = false):void
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