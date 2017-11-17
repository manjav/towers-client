package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.buttons.HomeButton;
import com.gerantech.towercraft.controls.buttons.IconButton;
import com.gerantech.towercraft.controls.buttons.NotifierButton;
import com.gerantech.towercraft.controls.overlays.WaitingOverlay;
import com.gerantech.towercraft.controls.popups.NewsPopup;
import com.gerantech.towercraft.controls.popups.SelectNamePopup;
import com.gerantech.towercraft.controls.screens.ArenaScreen;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.managers.InboxService;
import com.gerantech.towercraft.managers.net.LoadingManager;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.models.vo.UserData;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.constants.ResourceType;

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
	ArenaScreen.createFactionsFactory(init);
}
override public function init():void
{
	super.init();
	if( appModel.loadingManager.state < LoadingManager.STATE_LOADED || ArenaScreen.animFactory == null || initializeCompleted )
		return;
	layout = new AnchorLayout();		
	if( appModel.loadingManager.serverData.getBool("inBattle") )
	{
		setTimeout(gotoLiveBattle, 100, null);
		return;
	}
	
	showMainButtons();
	showFooterButtons();
	showTutorial();
	initializeCompleted = true;
}

private function showMainButtons():void
{
	var league:StarlingArmatureDisplay = ArenaScreen.animFactory.buildArmatureDisplay("all");
	league.animation.gotoAndPlayByTime("arena-"+player.get_arena(0)+"-selected", 0, 50);
	leaguesButton = new HomeButton(league, 0.8);
	addButton(leaguesButton, 540, 510, 0.4, goUp);
	function goUp():void { Starling.juggler.tween(leaguesButton, 2, {y:460*appModel.scale, transition:Transitions.EASE_IN_OUT, onComplete:goDown}); }
	function goDown():void { Starling.juggler.tween(leaguesButton, 2, {y:510*appModel.scale, transition:Transitions.EASE_IN_OUT, onComplete:goUp}); }

	battlesButton = new HomeButton(new Image(Assets.getTexture("battle-button", "gui")));
	addButton(battlesButton, 540, 1040, 0.6);
	
	questsButton = new HomeButton(new Image(Assets.getTexture("quest-button", "gui")));
	addButton(questsButton, 540, 1340, 0.8);
}

private function addButton(button:HomeButton, x:int, y:int, delay:Number, callback:Function=null):void
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
	settingButton.width = settingButton.height = 120 * appModel.scale;
	settingButton.addEventListener(Event.TRIGGERED, function():void{appModel.navigator.pushScreen(Main.SETTINGS_SCREEN);});
	settingButton.layoutData = new AnchorLayoutData(NaN, NaN, 20*appModel.scale, 6*appModel.scale);
	addChild(settingButton);
	
	var newsButton:IconButton = new IconButton(Assets.getTexture("button-news", "gui"));
	newsButton.width = newsButton.height = 110 * appModel.scale;
	newsButton.addEventListener(Event.TRIGGERED, function():void{appModel.navigator.addPopup(new NewsPopup())});
	newsButton.layoutData = new AnchorLayoutData(NaN, NaN, 25*appModel.scale, 126*appModel.scale);
	addChild(newsButton);
	
	inboxButton = new NotifierButton(Assets.getTexture("button-inbox", "gui"));
	inboxButton.badgeNumber = InboxService.instance.numUnreads;
	inboxButton.width = inboxButton.height = 120 * appModel.scale;
	inboxButton.addEventListener(Event.TRIGGERED, function():void{appModel.navigator.pushScreen(Main.INBOX_SCREEN)});
	inboxButton.layoutData = new AnchorLayoutData(NaN, NaN, 20*appModel.scale, 246*appModel.scale);
	addChild(inboxButton);
	
	var restoreButton:Button = new Button();
	restoreButton.alpha = 0;
	restoreButton.isLongPressEnabled = true;
	restoreButton.longPressDuration = 3;
	restoreButton.width = restoreButton.height = 120 * appModel.scale;
	restoreButton.addEventListener(FeathersEventType.LONG_PRESS, function():void{appModel.navigator.pushScreen(Main.ADMIN_SCREEN)});
	restoreButton.layoutData = new AnchorLayoutData(NaN, 0, 0);
	addChild(restoreButton);
	
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
	trace("player.inTutorial() : ", player.inTutorial());
	trace("player.nickName : ", player.nickName);

	if( player.get_questIndex() >= 3 && player.nickName == "guest" )
	{
		var confirm:SelectNamePopup = new SelectNamePopup();
		confirm.addEventListener(Event.COMPLETE, confirm_eventsHandler);
		appModel.navigator.addPopup(confirm);
		function confirm_eventsHandler():void {
			confirm.removeEventListener(Event.COMPLETE, confirm_eventsHandler);
			battlesButton.showArrow();
		}
		return;
	}
	
	// show rank table tutorial
	if( !player.inTutorial() && player.prefs.getAsInt(PrefsTypes.TUTE_STEP_101) < PrefsTypes.TUTE_118_VIEW_RANK && player.resources.get(ResourceType.BATTLES_WINS) > 0 )
	{
		var tutorialData:TutorialData = new TutorialData("rank_tutorial");
		tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_rank_0", null, 1000, 1000, 0));
		tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_completeHandler);
		tutorials.show(tutorialData);
		function tutorials_completeHandler(e:Event):void {
			appModel.navigator.toolbar.indicators[ResourceType.POINT].showArrow();
			UserData.instance.prefs.setInt(PrefsTypes.TUTE_STEP_101, PrefsTypes.TUTE_118_VIEW_RANK);
		}
		return;
	}
	
	if( player.inTutorial() || (player.quests.keys().length < 20 && player.quests.keys().length < player.resources.get(ResourceType.BATTLES_COUNT)) )
	{
		var tuteStep:int = player.prefs.getAsInt(PrefsTypes.TUTE_STEP_101);
		if( tuteStep != PrefsTypes.TUTE_111_SELECT_EXCHANGE && tuteStep != PrefsTypes.TUTE_113_SELECT_DECK )
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
			gotoLiveBattle("battle");
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
			appModel.navigator.pushScreen( Main.ARENA_SCREEN );		
			break;
	}
}

private function gotoLiveBattle(waitingData:String):void
{
	var item:StackScreenNavigatorItem = appModel.navigator.getScreen( Main.BATTLE_SCREEN );
	item.properties.requestField = null ;
	item.properties.waitingOverlay = new WaitingOverlay() ;
	item.properties.waitingOverlay.data = waitingData;
	appModel.navigator.pushScreen( Main.BATTLE_SCREEN ) ;
	appModel.navigator.addOverlay(item.properties.waitingOverlay);		
}
}
}