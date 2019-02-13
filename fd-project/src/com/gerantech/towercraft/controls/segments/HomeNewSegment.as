package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.buttons.HomeButton;
import com.gerantech.towercraft.controls.buttons.HomeNewButton;
import com.gerantech.towercraft.controls.buttons.HomeQuestsButton;
import com.gerantech.towercraft.controls.buttons.HomeStarsButton;
import com.gerantech.towercraft.controls.buttons.IconButton;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.groups.HomeBooksLine;
import com.gerantech.towercraft.controls.groups.OfferView;
import com.gerantech.towercraft.controls.groups.Profile;
import com.gerantech.towercraft.controls.popups.SelectNamePopup;
import com.gerantech.towercraft.controls.screens.FactionsScreen;
import com.gerantech.towercraft.controls.texts.CountdownLabel;
import com.gerantech.towercraft.controls.tooltips.BaseTooltip;
import com.gerantech.towercraft.managers.net.LoadingManager;
import com.gerantech.towercraft.managers.oauth.OAuthManager;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.UserData;
import com.gt.towers.battle.fieldes.FieldData;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.socials.Challenge;
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
private var questsButton:HomeQuestsButton;
public function HomeNewSegment() { super(); }
override public function init():void
{
	super.init();
	if( initializeCompleted || appModel.loadingManager.state < LoadingManager.STATE_LOADED )
		return;
	
	var padding:int = 16;
	initializeCompleted = true;
	layout = new AnchorLayout();
	//showOffers();

	var league:StarlingArmatureDisplay = FactionsScreen.factory.buildArmatureDisplay("arena-" + Math.min(8, player.get_arena(0)));
	league.animation.gotoAndPlayByTime("selected", 0, 50);
	var leaguesButton:HomeButton = new HomeButton(league, 0.7);
	league.pivotX = league.pivotY = 0;
	league.touchable = player.getTutorStep() > PrefsTypes.T_047_WIN;
	var leagueY:Number = stageHeight * (player.get_battleswins()<4?0.35:0.45)
	addButton(leaguesButton, "leaguesButton", stageWidth * 0.5, leagueY, 0.4, league.touchable ? goUp : null);
	function goUp()		: void { Starling.juggler.tween(leaguesButton, 2, {delay:0.5, y:leagueY + 0.00, transition:Transitions.EASE_IN_OUT, onComplete:goDown}); }
	function goDown()	: void { Starling.juggler.tween(leaguesButton, 2, {delay:0.5, y:leagueY + 0.02, transition:Transitions.EASE_IN_OUT, onComplete:goUp}); }

	// battle and operations button
	var gridRect:Rectangle = new Rectangle(124, 74, 18, 80);
	var shadowRect:Rectangle = new Rectangle(25, 15, 54, 36);
	var rightBattleButton:HomeNewButton = new HomeNewButton("battle-right", loc("button_battle_right"), 430, 186, gridRect, shadowRect);
	addButton(rightBattleButton, "rightButton", stageWidth * (player.get_arena(0)<2?0.29:0.49) + rightBattleButton.width * 0.5, stageHeight * (player.get_battleswins()<4?0.57:0.66), 0.6);
	
	// bookline
	var bookLine:HomeBooksLine = new HomeBooksLine();
    bookLine.height = padding * 20;
	bookLine.layoutData = new AnchorLayoutData(NaN, 0, padding * 2 , 0);
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
	showTutorial();
	
	if( player.get_battleswins() < 4 )
		return;

	if( player.get_arena(0) >= 2 )
	{
		var leftBattleButton:HomeNewButton = new HomeNewButton("battle-left", loc("button_battle_left"), 420, 186, gridRect, shadowRect);
		addButton(leftBattleButton, "leftButton", stageWidth * 0.46 - leftBattleButton.width * 0.5, stageHeight * 0.66, 0.7);
		
		/*if( player.challenges != null )
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
				leftBattleButton.addChild(countdownDisplay);
			}
		}*/
	}
	
	var profile:Profile  = new Profile();
	profile.name = "profile";
	profile.height = padding * 20;
	profile.layoutData = new AnchorLayoutData(padding * 6, 0, NaN, 0);
	addChild(profile);
	
	if( player.get_arena(0) < 1 )
		return;
		
	questsButton = new HomeQuestsButton();
	questsButton.name = "questsButton";
	questsButton.addEventListener(Event.TRIGGERED, mainButtons_triggeredHandler);
	questsButton.height = padding * 12;
	questsButton.width = stageWidth * 0.45;
	questsButton.layoutData = new AnchorLayoutData(profile.y + profile.height + padding * 4, NaN, NaN, padding * 2);
	addChild(questsButton);
	
	var starsButton:HomeStarsButton = new HomeStarsButton();
	starsButton.name = "starsButton";
	starsButton.addEventListener(Event.TRIGGERED, mainButtons_triggeredHandler);
	starsButton.height = padding * 12;
	starsButton.width = stageWidth * 0.45;
	starsButton.layoutData = new AnchorLayoutData(profile.y + profile.height + padding * 4 , padding * 2);
	addChild(starsButton);
	
	var rankButton:IconButton = new IconButton(Assets.getTexture("home/ranking"), 0.9);
	rankButton.name = "rankButton";
	rankButton.backgroundSkin = new Image(Assets.getTexture("theme/background-glass-skin"));
	rankButton.addEventListener(Event.TRIGGERED, mainButtons_triggeredHandler);
	Image(rankButton.backgroundSkin).scale9Grid = new Rectangle(16, 16, 4, 4);
	rankButton.height = rankButton.width = padding * 8;
	rankButton.layoutData = new AnchorLayoutData(padding * 38, NaN, NaN, padding * 2);
	addChild(rankButton);
	
	if( player.get_arena(0) > 0 && !player.prefs.getAsBool(PrefsTypes.AUTH_41_GOOGLE) )
	{
		googleButton = new IconButton(Assets.getTexture("settings-41"), 0.7);
		googleButton.name = "googleButton";
		googleButton.backgroundSkin = new Image(Assets.getTexture("theme/background-glass-skin"));
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
	
	/*adsButton = new NotifierButton(Assets.getTexture("button-spectate"));
	adsButton.width = adsButton.height = 140;
	adsButton.layoutData = new AnchorLayoutData(120, NaN, NaN, 20);
	if( exchanger.items.get(ExchangeType.C43_ADS).getState(timeManager.now) == ExchangeItem.CHEST_STATE_READY )
		adsButton.badgeLabel = "!";
	adsButton.addEventListener(Event.TRIGGERED, mainButtons_triggeredHandler);
	addChild(adsButton);*/
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

	if( player.get_battleswins() <= 3 && player.getTutorStep() >= PrefsTypes.T_018_CARD_UPGRADED )
	{
		SimpleLayoutButton(getChildByName("rightButton")).showTutorHint();
		return;
	}
	
	if( player.get_battleswins() > 3 && player.nickName == "guest" )
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
	
	if( tutorStep == PrefsTypes.T_152_NAME_SELECTED  )// show quest table tutorial
	{
		/*var tutorialData:TutorialData = new TutorialData("quest_tutorial");
		tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_quest_0", null, 500, 1500, 0));
		tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_completeHandler);
		tutorials.show(tutorialData);
		function tutorials_completeHandler(event:Event):void
		{
			if( event.data.name != "quest_tutorial" )
				return;
			
			UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_161_QUEST_FOCUS); 
			//SimpleLayoutButton(getChildByName("rankButton")).showTutorArrow(true);
			questsButton.showTutorArrow(false);
		}*/
		//HomeNewButton(getChildByName("rightButton")).showTutorArrow(false);
	}	
}

private function mainButtons_triggeredHandler(event:Event):void
{
	var buttonName:String = DisplayObject(event.currentTarget).name;
	switch( buttonName )
	{
		case "leftButton":		appModel.navigator.runBattle(FieldData.TYPE_TOUCHDOWN);					return;
		case "rightButton":		appModel.navigator.runBattle(FieldData.TYPE_HEADQUARTER);				return;
	}
	
	if( player.get_arena(0) <= 0 )
	{
		appModel.navigator.addLog(loc("try_to_league_up"));
		return;
	}
	
	switch( buttonName )
	{
		case "leaguesButton":	appModel.navigator.pushScreen( Main.FACTIONS_SCREEN );					return;
		case "rankButton": 		FactionsScreen.showRanking(appModel.game.player.get_arena(0));			return;
		case "questsButton":	appModel.navigator.pushScreen( Main.QUESTS_SCREEN );					return;
		case "starsButton":		exchangeManager.process(exchanger.items.get(ExchangeType.C104_STARS));	return;
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