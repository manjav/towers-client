package com.gerantech.towercraft.views.decorators
{
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.views.PlaceView;

import starling.display.Image;

public class CardDecorator extends BarracksDecorator
{
private var cardDisplay:Image;
private var __cardTexture:String;
public function CardDecorator(placeView:PlaceView)
{
	super(placeView);
}
override public function updateBuilding():void
{
	super.updateBuilding();
	cardDisplyFactory() ;
}

private function cardDisplyFactory():void
{
	if( cardDisplay == null )
	{
		if( place.building.type < 101 )
			return;
		__cardTexture = "cards/"+place.building.type;
		cardDisplay = new Image(Assets.getTexture(__cardTexture));
		cardDisplay.touchable = false;
		cardDisplay.pivotX = cardDisplay.width * 0.5;
		cardDisplay.pivotY = cardDisplay.height * 0.6;
		cardDisplay.x = place.x;
		cardDisplay.y = place.y;	
		fieldView.guiImagesContainer.addChild(cardDisplay);
		return;
	}
	cardDisplay.visible = place.building.type > 101;
	if( place.building.type < 101 || __cardTexture == "cards/"+place.building.type )
		return;
	__cardTexture = "cards/"+place.building.type;
	cardDisplay.texture = Assets.getTexture(__cardTexture);
}

override public function dispose():void
{
	if( cardDisplay )
		cardDisplay.removeFromParent(true);
	super.dispose();
}
}
}