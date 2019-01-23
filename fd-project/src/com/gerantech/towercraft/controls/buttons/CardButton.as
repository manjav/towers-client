package com.gerantech.towercraft.controls.buttons
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gt.towers.battle.units.Card;
import com.gt.towers.constants.CardTypes;
import feathers.layout.AnchorLayout;
import flash.geom.Rectangle;

public class CardButton extends SimpleLayoutButton
{
private var card:Card;
public var iconDisplay:BuildingCard;

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
	addChild(iconDisplay);
	iconDisplay.setData(card.type, card.level, 1);
	
	if( card.type == CardTypes.INITIAL && player.inDeckTutorial())
		showTutorArrow(true);
}

public function update():void 
{
	iconDisplay.setData(iconDisplay.type, player.cards.get(iconDisplay.type).level, player.resources.get(iconDisplay.type));
}



/*override public function set isSelected(value:Boolean):void
{
	super.isSelected = value
	if( value && tutorialArrow != null )
		tutorialArrow.removeFromParent(true);
}*/


}
}