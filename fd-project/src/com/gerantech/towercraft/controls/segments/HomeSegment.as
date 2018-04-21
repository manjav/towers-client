package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.buttons.HomeButton;
import com.gerantech.towercraft.controls.buttons.NotifierButton;
import com.gerantech.towercraft.controls.groups.HomeBooksLine;
import com.gerantech.towercraft.controls.groups.HomeFooter;
import com.gerantech.towercraft.controls.groups.OfferView;
import com.gerantech.towercraft.controls.overlays.EndBattleOverlay;
import com.gerantech.towercraft.controls.popups.SelectNamePopup;
import com.gerantech.towercraft.controls.screens.FactionsScreen;
import com.gerantech.towercraft.events.GameEvent;
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
	showTutorial();
	initializeCompleted = true;
	
	// hidden admin button
	var adminButton:Button = new Button();
	adminButton.alpha = 0;
	adminButton.isLongPressEnabled = true;
	adminButton.longPressDuration = 1;
	adminButton.width = adminButton.height = 120 * appModel.scale;
	adminButton.addEventListener(FeathersEventType.LONG_PRESS, function():void{if( player.admin )appModel.navigator.pushScreen(Main.ADMIN_SCREEN)});
	adminButton.layoutData = new AnchorLayoutData(NaN, 0, 320 * appModel.scale);
	addChild(adminButton);

	if( player.inTutorial() )
		return;
	
	var bookLine:HomeBooksLine = new HomeBooksLine();
	bookLine.layoutData = new AnchorLayoutData(NaN, 0, 0, 0);
	addChild(bookLine);
	
	var footer:HomeFooter = new HomeFooter();
	footer.layoutData = new AnchorLayoutData(NaN, NaN, bookLine.height, 0);
	addChild(footer);
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
	leaguesButton = new HomeButton(league, 0.6);
	league.pivotX = league.pivotY = 0
	addButton(leaguesButton, "button_leagues", 540, 600, 0.4, goUp);
	function goUp():void { Starling.juggler.tween(leaguesButton, 2, {y:620 * appModel.scale, transition:Transitions.EASE_IN_OUT, onComplete:goDown}); }
	function goDown():void { Starling.juggler.tween(leaguesButton, 2, {y:600 * appModel.scale, transition:Transitions.EASE_IN_OUT, onComplete:goUp}); }

	battlesButton = new HomeButton(new Image(Assets.getTexture("battle-button", "gui")), 0.9);
	addButton(battlesButton, "button_battles", 540, 970, 0.6);
	
	if( player.hasQuests && !player.inTutorial() )
	{
		questsButton = new HomeButton(new Image(Assets.getTexture("quest-button", "gui")), 0.9);
		addButton(questsButton, "button_quests", 540, 1200, 0.8);
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