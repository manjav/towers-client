package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.buttons.HomeButton;
import com.gerantech.towercraft.controls.buttons.IconButton;
import com.gerantech.towercraft.controls.buttons.NotifierButton;
import com.gerantech.towercraft.controls.overlays.BattleStartOverlay;
import com.gerantech.towercraft.controls.overlays.EndBattleOverlay;
import com.gerantech.towercraft.controls.popups.NewsPopup;
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
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;

import flash.utils.setTimeout;

import dragonBones.starling.StarlingArmatureDisplay;

import feathers.controls.Button;
import feathers.controls.ImageLoader;
import feathers.controls.StackScreenNavigatorItem;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class HomeSegment extends Segment
{
private var inboxButton:NotifierButton;
private var questsButton:HomeButton;
private var battlesButton:HomeButton;
private var leaguesButton:HomeButton;

public function HomeSegment()
{
	super();
	FactionsScreen.createFactionsFactory(init);
}
override public function init():void
{
	super.init();
	if( appModel.loadingManager.state < LoadingManager.STATE_LOADED || FactionsScreen.animFactory == null )
		return;
	
	layout = new AnchorLayout();		
	if( appModel.loadingManager.serverData.getBool("inBattle") )
	{
		setTimeout(gotoLiveBattle, 100, -1, false);
		return;
	}
	
	showMainButtons();
	showFooterButtons();
	showTutorial();
	initializeCompleted = true;
	//testOutcome();
}

private function testOutcome():void
{
var rwards:SFSArray = new SFSArray();
for (var i:int = 0; i < 2; i++) 
{
	var sfs:SFSObject = new SFSObject();
	sfs.putInt("key", i==0?2:0);
	sfs.putInt("id", i==0?10001:214);
	sfs.putText("name", i==0?"10001":"214");
	rwards.addSFSObject(sfs);
}
appModel.battleFieldView = new BattleFieldView();
appModel.battleFieldView.battleData = new BattleData(new SFSObject());
appModel.navigator.addOverlay(new EndBattleOverlay(0, rwards, false));
}
override public function focus():void
{
	if( initializeCompleted )
		showTutorial();
}

private function showMainButtons():void
{
	var league:StarlingArmatureDisplay = FactionsScreen.animFactory.buildArmatureDisplay("arena-"+Math.min(8, player.get_arena(0)));
	league.animation.gotoAndPlayByTime("selected", 0, 50);
	leaguesButton = new HomeButton(league, 0.8);
	league.pivotX = league.pivotY = 0
	addButton(leaguesButton, "button_leagues", 540, 510, 0.4, goUp);
	function goUp():void { Starling.juggler.tween(leaguesButton, 2, {y:460*appModel.scale, transition:Transitions.EASE_IN_OUT, onComplete:goDown}); }
	function goDown():void { Starling.juggler.tween(leaguesButton, 2, {y:510*appModel.scale, transition:Transitions.EASE_IN_OUT, onComplete:goUp}); }

	battlesButton = new HomeButton(new Image(Assets.getTexture("battle-button", "gui")));
	addButton(battlesButton, "button_battles", 540, 1000, 0.6);
	
	questsButton = new HomeButton(new Image(Assets.getTexture("quest-button", "gui")));
	addButton(questsButton, "button_quests", 540, 1300, 0.8);
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
	adminButton.longPressDuration = 3;
	adminButton.width = adminButton.height = 120 * appModel.scale;
	adminButton.addEventListener(FeathersEventType.LONG_PRESS, function():void{appModel.navigator.pushScreen(Main.ADMIN_SCREEN)});
	adminButton.layoutData = new AnchorLayoutData(NaN, 0, 0);
	addChild(adminButton);
	
	if( player.inTutorial() )
		return;
	
	var gradient:ImageLoader = new ImageLoader();
	gradient.maintainAspectRatio = false;
	gradient.alpha = 0.5;
	gradient.width = 500 * appModel.scale;
	gradient.height = 120 * appModel.scale;
	gradient.source = Assets.getTexture("theme/grad-ro-right", "gui");
	gradient.layoutData = new AnchorLayoutData(NaN, NaN, 20*appModel.scale, 0);
	addChild(gradient);
	
	var settingButton:IconButton = new IconButton(Assets.getTexture("button-settings", "gui"));
	settingButton.width = settingButton.height = 140 * appModel.scale;
	settingButton.addEventListener(Event.TRIGGERED, function():void{appModel.navigator.pushScreen(Main.SETTINGS_SCREEN);});
	settingButton.layoutData = new AnchorLayoutData(NaN, NaN, 10*appModel.scale, 6*appModel.scale);
	addChild(settingButton);
	
	var newsButton:IconButton = new IconButton(Assets.getTexture("button-news", "gui"));
	newsButton.width = newsButton.height = 140 * appModel.scale;
	newsButton.addEventListener(Event.TRIGGERED, function():void{appModel.navigator.addPopup(new NewsPopup())});
	newsButton.layoutData = new AnchorLayoutData(NaN, NaN, 10*appModel.scale, 126*appModel.scale);
	addChild(newsButton);
	
	inboxButton = new NotifierButton(Assets.getTexture("button-inbox", "gui"));
	inboxButton.badgeNumber = InboxService.instance.numUnreads;
	inboxButton.width = inboxButton.height = 140 * appModel.scale;
	inboxButton.addEventListener(Event.TRIGGERED, function():void{appModel.navigator.pushScreen(Main.INBOX_SCREEN)});
	inboxButton.layoutData = new AnchorLayoutData(NaN, NaN, 10*appModel.scale, 246*appModel.scale);
	addChild(inboxButton);
	
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
	var tutorStep:int = player.prefs.getAsInt(PrefsTypes.TUTE_STEP_101);
	trace("player.inTutorial: ", player.inTutorial(), "tutorStep: ", tutorStep);

	if( player.get_questIndex() >= 3 && player.nickName == "guest" )
	{
		var confirm:SelectNamePopup = new SelectNamePopup();
		//confirm.addEventListener(Event.COMPLETE, confirm_eventsHandler);
		appModel.navigator.addPopup(confirm);
		/*function confirm_eventsHandler():void {
			confirm.removeEventListener(Event.COMPLETE, confirm_eventsHandler);
			battlesButton.showArrow();
		}*/
		return;
	}
	
	// show rank table tutorial
	if( tutorStep > PrefsTypes.TUTE_116_END && tutorStep < PrefsTypes.TUTE_118_VIEW_RANK && player.resources.get(ResourceType.BATTLES_WINS) > 0 )
	{
		var tutorialData:TutorialData = new TutorialData("rank_tutorial");
		tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_rank_0", null, 1000, 1000, 0));
		tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_completeHandler);
		tutorials.show(tutorialData);
		function tutorials_completeHandler(e:Event):void {
			UserData.instance.prefs.setInt(PrefsTypes.TUTE_STEP_101, PrefsTypes.TUTE_118_VIEW_RANK);
			appModel.navigator.toolbar.indicators[ResourceType.POINT].showArrow();
		}
		return;
	}
	
	if( player.inTutorial() || (player.quests.keys().length < 20 && player.quests.keys().length < player.resources.get(ResourceType.BATTLES_COUNT)/2 ) )
	{
		if( tutorStep != PrefsTypes.TUTE_111_SELECT_EXCHANGE && tutorStep != PrefsTypes.TUTE_113_SELECT_DECK )
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
			gotoLiveBattle(-1);
			break;
		case "dragon-cross":
			/*if( !player.villageEnabled() )
			{
				appModel.navigator.addLog(loc("map-dragon-cross-availabledat", [loc("arena_title_1")]));
				punchButton(leaguesButton);
				return;
			}*/
			//appModel.navigator.pushScreen( Main.SOCIAL_SCREEN );		
			break;
		case leaguesButton:
			appModel.navigator.pushScreen( Main.FACTIONS_SCREEN );		
			break;
	}
}

private function gotoLiveBattle(questIndex:int = -1, cancelable:Boolean=true):void
{
	var item:StackScreenNavigatorItem = appModel.navigator.getScreen( Main.BATTLE_SCREEN );
	item.properties.requestField = null ;
	item.properties.waitingOverlay = new BattleStartOverlay(questIndex, cancelable ) ;;
	//item.properties.waitingOverlay.data = waitingData;
	appModel.navigator.pushScreen( Main.BATTLE_SCREEN ) ;
	appModel.navigator.addOverlay(item.properties.waitingOverlay);		
}
}
}