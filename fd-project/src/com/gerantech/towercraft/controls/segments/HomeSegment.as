package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.Game;
import com.gerantech.towercraft.controls.buttons.HomeButton;
import com.gerantech.towercraft.controls.buttons.BattleButton;
import com.gerantech.towercraft.controls.buttons.HomeQuestsButton;
import com.gerantech.towercraft.controls.buttons.HomeStarsButton;
import com.gerantech.towercraft.controls.buttons.IconButton;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.groups.HomeBooksLine;
import com.gerantech.towercraft.controls.groups.OfferView;
import com.gerantech.towercraft.controls.groups.Profile;
import com.gerantech.towercraft.controls.items.challenges.ChallengeIndexItemRenderer;
import com.gerantech.towercraft.controls.popups.RankingPopup;
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
import feathers.controls.ImageLoader;
import feathers.controls.List;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;
import flash.geom.Rectangle;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.events.Event;

public class HomeSegment extends Segment
{
static private var SOCIAL_AUTH_WARNED:Boolean
private var battleTimeoutId:uint;
private var googleButton:IconButton;
private var questsButton:HomeQuestsButton;
public function HomeSegment() { super(); }
override public function init():void
{
	super.init();
	if( initializeCompleted || appModel.loadingManager.state < LoadingManager.STATE_LOADED )
		return;
	var padding:int = 32;
	initializeCompleted = true;
	layout = new AnchorLayout();
	
	ChallengeIndexItemRenderer.IN_HOME = true;
	ChallengeIndexItemRenderer.ARENA = player.get_arena(0);
	var listLayout:VerticalLayout = new VerticalLayout();
	listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	listLayout.padding = 50;
	var eventsButton:List = new List();
	eventsButton.layout = listLayout;
	eventsButton.horizontalScrollPolicy = eventsButton.verticalScrollPolicy = ScrollPolicy.OFF;
	eventsButton.itemRendererFactory = function () : IListItemRenderer { return new ChallengeIndexItemRenderer(); };
	eventsButton.dataProvider = new ListCollection([player.getSelectedChallenge()]);
	eventsButton.layoutData = new AnchorLayoutData(stageHeight * 0.33, 100, NaN, 100);
	eventsButton.height = 500;
	addButton(eventsButton, "eventsButton");
	
	var league:StarlingArmatureDisplay = FactionsScreen.factory.buildArmatureDisplay("arena-" + Math.min(8, player.get_arena(0)));
	league.scale = 0.3;
	league.animation.gotoAndPlayByTime("selected", 0, 50);
	var leaguesButton:HomeButton = new HomeButton(league, 0.7);
	league.pivotX = league.pivotY = 0;
	league.touchable = player.getTutorStep() > PrefsTypes.T_047_WIN;
	addButton(leaguesButton, "leaguesButton", 100, 500, 0.5, 0.4);
	
	// battle button
	var battleButton:BattleButton = new BattleButton("button-battle", loc("button_battle"), 420, 260, new Rectangle(75, 75, 1, 35), new Rectangle(0, 0, 0, 30));
	battleButton.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, stageHeight * 0.15);//stageHeight * (player.get_battleswins() < 4?0.50:0.60), 0.6);
	addButton(battleButton, "battleButton");
	
	// bookline
	var bookLine:HomeBooksLine = new HomeBooksLine();
	bookLine.layoutData = new AnchorLayoutData(NaN, 0, padding, 0);
    bookLine.height = 320;
	addChild(bookLine);

	if( player.admin ) // hidden admin button
	{
		var adminButton:Button = new Button();
		adminButton.alpha = 0;
		adminButton.isLongPressEnabled = true;
		adminButton.longPressDuration = 1;
		adminButton.width = adminButton.height = 200;
		adminButton.addEventListener(FeathersEventType.LONG_PRESS, function():void{appModel.navigator.pushScreen(Game.ADMIN_SCREEN)});
		adminButton.layoutData = new AnchorLayoutData(NaN, 0, bookLine.height);
		addChild(adminButton);
	}
	showTutorial();
	
	if( player.get_battleswins() < 4 )
		return;

	if( player.get_arena(0) >= 2 )
	{
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
	profile.layoutData = new AnchorLayoutData(110, 32, NaN, 32);
	profile.name = "profile";
	addChild(profile);
	
	if( player.get_arena(0) < 1 )
		return;
	
	var starsButton:HomeStarsButton = new HomeStarsButton();
	starsButton.layoutData = new AnchorLayoutData(270, padding);
	starsButton.height = 140;
	starsButton.width = 410;
	addButton(starsButton, "starsButton");
	
	questsButton = new HomeQuestsButton();
	questsButton.layoutData = new AnchorLayoutData(NaN, NaN, NaN, padding, NaN, stageHeight * 0.15);
	questsButton.width = questsButton.height = 140;
	addButton(questsButton, "questsButton");
	
	var rankButton:IconButton = new IconButton(Assets.getTexture("home/ranking"), 0.6, Assets.getTexture("home/button-bg-0"), new Rectangle(22, 38, 4, 4));
	rankButton.layoutData = new AnchorLayoutData(NaN, padding, NaN, NaN, NaN, stageHeight * 0.15);
	rankButton.width = rankButton.height = 140;
	addButton(rankButton, "rankButton");
	
	if( player.get_arena(0) > 0 && !player.prefs.getAsBool(PrefsTypes.AUTH_41_GOOGLE) )
	{
		googleButton = new IconButton(Assets.getTexture("settings/41"), 0.6, Assets.getTexture("home/button-bg-0"), new Rectangle(22, 38, 4, 4));
		googleButton.layoutData = new AnchorLayoutData(270, padding + starsButton.width);
		googleButton.width = googleButton.height = 140;
		addButton(googleButton, "googleButton");
		
		if( !SOCIAL_AUTH_WARNED )
		{
			setTimeout(warnAuthentication, 1000);
			function warnAuthentication () : void {
				appModel.navigator.addChild(new BaseTooltip(loc("socials_signin_warn"), googleButton.getBounds(appModel.navigator)));
			}
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

private function addButton(button:DisplayObject, name:String, x:int=0, y:int=0, delay:Number=0, scale:Number = 1):void
{
	//button.x = x;
	//button.y = y;
	//button.scale = scale * 0.5;
	//button.alpha = 0;
	//Starling.juggler.tween(button, 0.5, {delay:delay, scale:scale, alpha:1, transition:Transitions.EASE_OUT_BACK});
	button.addEventListener(Event.TRIGGERED, mainButtons_triggeredHandler);
	button.name = name;
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
			Profile(getChildByName("profile")).dispatchEventWith("nameUpdate");
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
		case "eventsButton":	appModel.navigator.pushScreen( Game.CHALLENGES_SCREEN );				return;
		case "leftButton":		appModel.navigator.runBattle(FieldData.TYPE_TOUCHDOWN);					return;
		case "battleButton":	appModel.navigator.runBattle(FieldData.TYPE_HEADQUARTER);				return;
	}
	
	if( player.get_arena(0) <= 0 )
	{
		appModel.navigator.addLog(loc("try_to_league_up"));
		return;
	}
	
	switch( buttonName )
	{
		case "leaguesButton":	appModel.navigator.pushScreen( Game.FACTIONS_SCREEN );					return;
		case "questsButton":	appModel.navigator.pushScreen( Game.QUESTS_SCREEN );					return;
		case "rankButton": 		appModel.navigator.addPopup( new RankingPopup() );						return;
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