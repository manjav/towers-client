package com.gerantech.towercraft.controls.headers
{
import com.gerantech.towercraft.controls.BattleDeckCard;
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.views.PlaceView;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSArray;

import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import starling.core.Starling;
import starling.display.Quad;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import com.gt.towers.buildings.Building;

public class BattleFooter extends TowersLayout
{
private var _height:int;
private var _scaleDistance:int;
private var padding:int;

private var cards:Vector.<BattleDeckCard>;
private var draggableCard:BuildingCard;
private var touchId:int;

public function BattleFooter()
{
	super();
	_height = 220 * appModel.scale;
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
	
	cards = new Vector.<BattleDeckCard>();
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
	SFSConnection.instance.addEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, sfsConnection_roomVariablesUpdateHandler);
}

protected function sfsConnection_roomVariablesUpdateHandler(event:SFSEvent):void
{
	if( !appModel.battleFieldView.battleData.room.containsVariable("decks") )
		return;
	var decks:SFSArray = appModel.battleFieldView.battleData.room.getVariable("decks").getValue() as SFSArray;
	for( var i:int=0; i<decks.size(); i++)
	{
		var t:Array = decks.getText(i).split(",");
		appModel.battleFieldView.battleData.battleField.deckBuildings.get(t[0]).building._population = t[1];
	}
	
	for( i=0; i<cards.length; i++)
		cards[i].updateData();
	
}

private function createDeckItem(i:int):void
{
	var card:BattleDeckCard = new BattleDeckCard(appModel.battleFieldView.battleData.battleField.deckBuildings.get( (player.troopType==0?0:4) + i).building, (player.troopType==0?0:4) + i );
	card.width = 150 * appModel.scale;
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
		if( selectedCard == null || !selectedCard.touchable )
		{
			touchId = -1;			
			return;
		}
		//trace(selectedCard.parent, selectedCard.parent.touchable)
		touchId = touch.id;
		draggableCard.x = touch.globalX-x;
		draggableCard.y = touch.globalY-y;
		draggableCard.type = selectedCard.type;
		draggableCard.data = selectedCard.data;
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
			trace(draggableCard.data, draggableCard.type)
			var card:Building = appModel.battleFieldView.battleData.battleField.deckBuildings.get(draggableCard.data as int).building;
			if( place != null && place.place.building.transformable(card) )
				appModel.battleFieldView.responseSender.improveBuilding(place.place.index, draggableCard.data as int);
			
			Starling.juggler.tween(draggableCard, 0.1, {scale:0, onComplete:draggableCard.removeFromParent});
		/*var cardIndex:int = deckHeader.getCardIndex(touch);
		if( touchId == -1 && cardIndex > -1 )
		Starling.juggler.tween(draggableCard, 0.2, {x:deckHeader.cardsBounds[cardIndex].x+deckHeader.cardsBounds[cardIndex].width*0.5, y:deckHeader.cardsBounds[cardIndex].y+deckHeader.cardsBounds[cardIndex].height*0.5, onComplete:pushToDeck, onCompleteArgs:[cardIndex] });
		else
		pushToDeck(cardIndex);*/
			touchId = -1;			
		}
	}
}
}
}