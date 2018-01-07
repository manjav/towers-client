package com.gerantech.towercraft.controls.headers
{
import com.gerantech.towercraft.controls.BattleDeckCard;
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.sliders.ElixirBar;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.views.HealthBar;
import com.gerantech.towercraft.views.PlaceView;
import com.gt.towers.battle.BattleField;
import com.gt.towers.buildings.Building;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.controls.text.BitmapFontTextRenderer;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.text.BitmapFontTextFormat;

import starling.core.Starling;
import starling.display.Image;
import starling.display.Quad;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class BattleFooter extends TowersLayout
{
private var _height:int;
private var _scaleDistance:int;
private var padding:int;

private var cards:Vector.<BattleDeckCard>;
private var cardsContainer:LayoutGroup;
private var draggableCard:BuildingCard;
private var touchId:int;

private var elixirBar:ElixirBar;
private var elixirCountDisplay:BitmapFontTextRenderer;
public var stickerButton:CustomButton;

public function BattleFooter()
{
	super();
	_height = 300 * appModel.scale;
	padding = 12 * appModel.scale;
	_scaleDistance = 500 * appModel.scale;
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	backgroundSkin = new Quad(1,1,0);
	backgroundSkin.alpha = 0.7;
	height = _height;
	
	cardsContainer = new LayoutGroup();
	cardsContainer.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
	addChild(cardsContainer);
	
	var hlayout:HorizontalLayout = new HorizontalLayout();
	hlayout.padding = hlayout.gap = 16 * appModel.scale;
	hlayout.verticalAlign = VerticalAlign.JUSTIFY;
	hlayout.horizontalAlign = HorizontalAlign.RIGHT;
	cardsContainer.layout = hlayout;
	
	cards = new Vector.<BattleDeckCard>();
	for ( var i:int = 0; i < player.decks.get(player.selectedDeck).size(); i++ ) 
		createDeckItem(i);
	
	draggableCard = new BuildingCard();
	draggableCard.showLevel = false;
	draggableCard.showElixir = false;
	draggableCard.showSlider = false;
	draggableCard.showCount = true;
	draggableCard.width = 180 * appModel.scale;
	draggableCard.height = 210 * appModel.scale;
	draggableCard.pivotX = draggableCard.width * 0.5;
	draggableCard.pivotY = draggableCard.height * 0.5;
	draggableCard.includeInLayout = false;
	
	if( !SFSConnection.instance.mySelf.isSpectator )
	{
		stickerButton = new CustomButton();
		stickerButton.icon = Assets.getTexture("tooltip-bg-bot-left", "gui");
		stickerButton.iconLayout = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -4*appModel.scale);
		stickerButton.width = 140 * appModel.scale;
		stickerButton.layoutData = new AnchorLayoutData(padding, NaN, NaN, padding);
		stickerButton.addEventListener(Event.TRIGGERED, stickerButton_triggeredHandler);
		addChild(stickerButton);
	}
	
	elixirBar = new ElixirBar();
	elixirBar.layoutData = new AnchorLayoutData(NaN, padding, padding, padding);
	addChild(elixirBar);
		
	addEventListener(TouchEvent.TOUCH, touchHandler);
	SFSConnection.instance.addEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, sfsConnection_roomVariablesUpdateHandler);
}

private function stickerButton_triggeredHandler():void
{
	dispatchEventWith(FeathersEventType.BEGIN_INTERACTION);
}

protected function sfsConnection_roomVariablesUpdateHandler(event:SFSEvent):void
{
	if( !appModel.battleFieldView.battleData.room.containsVariable("bars") )
		return;
	var bars:SFSObject = appModel.battleFieldView.battleData.room.getVariable("bars").getValue() as SFSObject;
	appModel.battleFieldView.battleData.battleField.elixirBar.set(0, bars.getInt("0"));
	appModel.battleFieldView.battleData.battleField.elixirBar.set(1, bars.getInt("1"));
	elixirBar.value = appModel.battleFieldView.battleData.battleField.elixirBar.get(player.troopType);
	for( var i:int=0; i<cards.length; i++)
		cards[i].updateData();
}

private function createDeckItem(i:int):void
{
	var card:BattleDeckCard = new BattleDeckCard(appModel.battleFieldView.battleData.battleField.deckBuildings.get( (player.troopType==0?0:4) + i).building, (player.troopType==0?0:4) + i );
	card.width = 150 * appModel.scale;
	cards.push(card);
	cardsContainer.addChild(card);
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
		Starling.juggler.tween(draggableCard, 0.1, {scale:1.3});
		addChild(draggableCard);
		draggableCard.type = selectedCard.type;
		draggableCard.data = selectedCard.data;
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
			var card:Building = appModel.battleFieldView.battleData.battleField.deckBuildings.get(draggableCard.data as int).building;
			if( place != null && place.place.building.transformable(card) )
			{
				appModel.battleFieldView.responseSender.improveBuilding(place.place.index, draggableCard.data as int);
				elixirBar.value -= card.elixirSize;
				place.showDeployWaiting(card);
			}
			
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