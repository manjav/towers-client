package com.gerantech.towercraft.controls.headers
{
import com.gerantech.towercraft.controls.BattleDeckCard;
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.sliders.ElixirBar;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.controls.LayoutGroup;
import feathers.controls.text.BitmapFontTextRenderer;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import flash.geom.Rectangle;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Quad;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class BattleFooter extends TowersLayout
{
public var stickerButton:CustomButton;
private var _height:int;
private var _scaleDistance:int;
private var padding:int;
private var cards:Vector.<BattleDeckCard>;
private var cardsContainer:LayoutGroup;
private var draggableCard:BuildingCard;
private var touchId:int;
private var elixirBar:ElixirBar;
private var elixirCountDisplay:BitmapFontTextRenderer;
private var cardQueue:Vector.<int>;
private var preparedCard:BuildingCard;
public function BattleFooter()
{
	super();
	padding = 12;
	_height = 380;
	_scaleDistance = 500;
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	backgroundSkin = new Quad(1, 1, 0);
	backgroundSkin.alpha = 0.7;
	height = _height;
	
	cardsContainer = new LayoutGroup();
	cardsContainer.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
	addChild(cardsContainer);
	
	var hlayout:HorizontalLayout = new HorizontalLayout();
	hlayout.padding = hlayout.gap = 16;
	hlayout.verticalAlign = VerticalAlign.JUSTIFY;
	hlayout.horizontalAlign = HorizontalAlign.RIGHT;
	cardsContainer.layout = hlayout;
	
	cardQueue = appModel.battleFieldView.battleData.getAlliseDeck().values();
	
	cards = new Vector.<BattleDeckCard>();
	var minDeckSize:int = Math.min(4, cardQueue.length);
	for ( var i:int = 0; i < minDeckSize; i++ ) 
		createDeckItem(cardQueue.shift());
	
	preparedCard = new BuildingCard(false, false, false, false);
	preparedCard.width = 160;
	preparedCard.layoutData = new AnchorLayoutData(NaN, NaN, 0, 0);
	preparedCard.setData(cardQueue[0]);
	addChild(preparedCard);
	
	draggableCard = new BuildingCard(false, false, false, false);
	draggableCard.touchable = false;
	draggableCard.width = 220;
	draggableCard.height = draggableCard.width * BuildingCard.VERICAL_SCALE;
	draggableCard.pivotX = draggableCard.width * 0.5;
	draggableCard.pivotY = draggableCard.height * 0.5;
	
	if( !SFSConnection.instance.mySelf.isSpectator )
	{
		stickerButton = new CustomButton();
		stickerButton.icon = Assets.getTexture("tooltip-bg-bot-left", "gui");
		stickerButton.iconLayout = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -4);
		stickerButton.width = preparedCard.width - padding * 2;
		stickerButton.layoutData = new AnchorLayoutData(padding, NaN, NaN, padding);
		stickerButton.addEventListener(Event.TRIGGERED, stickerButton_triggeredHandler);
		addChild(stickerButton);
	}
	
	elixirBar = new ElixirBar();
	elixirBar.layoutData = new AnchorLayoutData(NaN, padding, padding, preparedCard.width);
	addChild(elixirBar);
	
	addEventListener(TouchEvent.TOUCH, touchHandler);
	SFSConnection.instance.addEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, sfsConnection_roomVariablesUpdateHandler);
}

protected function stickerButton_triggeredHandler():void
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
	for( var i:int=0; i<cards.length; i++ )
		cards[i].updateData();
}

private function createDeckItem(cardType:int):void
{
	var card:BattleDeckCard = new BattleDeckCard( cardType );
	card.width = 200;
	cards.push(card);
	cardsContainer.addChild(card);
}

protected function touchHandler(event:TouchEvent):void
{
	var touch:Touch = event.getTouch(this);
	if( touch == null )
		return;
	if( touch.phase == TouchPhase.BEGAN )
	{
		var selectedCard:BuildingCard = touch.target.parent as BuildingCard;
		if( selectedCard == null || !selectedCard.touchable )
		{
			touchId = -1;			
			return;
		}
		
		selectedCard.parent.visible = false;
		//trace(selectedCard.parent, selectedCard.parent.touchable)
		touchId = touch.id;
		draggableCard.x = touch.globalX - x;
		draggableCard.y = touch.globalY - y;
		Starling.juggler.tween(draggableCard, 0.1, {scale:1.3});
		addChild(draggableCard);
		draggableCard.setData(selectedCard.type);
		//draggableCard.data = selectedCard.data;
	}
	else 
	{
		if( touchId != touch.id )
			return;
		if( touch.phase == TouchPhase.MOVED )
		{
			draggableCard.x = touch.globalX-x;
			draggableCard.y = touch.globalY-y;
			draggableCard.scale = Math.max(0.5, (_scaleDistance+Math.min(touch.globalY - y, 0)) / _scaleDistance * 1.2);
			/*var place:PlaceView = appModel.battleFieldView.dropTargets.contain(touch.globalX, touch.globalY) as PlaceView;
			if( place == null )
				return;*/
			//place.place.building.improvable(draggableCard.type);
			//deckHeader.getCardIndex(touch);
		}
		else if( touch.phase == TouchPhase.ENDED )
		{
			selectedCard = touch.target.parent as BuildingCard;
			if( touch.globalY < 1435 && touch.globalY > 800 )
			{
				cardQueue.push(draggableCard.type);
				selectedCard.setData(cardQueue.shift());
				preparedCard.setData(cardQueue[0]);
				animatePushDeck(selectedCard);
				Starling.juggler.tween(draggableCard, 0.1, {scale:0, onComplete:draggableCard.removeFromParent});
				
				appModel.battleFieldView.responseSender.deployUnit(draggableCard.type, touch.globalX, touch.globalY);
			}
			else
			{
				draggableCard.removeFromParent();
				selectedCard.parent.visible = true;	
			}
			
			/*place = appModel.battleFieldView.dropTargets.contain(touch.globalX, touch.globalY) as PlaceView;
			var card:Card = appModel.battleFieldView.battleData.battleField.deckBuildings.get(draggableCard.data as int).building;
			if( place != null && place.place.building.transformable(card) )
			{
				appModel.battleFieldView.responseSender.improveBuilding(place.place.index, draggableCard.data as int);
				elixirBar.value -= card.elixirSize;
				place.showDeployWaiting(card);
			}*/
			
		/*var cardIndex:int = deckHeader.getCardIndex(touch);
		if( touchId == -1 && cardIndex > -1 )
		Starling.juggler.tween(draggableCard, 0.2, {x:deckHeader.cardsBounds[cardIndex].x+deckHeader.cardsBounds[cardIndex].width*0.5, y:deckHeader.cardsBounds[cardIndex].y+deckHeader.cardsBounds[cardIndex].height*0.5, onComplete:pushToDeck, onCompleteArgs:[cardIndex] });
		else
		pushToDeck(cardIndex);*/
			touchId = -1;			
		}
	}
}

private function animatePushDeck(deckSelected:BuildingCard):void 
{
	var card:BuildingCard = new BuildingCard(false, false, false, false);
	card.touchable = false;
	card.x = preparedCard.x;
	card.y = preparedCard.y;
	card.width = preparedCard.width;
	card.setData(deckSelected.type);
	addChild(card);
	var b:Rectangle = deckSelected.getBounds(this);
	Starling.juggler.tween(card, 0.4, {x:b.x, y:b.y, width:b.width, height:b.height, transition:Transitions.EASE_IN_OUT, onComplete:pushAnimationCompleted});
	function pushAnimationCompleted() : void
	{
		card.removeFromParent(true);
		deckSelected.parent.visible = true;	
	}
}
}
}