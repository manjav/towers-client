package com.gerantech.towercraft.controls.headers
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.views.PlaceView;

import feathers.layout.AnchorLayout;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.DisplayObjectContainer;
import starling.display.Quad;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class BattleFooter extends TowersLayout
{
	private var _height:int;
	private var _scaleDistance:int;
	private var padding:int;

	private var cards:Vector.<BuildingCard>;
	private var draggableCard:BuildingCard;
	private var touchId:int;
public function BattleFooter()
{
	super();
	_height = 260 * appModel.scale;
	_scaleDistance = 500 * appModel.scale;
}

override protected function initialize():void
{
	super.initialize();
	
	var hlayout:HorizontalLayout = new HorizontalLayout();
	hlayout.padding = hlayout.gap = 16 * appModel.scale;
	hlayout.verticalAlign = VerticalAlign.JUSTIFY;
	hlayout.horizontalAlign = HorizontalAlign.RIGHT;
	layout = hlayout;
	
	backgroundSkin = new Quad(1,1,0);
	backgroundSkin.alpha = 0.7;
	height = _height;
	
	
	cards = new Vector.<BuildingCard>();
	for ( var i:int = 0; i < player.decks.get(player.selectedDeck).size(); i++ ) 
		createDeckItem(i);
	
	draggableCard = new BuildingCard();
	draggableCard.showLevel = false;
	draggableCard.showSlider = false;
	draggableCard.width = 180 * appModel.scale;
	draggableCard.height = 210 * appModel.scale;
	draggableCard.pivotX = draggableCard.width * 0.5;
	draggableCard.pivotY = draggableCard.height * 0.5;
	draggableCard.includeInLayout = false;
	
	addEventListener(TouchEvent.TOUCH, touchHandler);
}

private function createDeckItem(i:int):void
{
	var card:BuildingCard = new BuildingCard();
	card.showLevel = card.showSlider = false;
	card.width = 180 * appModel.scale;
	card.type = player.decks.get(player.selectedDeck).get(i);
	cards.push(card);
	addChild(card);
}


private function touchHandler(event:TouchEvent):void
{
	var touch:Touch = event.getTouch(this);
	if( touch == null )
		return;
	if( touch.phase == TouchPhase.BEGAN)
	{
		var selectedCard:BuildingCard = touch.target.parent as BuildingCard; 
		if( selectedCard == null )
			return;
		touchId = touch.id;
		draggableCard.x = touch.globalX-x;
		draggableCard.y = touch.globalY-y;
		draggableCard.type = selectedCard.type;
		Starling.juggler.tween(draggableCard, 0.1, {scale:1.3});
		addChild(draggableCard);
	}
	else 
	{
		if( touchId != touch.id )
			return;
		if( touch.phase == TouchPhase.MOVED )
		{

			draggableCard.x = touch.globalX-x;
			draggableCard.y = touch.globalY-y;
			draggableCard.scale = Math.max(0.5, (_scaleDistance+Math.min(touch.globalY-y, 0))/_scaleDistance*1.2);
			var place:PlaceView = appModel.battleFieldView.dropTargets.contain(touch.globalX, touch.globalY) as PlaceView;
			if( place == null )
				return;
			//place.place.building.improvable(draggableCard.type);

			//deckHeader.getCardIndex(touch);
		}
		else if( touch.phase == TouchPhase.ENDED )
		{
			place = appModel.battleFieldView.dropTargets.contain(touch.globalX, touch.globalY) as PlaceView;
			if( place != null && place.place.building.improvable(draggableCard.type) && place.place.building.troopType == player.troopType )
				appModel.battleFieldView.responseSender.improveBuilding(place.place.index, draggableCard.type);
			
			Starling.juggler.tween(draggableCard, 0.1, {scale:0, onComplete:draggableCard.removeFromParent});
		/*var cardIndex:int = deckHeader.getCardIndex(touch);
		if( touchId == -1 && cardIndex > -1 )
		Starling.juggler.tween(draggableCard, 0.2, {x:deckHeader.cardsBounds[cardIndex].x+deckHeader.cardsBounds[cardIndex].width*0.5, y:deckHeader.cardsBounds[cardIndex].y+deckHeader.cardsBounds[cardIndex].height*0.5, onComplete:pushToDeck, onCompleteArgs:[cardIndex] });
		else
		pushToDeck(cardIndex);*/
		}
	}
}
}
}