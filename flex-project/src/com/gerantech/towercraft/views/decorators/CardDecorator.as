package com.gerantech.towercraft.views.decorators
{
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.views.PlaceView;

import starling.display.Image;

public class CardDecorator extends BarracksDecorator
{
private var cardDisplay:Image;
public function CardDecorator(placeView:PlaceView)
{
	super(placeView);
}
override public function updateElements(population:int, troopType:int):void
{
	super.updateElements(population, troopType);
	createCardDisply();
}

private function createCardDisply():void
{
	if( cardDisplay != null )
		return;
	
	cardDisplay = new Image(Assets.getTexture("cards/"+place.building.type));
	cardDisplay.touchable = false;
	cardDisplay.pivotX = cardDisplay.width * 0.5;
	cardDisplay.pivotY = cardDisplay.height * 0.6;
	cardDisplay.x = parent.x;
	cardDisplay.y = parent.y;	
	fieldView.guiImagesContainer.addChild(cardDisplay);
}
override public function dispose():void
{
	if( cardDisplay )
		cardDisplay.removeFromParent(true);
	super.dispose();
}
}
}