package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.buttons.HomeButton;
import com.gerantech.towercraft.controls.buttons.HomeHeaderButton;
import com.gerantech.towercraft.controls.buttons.HomeNewButton;
import com.gerantech.towercraft.controls.buttons.HomeQuestsButton;
import com.gerantech.towercraft.controls.buttons.IconButton;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.groups.HomeBooksLine;
import com.gerantech.towercraft.controls.groups.OfferView;
import com.gerantech.towercraft.controls.groups.Profile;
import com.gerantech.towercraft.controls.overlays.EndBattleOverlay;
import com.gerantech.towercraft.controls.popups.SelectNamePopup;
import com.gerantech.towercraft.controls.screens.FactionsScreen;
import com.gerantech.towercraft.controls.texts.CountdownLabel;
import com.gerantech.towercraft.controls.tooltips.BaseTooltip;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.managers.net.LoadingManager;
import com.gerantech.towercraft.managers.oauth.OAuthManager;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.models.vo.BattleData;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.views.BattleFieldView;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.socials.Challenge;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;
import dragonBones.starling.StarlingArmatureDisplay;
import feathers.controls.Button;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.events.Event;

public class HomeNewSegment extends Segment
{
static private var SOCIAL_AUTH_WARNED:Boolean
private var battleTimeoutId:uint;
private var googleButton:IconButton;
public function HomeNewSegment() { super(); }
override public function init():void
{
	super.init();
	if( initializeCompleted || appModel.loadingManager.state < LoadingManager.STATE_LOADED  )
		return;
	
	var padding:int = 16;
	initializeCompleted = true;
	layout = new AnchorLayout();
//	showOffers();

	var league:StarlingArmatureDisplay = FactionsScreen.factory.buildArmatureDisplay("arena-" + Math.min(8, player.get_arena(0)));
	league.animation.gotoAndPlayByTime("selected", 0, 50);
	var leaguesButton:HomeButton = new HomeButton(league, 0.7);
	league.pivotX = league.pivotY = 0;
	league.touchable = player.getTutorStep() > PrefsTypes.T_047_WIN;
	addButton(leaguesButton, "leaguesButton", stageWidth * 0.5, stageHeight * 0.45, 0.4, league.touchable ? goUp : null);
	function goUp()		: void { Starling.juggler.tween(leaguesButton, 2, {delay:0.5, y:stageHeight * 0.47, transition:Transitions.EASE_IN_OUT, onComplete:goDown}); }
	function goDown()	: void { Starling.juggler.tween(leaguesButton, 2, {delay:0.5, y:stageHeight * 0.45, transition:Transitions.EASE_IN_OUT, onComplete:goUp}); }

	// battle and operations button
	var gridRect:Rectangle = new Rectangle(124, 74, 18, 80);
	var shadowRect:Rectangle = new Rectangle(25, 15, 54, 36);
	var battlesButton:HomeNewButton = new HomeNewButton("battle", loc("button_battle"), 430, 186, gridRect, shadowRect);
	addButton(battlesButton, "battlesButton", stageWidth * 0.49 + battlesButton.width * 0.5, stageHeight * 0.66, 0.6);
	
	if( player.challenges != null )
	{
		var c:int = player.challenges.getStartedChallenge(timeManager.now);
		if( c > -1 )
		{
			var ch:Challenge = player.challenges.get(0);
			var countdownDisplay:CountdownLabel = new CountdownLabel();
			countdownDisplay.time = ch.startAt + ch.duration - timeManager.now;
			countdownDisplay.localString = "challenge_end_at";
			countdownDisplay.height = 100;
			countdownDisplay.layoutData = new AnchorLayoutData(-countdownDisplay.height * 0.5, 30, NaN, 30);
			battlesButton.addChild(countdownDisplay);
		}
	}
	
	if( player.hasOperations )
	{
		var operationButton:HomeNewButton = new HomeNewButton("operation", loc("button_operation"), 420, 186, gridRect, shadowRect);
		addButton(operationButton, "operationButton", stageWidth * 0.46 - operationButton.width * 0.5, stageHeight * 0.66, 0.7);
	}
	
	// bookline
	var bookLine:HomeBooksLine = new HomeBooksLine();
    bookLine.height = padding * 20;
	bookLine.layoutData = new AnchorLayoutData(NaN, 0, padding, 0);
	addChild(bookLine);

	if( player.admin ) // hidden admin button
	{
		var adminButton:Button = new Button();
		adminButton.alpha = 0;
		adminButton.isLongPressEnabled = true;
		adminButton.longPressDuration = 1;
		adminButton.width = adminButton.height = 200;
		adminButton.addEventListener(FeathersEventType.LONG_PRESS, function():void{appModel.navigator.pushScreen(Main.ADMIN_SCREEN)});
		adminButton.layoutData = new AnchorLayoutData(NaN, 0, bookLine.height);
		addChild(adminButton);
	}
	
	var profile:Profile  = new Profile();
	profile.name = "profile";
	profile.height = padding * 20;
	profile.layoutData = new AnchorLayoutData(padding * 6, 0, NaN, 0);
	addChild(profile);
	
	showTutorial();
	
	if( player.get_battleswins() < 4 )
		return;

	var giftButton:HomeHeaderButton = new HomeHeaderButton();
	giftButton.name = "giftButton";
	giftButton.addEventListener(Event.TRIGGERED, mainButtons_triggeredHandler);
	giftButton.height = padding * 12;
	giftButton.width = stageWidth * 0.45;
	giftButton.layoutData = new AnchorLayoutData(profile.y + profile.height + padding * 4 , padding * 2);
	addChild(giftButton);

	var questsButton:HomeQuestsButton = new HomeQuestsButton();
	questsButton.name = "questsButton";
	questsButton.addEventListener(Event.TRIGGERED, mainButtons_triggeredHandler);
	questsButton.height = padding * 12;
	questsButton.width = stageWidth * 0.45;
	questsButton.layoutData = new AnchorLayoutData(profile.y + profile.height + padding * 4, NaN, NaN, padding * 2);
	addChild(questsButton);
	
	var rankButton:IconButton = new IconButton(Assets.getTexture("home/ranking", "gui"), 0.9);
	rankButton.name = "rankButton";
	rankButton.backgroundSkin = new Image(Assets.getTexture("theme/background-glass-skin", "gui"));
	rankButton.addEventListener(Event.TRIGGERED, mainButtons_triggeredHandler);
	Image(rankButton.backgroundSkin).scale9Grid = new Rectangle(16, 16, 4, 4);
	rankButton.height = rankButton.width = padding * 8;
	rankButton.layoutData = new AnchorLayoutData(padding * 38, NaN, NaN, padding * 2);
	addChild(rankButton);
	
	if( player.get_arena(0) > 0 && !player.prefs.getAsBool(PrefsTypes.AUTH_41_GOOGLE) )
	{
		googleButton = new IconButton(Assets.getTexture("settings-41", "gui"), 0.7);
		googleButton.name = "googleButton";
		googleButton.backgroundSkin = new Image(Assets.getTexture("theme/background-glass-skin", "gui"));
		googleButton.addEventListener(Event.TRIGGERED, mainButtons_triggeredHandler);
		Image(googleButton.backgroundSkin).scale9Grid = new Rectangle(16, 16, 4, 4);
		googleButton.height = googleButton.width = padding * 8;
		googleButton.layoutData = new AnchorLayoutData(padding * 38, padding * 2);
		addChild(googleButton);
		
		if( !SOCIAL_AUTH_WARNED )
		{
			setTimeout(appModel.navigator.addChild, 1000, new BaseTooltip(loc("socials_signin_warn"), new Rectangle(stageWidth - padding * 8, padding * 44, 2, 2)));
			SOCIAL_AUTH_WARNED = true;
		}
	}
	
	/*adsButton = new NotifierButton(Assets.getTexture("button-spectate", "gui"));
	adsButton.width = adsButton.height = 140;
	adsButton.layoutData = new AnchorLayoutData(120, NaN, NaN, 20);
	if( exchanger.items.get(ExchangeType.C43_ADS).getState(timeManager.now) == ExchangeItem.CHEST_STATE_READY )
		adsButton.badgeLabel = "!";
	adsButton.addEventListener(Event.TRIGGERED, mainButtons_triggeredHandler);
	addChild(adsButton);*/
	//dfsdf();
}

private function dfsdf():void
{
	var rwards:SFSArray = new SFSArray();
	for (var i:int = 0; i < 2; i++) 
	{
		var sfs:SFSObject = new SFSObject();
		sfs.putInt("score", i==0?2:0);
		sfs.putInt("id", i == 0?10383:214);
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
	offers.width = 780;
	offers.height = 160;
	offers.y = 50;
	addChild(offers);
}

private function addButton(button:DisplayObject, name:String, x:int, y:int, delay:Number, callback:Function=null):void
{
	button.name = name;
	button.x = x;
	button.y = y;
	button.scale = 0.5;
	button.alpha = 0;
	button.addEventListener(Event.TRIGGERED, mainButtons_triggeredHandler);
	Starling.juggler.tween(button, 0.5, {delay:delay, scale:1, alpha:1, transition:Transitions.EASE_OUT_BACK, onComplete:callback});
	addChild(button);
}	

// show tutorial steps
private function showTutorial():void
{
	var tutorStep:int = player.getTutorStep();
	trace("player.inTutorial: ", player.inTutorial(), "tutorStep: ", tutorStep);

	if( player.get_battleswins() > 4 && player.nickName == "guest" )
	{
		var confirm:SelectNamePopup = new SelectNamePopup();
		confirm.addEventListener(Event.COMPLETE, confirm_eventsHandler);
		appModel.navigator.addPopup(confirm);
		function confirm_eventsHandler():void {
			confirm.removeEventListener(Event.COMPLETE, confirm_eventsHandler);
			UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_152_NAME_SELECTED);
			Profile(getChildByName("profile")).updateName();
			showTutorial();
		}
		return;
	}
	
	if( tutorStep == PrefsTypes.T_152_NAME_SELECTED  )// show rank table tutorial
	{
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_161_RANK_FOCUS); 
		var tutorialData:TutorialData = new TutorialData("rank_tutorial");
		tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_rank_0", null, 500, 1500, 0));
		tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_completeHandler);
		tutorials.show(tutorialData);
		function tutorials_completeHandler(event:Event):void
		{
			if( event.data.name != "rank_tutorial" )
				return;
			UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_162_RANK_SHOWN);
			SimpleLayoutButton(getChildByName("rankButton")).showTutorArrow(true);
		}
		return;
	}
	
	if( player.get_battleswins() > 2 && player.get_arena(0) <= 0 )
	{
		SimpleLayoutButton(getChildByName("battlesButton")).showTutorArrow(false);
		return;
	}	
}

private function mainButtons_triggeredHandler(event:Event):void
{
	var buttonName:String = DisplayObject(event.currentTarget).name;
	
	switch( buttonName )
	{
		case "leaguesButton":	appModel.navigator.pushScreen( Main.FACTIONS_SCREEN );				return;
		case "battlesButton":	appModel.navigator.runBattle(player.get_arena(0) > 0);				return;
		case "rankButton": 		FactionsScreen.showRanking(appModel.game.player.get_arena(0));		return;
	}
	
	if( player.get_arena(0) <= 0 )
	{
		appModel.navigator.addLog(loc("try_to_league_up"));
		return;
	}
	
	switch( buttonName )
	{
		case "questsButton":	appModel.navigator.pushScreen( Main.QUESTS_SCREEN );					return;
		case "operationButton":	appModel.navigator.pushScreen( Main.OPERATIONS_SCREEN );				return;
		case "giftButton":		exchangeManager.process(exchanger.items.get(ExchangeType.C101_FREE));	return;
		case "adsButton":		exchangeManager.process(exchanger.items.get(ExchangeType.C43_ADS)); 	return;
		case "googleButton":	socialSignin();														 	return;
	}
}

private function socialSignin():void 
{
	OAuthManager.instance.addEventListener(OAuthManager.SINGIN, socialManager_signinHandler);
	OAuthManager.instance.signin();
}

private function socialManager_signinHandler(e:Event):void 
{
	OAuthManager.instance.removeEventListener(OAuthManager.SINGIN, socialManager_signinHandler);
	googleButton.removeFromParent();
}
}
}