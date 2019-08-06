package com.gerantech.towercraft.controls.buttons
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.overlays.TutorialArrow;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gt.towers.constants.CardTypes;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import starling.events.Event;
import flash.geom.Rectangle;
public class CardButton extends SimpleLayoutButton
{
public var card:BuildingCard;
private var type:int;
private var tutorialArrow:TutorialArrow;
public function CardButton(type:int)
{
	super();
	this.type = type;
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	
	iconDisplay = new BuildingCard(true, true, false, true);
	iconDisplay.width = 240;
	iconDisplay.height = iconDisplay.width * BuildingCard.VERICAL_SCALE;
	iconDisplay.x = iconDisplay.pivotX = iconDisplay.width * 0.5;
	iconDisplay.y = iconDisplay.pivotY = iconDisplay.height * 0.5;
	addChild(iconDisplay);
	iconDisplay.setData(card.type, card.level, 1);
	addEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);
}

protected function createCompleteHandler(e:Event):void 
{
	removeEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);
	if( card.type == CardTypes.INITIAL && player.inDeckTutorial())
		showTutorHint(0, 100);
}

private function tutorialManager_finishHandler(event:Event):void
{
	if( player.getTutorStep() != PrefsTypes.TUTE_114_SELECT_BUILDING )
		return;
	tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorialManager_finishHandler);
	var tuteData:TutorialData = event.data as TutorialData;
	if( tuteData.name == "deck_start" )
		showTutorArrow();
}
}
}