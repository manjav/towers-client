package com.gerantech.towercraft.controls.buttons
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.overlays.TutorialArrow;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gt.towers.battle.units.Card;
import com.gt.towers.constants.PrefsTypes;
import feathers.layout.AnchorLayout;
import flash.geom.Rectangle;
import starling.display.Stage;
import starling.events.Event;

public class CardButton extends SimpleLayoutButton
{
public var card:Card;
private var iconDisplay:BuildingCard;
private var tutorialArrow:TutorialArrow;

public function CardButton(type:int)
{
	super();
	this.card = player.cards.get(type);
}

public function getIconBounds():Rectangle 
{
	return iconDisplay.getBounds(stage);
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	
	iconDisplay = new BuildingCard(true, true, true, true);
	iconDisplay.width = 240;
	iconDisplay.height = iconDisplay.width * 1.295;
	iconDisplay.x = iconDisplay.pivotX = iconDisplay.width * 0.5;
	iconDisplay.y = iconDisplay.pivotY = iconDisplay.height * 0.5;	
	addChild(iconDisplay);
	
	/*if( type == CardTypes.INITIAL )
		tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorialManager_finishHandler);
}

private function tutorialManager_finishHandler(event:Event):void
{
	if( player.getTutorStep() != PrefsTypes.TUTE_114_SELECT_BUILDING )
		return;
	tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorialManager_finishHandler);
	var tuteData:TutorialData = event.data as TutorialData;
	if( tuteData.name == "deck_start" )
		showTutorArrow(false);*/
}
}
}