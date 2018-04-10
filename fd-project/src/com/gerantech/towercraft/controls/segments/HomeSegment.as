package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.buttons.HomeButton;
import com.gerantech.towercraft.controls.buttons.IconButton;
import com.gerantech.towercraft.controls.buttons.NotifierButton;
import com.gerantech.towercraft.controls.groups.OfferView;
import com.gerantech.towercraft.controls.overlays.EndBattleOverlay;
import com.gerantech.towercraft.controls.popups.SelectNamePopup;
import com.gerantech.towercraft.controls.screens.FactionsScreen;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.managers.InboxService;
import com.gerantech.towercraft.managers.net.LoadingManager;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.models.vo.BattleData;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.views.BattleFieldView;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.constants.ResourceType;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;
import dragonBones.starling.StarlingArmatureDisplay;
import feathers.controls.Button;
import feathers.controls.ImageLoader;
import feathers.controls.StackScreenNavigatorItem;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;
import starling.utils.Color;

public class HomeSegment extends Segment
{
private var inboxButton:NotifierButton;
private var questsButton:HomeButton;
private var battlesButton:HomeButton;
private var leaguesButton:HomeButton;
private var battleTimeoutId:uint;

public function HomeSegment()
{
	super();
}
override public function init():void
{
	super.init();
	if( initializeCompleted || appModel.loadingManager.state < LoadingManager.STATE_LOADED  )
		return;
	
	layout = new AnchorLayout();		
	showOffers();
	showMainButtons();
	showFooterButtons();
	showTutorial();
	initializeCompleted = true;
	//dfsdf();
}


private function dfsdf():void
{
	var rwards:SFSArray = new SFSArray();
	for (var i:int = 0; i < 2; i++) 
	{
		var sfs:SFSObject = new SFSObject();
		sfs.putInt("score", i==0?2:0);
		sfs.putInt("id", i==0?10383:214);
		sfs.putText("name", i == 0?"10383":"214");
		sfs.putInt("1001", 12);
		sfs.putInt("1004", 2);
		rwards.addSFSObject(sfs);
	}
	appModel.battleFieldView = new BattleFieldView();
	var sfs2:ISFSObject = new SFSObject();
	sfs2.putText("mapName", "battle_3");
	sfs2.putBool("hasExtraTime", false);
	appModel.battleFieldView.battleData = new BattleData(sfs2);
	appModel.navigator.addOverlay(new EndBattleOverlay(0, rwards, false));
}
override public function focus():void
{
	if( initializeCompleted )
		showTutorial();
}

private function showOffers():void 
{
	var offers:OfferView = new OfferView();
	offers.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:0, NaN, appModel.isLTR?0:NaN);
	offers.width = 780 * appModel.scale;
	offers.height = 160 * appModel.scale;
	offers.y = 50 * appModel.scale;
	addChild(offers);

}
private function showMainButtons():void
{
	var league:StarlingArmatureDisplay = FactionsScreen.animFactory.buildArmatureDisplay("arena-"+Math.min(8, player.get_arena(0)));
	league.animation.gotoAndPlayByTime("selected", 0, 50);
	leaguesButton = new HomeButton(league, 0.8);
	league.pivotX = league.pivotY = 0
	addButton(leaguesButton, "button_leagues", 540, 650, 0.4, goUp);
	function goUp():void { Starling.juggler.tween(leaguesButton, 2, {y:610 * appModel.scale, transition:Transitions.EASE_IN_OUT, onComplete:goDown}); }
	function goDown():void { Starling.juggler.tween(leaguesButton, 2, {y:650 * appModel.scale, transition:Transitions.EASE_IN_OUT, onComplete:goUp}); }

	battlesButton = new HomeButton(new Image(Assets.getTexture("battle-button", "gui")));
	addButton(battlesButton, "button_battles", 540, 1140, 0.6);
	
	if( player.hasQuests )
	{
		questsButton = new HomeButton(new Image(Assets.getTexture("quest-button", "gui")));
		addButton(questsButton, "button_quests", 540, 1400, 0.8);
	}
}

private function addButton(button:HomeButton, name:String, x:int, y:int, delay:Number, callback:Function=null):void
{
	button.x = x * appModel.scale;
	button.y = y * appModel.scale;
	button.scale = 0.5;
	button.alpha = 0;
	button.addEventListener(Event.TRIGGERED, mainButtons_triggeredHandler);
	Starling.juggler.tween(button, 0.5, {delay:delay, scale:1, alpha:1, transition:Transitions.EASE_OUT_BACK, onComplete:callback});
	addChild(button);
}	

private function showFooterButtons():void
{
	var adminButton:Button = new Button();
	adminButton.alpha = 0;
	adminButton.isLongPressEnabled = true;
	adminButton.longPressDuration = 1;
	adminButton.width = adminButton.height = 120 * appModel.scale;
	adminButton.addEventListener(FeathersEventType.LONG_PRESS, function():void{if( player.admin )appModel.navigator.pushScreen(Main.ADMIN_SCREEN)});
	adminButton.layoutData = new AnchorLayoutData(NaN, 0, 0);
	addChild(adminButton);
	
	if( player.inTutorial() )
		return;
	
	var gradient:ImageLoader = new ImageLoader();
	gradient.scale9Grid = new Rectangle(1,1,7,7);
    gradient.color = Color.BLACK;
    gradient.alpha = 0.6;
    gradient.width = 600 * appModel.scale;
    gradient.height = 120 * appModel.scale;
    gradient.source = Assets.getTexture("theme/gradeint-left", "gui");
	gradient.layoutData = new AnchorLayoutData(NaN, NaN, 20*appModel.scale, 0);
	addChild(gradient);
	
	var settingButton:IconButton = new IconButton(Assets.getTexture("button-settings", "gui"));
	settingButton.width = settingButton.height = 140 * appModel.scale;
	settingButton.addEventListener(Event.TRIGGERED, function():void{appModel.navigator.pushScreen(Main.SETTINGS_SCREEN);});
	settingButton.layoutData = new AnchorLayoutData(NaN, NaN, 10*appModel.scale, 6*appModel.scale);
	addChild(settingButton);
	
	var newsButton:IconButton = new IconButton(Assets.getTexture("button-telegram", "gui"));
	newsButton.width = newsButton.height = 140 * appModel.scale;
	newsButton.addEventListener(Event.TRIGGERED, function():void{navigateToURL(new URLRequest(loc("setting_value_311")))});
	newsButton.layoutData = new AnchorLayoutData(NaN, NaN, 10*appModel.scale, 126*appModel.scale);
	addChild(newsButton);
	
	inboxButton = new NotifierButton(Assets.getTexture("button-inbox", "gui"));
	inboxButton.badgeNumber = InboxService.instance.numUnreads;
	inboxButton.width = inboxButton.height = 140 * appModel.scale;
	inboxButton.addEventListener(Event.TRIGGERED, function():void{appModel.navigator.pushScreen(Main.INBOX_SCREEN)});
	inboxButton.layoutData = new AnchorLayoutData(NaN, NaN, 10*appModel.scale, 246*appModel.scale);
	addChild(inboxButton);
	
	var tvButton:IconButton = new IconButton(Assets.getTexture("button-spectate", "gui"));
	tvButton.width = tvButton.height = 140 * appModel.scale;
	tvButton.addEventListener(Event.TRIGGERED, function():void{var item:StackScreenNavigatorItem = appModel.navigator.getScreen( Main.SPECTATE_SCREEN );item.properties.cmd = "battles";appModel.navigator.pushScreen( Main.SPECTATE_SCREEN );}) ;
	tvButton.layoutData = new AnchorLayoutData(NaN, NaN, 10*appModel.scale, 366*appModel.scale);
	addChild(tvButton);
	
	InboxService.instance.request();
	InboxService.instance.addEventListener(Event.UPDATE, inboxService_updateHandler);
}

private function inboxService_updateHandler():void
{
	inboxButton.badgeNumber = InboxService.instance.numUnreads;
}

// show tutorial steps
private function showTutorial():void
{
	var tutorStep:int = player.getTutorStep();
	trace("player.inTutorial: ", player.inTutorial(), "tutorStep: ", tutorStep);

	if( !player.inTutorial() && player.nickName == "guest" )
	{
		var confirm:SelectNamePopup = new SelectNamePopup();
		confirm.addEventListener(Event.COMPLETE, confirm_eventsHandler);
		appModel.navigator.addPopup(confirm);
		function confirm_eventsHandler():void {
			confirm.removeEventListener(Event.COMPLETE, confirm_eventsHandler);
			UserData.instance.prefs.setInt(PrefsTypes.TUTOR, player.tutorialMode == 0 ? PrefsTypes.T_172_NAME_SELECTED : PrefsTypes.T_139_NAME_SELECTED); 
			battlesButton.showArrow();
		}
		return;
	}
	
	// show rank table tutorial
	if( tutorStep == PrefsTypes.T_172_NAME_SELECTED && player.resources.get(ResourceType.BATTLES_WINS) > 0 )
	{
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_181_RANK_FOCUS); 
		var tutorialData:TutorialData = new TutorialData("rank_tutorial");
		tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_rank_0", null, 500, 1500, 0));
		tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_completeHandler);
		tutorials.show(tutorialData);
		function tutorials_completeHandler(event:Event):void {
			
			if( event.data.name != "rank_tutorial" )
				return;
			UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_182_RANK_SHOWN);
			appModel.navigator.toolbar.indicators[ResourceType.POINT].showArrow();
		}
		return;
	}
	
	if( player.inTutorial() || (player.quests.keys().length < 20 && player.quests.keys().length < player.resources.get(ResourceType.BATTLES_COUNT)/2 ) )
	{
		if( !player.inShopTutorial() && !player.inDeckTutorial() && player.hasQuests )
			questsButton.showArrow();
	}
}


private function mainButtons_triggeredHandler(event:Event ):void
{
	if(	player.inTutorial() && event.currentTarget != questsButton )
	{
		appModel.navigator.addLog(loc("map-button-locked", [loc("map-"+event.data['name'])]));
		return;
	}

	switch(event.currentTarget)
	{
		case questsButton:
			appModel.navigator.pushScreen( Main.QUESTS_SCREEN );		
			break;
		case battlesButton:
			appModel.navigator.runBattle(player.get_arena(0) > 0);
			break;
		case leaguesButton:
			appModel.navigator.pushScreen( Main.FACTIONS_SCREEN );		
			break;
	}
}
}
}