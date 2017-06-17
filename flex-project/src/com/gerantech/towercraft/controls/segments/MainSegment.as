package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.events.LoadingEvent;
import com.gerantech.towercraft.managers.net.LoadingManager;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gt.towers.battle.fieldes.PlaceData;
import com.gt.towers.utils.lists.PlaceDataList;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.controls.Button;
import feathers.controls.LayoutGroup;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;

import starling.events.Event;

public class MainSegment extends Segment
{
    public function MainSegment()
    {
        super();
    }
	private var questButton:Button;
	override protected function initialize():void
	{
		super.initialize();
		
		layout = new AnchorLayout();
		
		var battons:LayoutGroup = new LayoutGroup();
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
		battons.addChild(questButton);	
		
		var battleButton:Button = new Button();
		battleButton.label = loc("mainpage_fire_button");
		battleButton.addEventListener(Event.TRIGGERED, battleButton_triggeredHandler);
		battons.addChild(battleButton);
		
		addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionInCompleteHandler);
	}
	

	private function transitionInCompleteHandler():void
	{
		/*var battleOutcomeOverlay:BattleOutcomeOverlay = new BattleOutcomeOverlay(3, false);
		addChild(battleOutcomeOverlay);
		var battleOutcomeOverlay:WaitingOverlay = new WaitingOverlay();
		addChild(battleOutcomeOverlay);
		return;*/
		
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
