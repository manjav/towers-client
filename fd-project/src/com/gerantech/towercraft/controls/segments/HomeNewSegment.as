package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.buttons.HomeButton;
import com.gerantech.towercraft.controls.buttons.HomeHeaderButton;
import com.gerantech.towercraft.controls.buttons.HomeNewButton;
import com.gerantech.towercraft.controls.buttons.HomeTasksButton;
import com.gerantech.towercraft.controls.buttons.NotifierButton;
import com.gerantech.towercraft.controls.groups.HomeBooksLine;
import com.gerantech.towercraft.controls.groups.OfferView;
import com.gerantech.towercraft.controls.groups.Profile;
import com.gerantech.towercraft.controls.overlays.EndBattleOverlay;
import com.gerantech.towercraft.controls.popups.SelectNamePopup;
import com.gerantech.towercraft.controls.screens.FactionsScreen;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.managers.net.LoadingManager;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.models.vo.BattleData;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.views.BattleFieldView;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.constants.ResourceType;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;
import dragonBones.starling.StarlingArmatureDisplay;
import feathers.controls.Button;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.Event;

public class HomeNewSegment extends Segment
{
private var inboxButton:NotifierButton;
private var operationButton:HomeNewButton;
private var battlesButton:HomeNewButton;
private var leaguesButton:HomeButton;
private var battleTimeoutId:uint;
private var adsButton:NotifierButton;
private var tasksButton:HomeTasksButton;
private var giftButton:HomeHeaderButton;

public function HomeNewSegment() { super(); }
override public function init():void
{
	super.init();
	if( initializeCompleted || appModel.loadingManager.state < LoadingManager.STATE_LOADED  )
		return;
	
	var padding:int = 16 * appModel.scale;
	initializeCompleted = true;
	layout = new AnchorLayout();
//	showOffers();

	var league:StarlingArmatureDisplay = FactionsScreen.factory.buildArmatureDisplay("arena-" + Math.min(8, player.get_arena(0)));
	league.animation.gotoAndPlayByTime("selected", 0, 50);
	leaguesButton = new HomeButton(league, 0.7);
	league.pivotX = league.pivotY = 0;
	addButton(leaguesButton, width * 0.5, height * 0.50, 0.4, goUp);
	function goUp()		: void { Starling.juggler.tween(leaguesButton, 2, {delay:0.5, y:height * 0.52, transition:Transitions.EASE_IN_OUT, onComplete:goDown}); }
	function goDown()	: void { Starling.juggler.tween(leaguesButton, 2, {delay:0.5, y:height * 0.50, transition:Transitions.EASE_IN_OUT, onComplete:goUp}); }
	
	var profile:Profile  = new Profile();
	profile.height = padding * 20;
	profile.layoutData = new AnchorLayoutData(padding * 6, 0, NaN, 0);
	addChild(profile);

	giftButton = new HomeHeaderButton();
	giftButton.addEventListener(Event.TRIGGERED, mainButtons_triggeredHandler);
	giftButton.height = padding * 12;
	giftButton.width = width * 0.45;
	giftButton.layoutData = new AnchorLayoutData(profile.y + profile.height + padding * 4 , padding * 2);
	addChild(giftButton);

	tasksButton = new HomeTasksButton();
	tasksButton.addEventListener(Event.TRIGGERED, mainButtons_triggeredHandler);
	tasksButton.height = padding * 12;
	tasksButton.width = width * 0.45;
	tasksButton.layoutData = new AnchorLayoutData(profile.y + profile.height + padding * 4, NaN, NaN, padding * 2);
	addChild(tasksButton);

	var gridRect:Rectangle = new Rectangle(124, 74, 18, 80);
	var shadowRect:Rectangle = new Rectangle(25, 15, 54, 36);
	battlesButton = new HomeNewButton("battle", loc("button_battle"), 400 * appModel.scale, 180 * appModel.scale, gridRect, shadowRect);
	addButton(battlesButton, width * 0.48 + battlesButton.width * 0.5, height * 0.73, 0.6);

	var bookLine:HomeBooksLine = new HomeBooksLine();
    bookLine.height = padding * 24;
	bookLine.paddingTop = 40 * appModel.scale;
	bookLine.layoutData = new AnchorLayoutData(NaN, 0, padding, 0);
	
	if( player.admin ) // hidden admin button
	{
		var adminButton:Button = new Button();
		adminButton.alpha = 0;
		adminButton.isLongPressEnabled = true;
		adminButton.longPressDuration = 1;
		adminButton.width = adminButton.height = 120 * appModel.scale;
		adminButton.addEventListener(FeathersEventType.LONG_PRESS, function():void{appModel.navigator.pushScreen(Main.ADMIN_SCREEN)});
		adminButton.layoutData = new AnchorLayoutData(NaN, 0, bookLine.height - bookLine.paddingTop);
		addChild(adminButton);
	}
	
	showTutorial();
	
	if( player.get_battleswins() < 4 )
		return;
	
	addChild(bookLine);
	
	if( player.get_battleswins() < 6 )
		return;

	if( player.get_battleswins() < 7 )
		return;
	if( player.hasQuests )
	{
		operationButton = new HomeNewButton("operation", loc("button_operation"), 360 * appModel.scale, 180 * appModel.scale, gridRect, shadowRect);
		addButton(operationButton, width * 0.45 - operationButton.width * 0.5, height * 0.73, 0.7);
	}
	
	/*adsButton = new NotifierButton(Assets.getTexture("button-spectate", "gui"));
	adsButton.width = adsButton.height = 140 * appModel.scale;
	adsButton.layoutData = new AnchorLayoutData(120 * appModel.scale, NaN, NaN, 20 * appModel.scale);
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

private function addButton(button:DisplayObject, x:int, y:int, delay:Number, callback:Function=null):void
{
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
			UserData.instance.prefs.setInt(PrefsTypes.TUTOR, player.tutorialMode == 0 ? PrefsTypes.T_172_NAME_SELECTED : PrefsTypes.T_139_NAME_SELECTED); 
		}
		return;
	}
	else if( player.get_battleswins() < 6 )
	{
		//battlesButton.showArrow();
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
	
	/*if( player.inTutorial() || (player.quests.keys().length < 20 && player.quests.keys().length < player.resources.get(ResourceType.BATTLES_COUNT)/2 ) )
	{
		if( !player.inShopTutorial() && !player.inDeckTutorial() && player.hasQuests )
			questsButton.showArrow();
	}*/
}


private function mainButtons_triggeredHandler(event:Event ):void
{
	if(	player.inTutorial() && event.currentTarget != operationButton )
	{
		appModel.navigator.addLog(loc("map-button-locked", [loc("map-"+event.data['name'])]));
		return;
	}

	switch(event.currentTarget)
	{
		case operationButton:
			appModel.navigator.pushScreen( Main.QUESTS_SCREEN );		
			break;
		case battlesButton:
			appModel.navigator.runBattle(player.get_arena(0) > 0);
			break;
		case leaguesButton:
			appModel.navigator.pushScreen( Main.FACTIONS_SCREEN );		
			break;
		case giftButton:
			exchangeManager.process(exchanger.items.get(ExchangeType.C101_FREE));
			break;
		case tasksButton:
			appModel.navigator.addLog(loc("button_under_construction", [loc("button_quests")]));
			break;
		case adsButton:
			exchangeManager.process(exchanger.items.get(ExchangeType.C43_ADS));
			break;
	}
}
}
}