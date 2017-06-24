package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.events.LoadingEvent;
import com.gerantech.towercraft.managers.net.LoadingManager;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gt.towers.battle.fieldes.PlaceData;
import com.gt.towers.utils.lists.PlaceDataList;
import com.smartfoxserver.v2.entities.data.SFSObject;

import dragonBones.objects.DragonBonesData;
import dragonBones.starling.StarlingArmatureDisplay;
import dragonBones.starling.StarlingFactory;

import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;

import starling.display.Quad;
import starling.events.Event;

public class MainSegment extends Segment
{
	
	[Embed(source = "../../../../../assets/animations/mainmap/main-map_ske.json", mimeType = "application/octet-stream")]
	public static const skeletonClass: Class;
	[Embed(source = "../../../../../assets/animations/mainmap/main-map_tex.json", mimeType = "application/octet-stream")]
	public static const atlasDataClass: Class;
	[Embed(source = "../../../../../assets/animations/mainmap/main-map_tex.png")]
	public static const atlasImageClass: Class;
	
	private var factory:StarlingFactory;
	private var dragonBonesData:DragonBonesData;
	private var questButton:SimpleLayoutButton;
	
	public function MainSegment()
	{
		super();
		factory = new StarlingFactory();
		dragonBonesData = factory.parseDragonBonesData( JSON.parse(new skeletonClass()) );
		factory.parseTextureAtlasData( JSON.parse(new atlasDataClass()), new atlasImageClass() );
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	}
	protected function addedToStageHandler(event:Event):void
	{
		if(dragonBonesData == null)
			return;
		
		var mapDisplay:StarlingArmatureDisplay = factory.buildArmatureDisplay(dragonBonesData.armatureNames[0]);
		mapDisplay.x = 0;
		mapDisplay.y = 0;
		mapDisplay.scale = appModel.scale * 1.2;
		mapDisplay.animation.gotoAndPlayByTime("idle", 0, -1);
		this.addChildAt(mapDisplay, 0);
	}
		
	override protected function initialize():void
	{
		super.initialize();
		
		layout = new AnchorLayout();
		
		/*var battons:LayoutGroup = new LayoutGroup();
		battons.layoutData = new AnchorLayoutData(0,0,0,0);
		addChild(battons);
		
		var vlayout:VerticalLayout = new VerticalLayout();
		vlayout.horizontalAlign = HorizontalAlign.CENTER;
		vlayout.verticalAlign = VerticalAlign.MIDDLE;
		vlayout.gap = 20;
		battons.layout = vlayout;
		
		questButton = new Button();
		questButton.label = loc("mainpage_quest_button");
		questButton.addEventListener(Event.TRIGGERED, questButton_triggeredHandler);
		battons.addChild(questButton);	*/
		
		/*var battleButton:Button = new Button();
		battleButton.label = loc("mainpage_fire_button");
		battleButton.addEventListener(Event.TRIGGERED, battleButton_triggeredHandler);
		battons.addChild(battleButton);*/
				
		var battleButton:SimpleLayoutButton = new SimpleLayoutButton();
		battleButton.alpha = 0;
		battleButton.width = 600*appModel.scale;
		battleButton.height = 400*appModel.scale;
		battleButton.x = 500*appModel.scale;
		battleButton.y = 1140*appModel.scale;
		battleButton.backgroundSkin = new Quad(1,1,1);
		battleButton.addEventListener(Event.TRIGGERED, battleButton_triggeredHandler);
		addChild(battleButton);	
		
		questButton = new SimpleLayoutButton();
		questButton.alpha = 0;
		questButton.width = questButton.height = 200*appModel.scale;
		questButton.x = 320*appModel.scale;
		questButton.y = 770*appModel.scale;
		questButton.backgroundSkin = new Quad(1,1,1);
		questButton.addEventListener(Event.TRIGGERED, questButton_triggeredHandler);
		addChild(questButton);
		
		addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionInCompleteHandler);
	}

	private function transitionInCompleteHandler():void
	{
		removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionInCompleteHandler);
		showTutorial();
	}		
	
	// show tutorial steps
	private function showTutorial():void
	{
		if(appModel.loadingManager.state < LoadingManager.STATE_LOADED )
		{
			appModel.loadingManager.addEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
			return;
		}
		//trace("main screen", player.get_questIndex());
		if( player.get_questIndex() > 1 )
			return;	
		
		var tutorialData:TutorialData = new TutorialData("");
		tutorialData.tasks.push(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_quest_" + player.get_questIndex() + "_start",  null, 200));
		var pl:PlaceDataList = new PlaceDataList();
		pl.push(new PlaceData(0,(questButton.x+questButton.width/2)/appModel.scale, (questButton.y+questButton.height/2)/appModel.scale, 0, 0, ""));
		tutorialData.tasks.push(new TutorialTask(TutorialTask.TYPE_TOUCH, null, pl, 200));
		tutorials.show(this, tutorialData);
	}
	private function loadingManager_loadedHandler():void
	{
		appModel.loadingManager.removeEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
		showTutorial();
	}
	
	private function battleButton_triggeredHandler(event:Event):void
	{
		var sfsObj:SFSObject = new SFSObject();
		sfsObj.putBool("q", false);
		sfsObj.putInt("i", 0);
		SFSConnection.instance.sendExtensionRequest(SFSCommands.START_BATTLE, sfsObj);
		appModel.navigator.pushScreen( Main.BATTLE_SCREEN );		
	}		
	private function questButton_triggeredHandler():void
	{
		appModel.navigator.pushScreen( Main.QUESTS_SCREEN );		
	}
}
}
