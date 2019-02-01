package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.items.CardFeatureItemRenderer;
import com.gerantech.towercraft.controls.screens.DashboardScreen;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.views.effects.MortalParticleSystem;
import com.gt.towers.buildings.Building;
import com.gt.towers.constants.BuildingFeatureType;
import com.gt.towers.constants.BuildingType;
import com.gt.towers.constants.PrefsTypes;
import dragonBones.starling.StarlingArmatureDisplay;
import feathers.controls.List;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;

public class BuildingUpgradeOverlay extends BaseOverlay
{
public var building:Building;
private var initializeStarted:Boolean;
private var shineArmature:StarlingArmatureDisplay;

public function BuildingUpgradeOverlay()
{
	super();
	//BattleOutcomeOverlay.createFactionsFactory(initialize);
}

override protected function initialize():void
{
	if( stage != null )
		addChild(defaultOverlayFactory());
	//if( stage == null || appModel.assets.isLoading || initializeStarted )
		//return;
	super.initialize();
	appModel.navigator.activeScreen.visible = false;
	initializeStarted = true;

	layout = new AnchorLayout();
	closeOnStage = false;

	width = stage.stageWidth;
	height = stage.stageHeight;
	overlay.alpha = 1;
/*	
	if(BattleOutcomeOverlay.dragonBonesData == null)
		return;
	
	var armatureDisplay:StarlingArmatureDisplay = BattleOutcomeOverlay.animFactory.buildArmatureDisplay("levelup");
	armatureDisplay.x = stage.stageWidth/2;
	armatureDisplay.y = stage.stageHeight / 2;
	armatureDisplay.scale = appModel.scale;
	armatureDisplay.animation.gotoAndPlayByFrame("appearin", 1, 1);
	addChild(armatureDisplay);*/
	
	
	var card:BuildingCard = new BuildingCard(true, false, false, false);
	card.pivotY = card.height * 0.5;
	card.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, NaN);
	card.width = 240;
	card.height = card.width * 1.4;
	card.y = (stage.stageHeight - card.height) * 0.5;
	card.scale = 1.6;
	addChild(card);
	card.setData(building.type, building.get_level() - 1);
	
	appModel.sounds.setVolume("main-theme", 0.3);
	setTimeout(levelUp, 500);
	setTimeout(showFeatures, 1800);
	setTimeout(showEnd, 2500);
	function levelUp():void {
		var titleDisplay:RTLLabel = new RTLLabel(loc("building_title_" + building.type), 1, "center", null, false, null, 1.5);
		titleDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0);
		titleDisplay.y = (stage.stageHeight - card.height) / 3;
		addChild(titleDisplay);
		
		card.scale = 2.4;
		card.setData(building.type, building.get_level());
		Starling.juggler.tween(card, 0.3, {scale:1.6, transition:Transitions.EASE_OUT});
		Starling.juggler.tween(card, 0.5, {delay:0.7, y:card.y - 150, transition:Transitions.EASE_IN_OUT});
		
		// shine animation
		shineArmature = OpenBookOverlay.factory.buildArmatureDisplay("shine");
		shineArmature.touchable = false;
		shineArmature.scale = 0.1;
		shineArmature.x = 120;
		shineArmature.y = 170;
		shineArmature.animation.gotoAndPlayByTime("rotate", 0, 10);
		card.addChildAt(shineArmature, 0);
		Starling.juggler.tween(shineArmature, 0.3, {scale:2.5, transition:Transitions.EASE_OUT_BACK});
		
		// explode particles
		var explode:MortalParticleSystem = new MortalParticleSystem("explode", 2);
		explode.x = 120;
		explode.y = 170;
		card.addChildAt(explode, 0);
		
		// scraps particles
		var scraps:MortalParticleSystem = new MortalParticleSystem("scrap", 5);
		scraps.x = stage.stageWidth * 0.5;
		scraps.y = -stage.stageHeight * 0.1;
		addChildAt(scraps, 1);
		
		appModel.sounds.addAndPlay("upgrade");
	}
	function showFeatures():void 
	{
		var featureList:List = new List();
		featureList.width = stage.stageWidth * 0.5;
		featureList.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, featureList.width * 0.7);
		featureList.horizontalScrollPolicy = featureList.verticalScrollPolicy = ScrollPolicy.OFF;
		featureList.itemRendererFactory = function ():IListItemRenderer { return new CardFeatureItemRenderer(building.type); }
		featureList.dataProvider = new ListCollection(BuildingFeatureType.getRelatedTo(building.type)._list);
		addChild(featureList);
	}
	function showEnd():void 
	{
		if( player.getTutorStep() >= PrefsTypes.T_038_CARD_UPGRADED && building.type == BuildingType.B11_BARRACKS && building.get_level() == 2 )
		{
			UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_038_CARD_UPGRADED );
			
			// dispatch tutorial event
			var tutorialData:TutorialData = new TutorialData("deck_end");
			tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_deck_0", null, 500, 1500, 0));
			tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_finishHandler);
			tutorials.show(tutorialData);
		}
		else
		{
			var buttonOverlay:SimpleLayoutButton = new SimpleLayoutButton();
			buttonOverlay.addEventListener(Event.TRIGGERED, buttonOverlay_triggeredHandler);
			buttonOverlay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
			addChild(buttonOverlay);
		}
	}
}

private function tutorials_finishHandler(event:Event):void 
{
	var tutorial:TutorialData = event.data as TutorialData;
	if( tutorial.name != "deck_end" )
		return;
	tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_finishHandler);
	UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_039_RETURN_TO_BATTLE);
	DashboardScreen.TAB_INDEX = 2;
	appModel.navigator.runBattle();
	close();
}


/*
private function showTutorial():void
{
	UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_036_DECK_SHOWN );
	if( player.getTutorStep() != PrefsTypes.T_038_CARD_UPGRADED )
		return;
	
	var tutorialData:TutorialData = new TutorialData("deck_end");
	tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_deck_0", null, 500, 1500, 0));
	tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_finishHandler);
	tutorials.show(tutorialData);
}		

private function tutorials_finishHandler(event:Event):void 
{
	if( player.getTutorStep() != PrefsTypes.T_038_CARD_UPGRADED )
		return;
	UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_039_RETURN_TO_BATTLE );
	DashboardScreen.TAB_INDEX = 2;
	appModel.navigator.runBattle();
}
*/




private function buttonOverlay_triggeredHandler(event:Event):void
{
	close();
}

override public function dispose():void
{
	appModel.navigator.activeScreen.visible = true;
	shineArmature.removeFromParent();
	appModel.sounds.setVolume("main-theme", 1);
	super.dispose();
}
}
}