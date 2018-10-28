package com.gerantech.towercraft.controls.buttons
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gt.towers.battle.units.Card;
import feathers.layout.AnchorLayout;
import flash.geom.Rectangle;

public class CardButton extends SimpleLayoutButton
{
private var card:Card;
public var iconDisplay:BuildingCard;
//private var tutorialArrow:TutorialArrow;

public function CardButton(type:int)
{
	super();
	card = player.cards.get(type);
}

public function getIconBounds():Rectangle 
{
	return iconDisplay.getBounds(stage);
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
	iconDisplay.setData(card.type, card.level, 1);
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

public function update():void 
{
	iconDisplay.setData(iconDisplay.type, player.cards.get(iconDisplay.type).level, player.resources.get(iconDisplay.type));
}
}
}