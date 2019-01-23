package com.gerantech.towercraft.controls.buttons
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.overlays.TutorialArrow;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gt.towers.constants.CardTypes;
import com.gt.towers.constants.PrefsTypes;

import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.events.Event;

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
	
	if( type == CardTypes.INITIAL )
		tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorialManager_finishHandler);
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
private function showTutorArrow () : void
{
	if( tutorialArrow != null )
		tutorialArrow.removeFromParent(true);
	
	tutorialArrow = new TutorialArrow(false);
	tutorialArrow.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -height * 0.4);
	addChild(tutorialArrow);
}

override protected function trigger():void
{
	super.trigger();
	if( tutorialArrow != null )
		tutorialArrow.removeFromParent(true);
}
}
}