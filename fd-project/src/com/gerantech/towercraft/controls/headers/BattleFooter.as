package com.gerantech.towercraft.controls.headers
{
import com.gerantech.towercraft.controls.BattleDeckCard;
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.sliders.ElixirBar;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.views.units.CardPlaceHolder;
import com.gt.towers.battle.BattleField;
import com.gt.towers.constants.CardTypes;
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
import flash.geom.Point;
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
static public var HEIGHT:int = 380;
public var stickerButton:CustomButton;
public var cards:Vector.<BattleDeckCard>;
private var padding:int;
private var cardsContainer:LayoutGroup;
private var draggableCard:Draggable;
private var preparedCard:BuildingCard;
private var placeHolder:CardPlaceHolder;
private var touchId:int;
private var elixirBar:ElixirBar;
private var elixirCountDisplay:BitmapFontTextRenderer;
private var cardQueue:Vector.<int>;
private var touchPosition:Point = new Point();
private var selectedCard:BattleDeckCard;
private var selectedCardPosition:Rectangle;

public function BattleFooter()
{
	super();
	padding = 12;
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	backgroundSkin = new Quad(1, 1, 0);
	backgroundSkin.alpha = 0.7;
	height = HEIGHT;
	
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
	preparedCard.touchable = false;
	preparedCard.width = 160;
	preparedCard.layoutData = new AnchorLayoutData(NaN, NaN, 0, 0);
	preparedCard.setData(cardQueue[0]);
	addChild(preparedCard);
	
	if( !SFSConnection.instance.mySelf.isSpectator )
	{
		stickerButton = new CustomButton();
		stickerButton.icon = Assets.getTexture("tooltip-bg-bot-left");
		stickerButton.iconLayout = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -4);
		stickerButton.width = preparedCard.width - padding * 2;
		stickerButton.layoutData = new AnchorLayoutData(padding, NaN, NaN, padding);
		stickerButton.addEventListener(Event.TRIGGERED, stickerButton_triggeredHandler);
		addChild(stickerButton);
	}
	
	elixirBar = new ElixirBar();
	elixirBar.layoutData = new AnchorLayoutData(NaN, padding, padding, preparedCard.width);
	addChild(elixirBar);
	
	draggableCard = new Draggable();
	
	placeHolder = new CardPlaceHolder();
	
	stage.addEventListener(TouchEvent.TOUCH, stage_touchHandler);
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
	elixirBar.value = appModel.battleFieldView.battleData.getAlliseEllixir();
	for( var i:int=0; i<cards.length; i++ )
		cards[i].updateData();
}

private function createDeckItem(cardType:int) : void
{
	var card:BattleDeckCard = new BattleDeckCard(cardType);
	card.width = 200;
	cards.push(card);
	cardsContainer.addChild(card);
}

protected function stage_touchHandler(event:TouchEvent) : void
{
	var touch:Touch = event.getTouch(stage);
	if( touch == null )
		return;
	if( touch.phase == TouchPhase.BEGAN )
	{
		if( touch.target is BattleDeckCard )
			selectedCard = touch.target as BattleDeckCard;
		if( selectedCard == null || !selectedCard.touchable )
		{
			/*if( touch.target is BattleFieldView )
				touchId = touch.id;
			else*/
			touchId = -1;
			return;
		}
		
		touchId = touch.id;
		selectedCard.visible = false;
		
		selectedCardPosition = selectedCard.getBounds(stage);
		draggableCard.x = placeHolder.x = selectedCardPosition.x += selectedCard.width * 0.50;
		draggableCard.y = placeHolder.y = selectedCardPosition.y += selectedCard.height * 0.44;
		Starling.juggler.tween(draggableCard, 0.1, {scale:1});
		draggableCard.visible = true;
		draggableCard.setData(placeHolder.type = selectedCard.cardType);
		stage.addChild(draggableCard);
		stage.addChild(placeHolder);
	}
	else 
	{
		if( touchId != touch.id )
			return;
		if( touch.phase == TouchPhase.MOVED )
		{
			setTouchPosition(touch);
			placeHolder.x = draggableCard.x = touchPosition.x;
			placeHolder.y = draggableCard.y = touchPosition.y;
			draggableCard.scale = Math.min(1.2, (100 + touch.globalY - y) / 200 * 1.2);
			draggableCard.visible = draggableCard.scale >= 0.6;
			placeHolder.visible = !draggableCard.visible;
		}
		else if( touch.phase == TouchPhase.ENDED && selectedCard != null )
		{
			placeHolder.removeFromParent();
			setTouchPosition(touch);
			touchPosition.x -= (appModel.battleFieldView.x - BattleField.WIDTH * 0.5);
			touchPosition.y -= (appModel.battleFieldView.y - BattleField.HEIGHT * 0.5);
			if( touchPosition.y < BattleField.HEIGHT && touchPosition.y > BattleField.HEIGHT * (CardTypes.isSpell(selectedCard.cardType)?0.0:0.5) && appModel.battleFieldView.battleData.getAlliseEllixir() >= draggableCard.elixirSize )
			{
				cardQueue.push(selectedCard.cardType);
				selectedCard.setData(cardQueue.shift());
				preparedCard.setData(cardQueue[0]);
				pushNewCardToDeck(selectedCard);
				Starling.juggler.tween(draggableCard, 0.1, {scale:0, onComplete:draggableCard.removeFromParent});
				selectedCard = null;
				
				elixirBar.value -= draggableCard.elixirSize;
				for( var i:int=0; i < cards.length; i++ )
					cards[i].updateData();
					
				touchPosition.x = appModel.battleFieldView.battleData.battleField.side == 0 ? touchPosition.x : BattleField.WIDTH - touchPosition.x;
				touchPosition.y = appModel.battleFieldView.battleData.battleField.side == 0 ? touchPosition.y : BattleField.HEIGHT - touchPosition.y;
				appModel.battleFieldView.responseSender.summonUnit(draggableCard.type, touchPosition.x, touchPosition.y);
			}
			else
			{
				draggableCard.x = selectedCardPosition.x;
				draggableCard.y = selectedCardPosition.y;
				draggableCard.scale = 1;
				selectedCard.visible = true;	
			}
			touchId = -1;			
		}
	}
}

private function setTouchPosition(touch:Touch) : void 
{
	touchPosition.x = Math.max(BattleField.PADDING, Math.min(stageWidth - BattleField.PADDING, touch.globalX));
	touchPosition.y = Math.max(BattleField.HEIGHT * (CardTypes.isSpell(selectedCard.cardType)?-0.5:0.01) + appModel.battleFieldView.y, touch.globalY);
}

private function pushNewCardToDeck(deckSelected:BattleDeckCard) : void 
{
	var card:BuildingCard = new BuildingCard(false, false, false, false);
	card.touchable = false;
	card.x = preparedCard.x;
	card.y = preparedCard.y;
	card.width = preparedCard.width;
	card.setData(deckSelected.cardType);
	addChild(card);
	var b:Rectangle = deckSelected.getBounds(this);
	Starling.juggler.tween(card, 0.4, {x:b.x, y:b.y, width:b.width, height:b.height, transition:Transitions.EASE_IN_OUT, onComplete:pushAnimationCompleted});
	function pushAnimationCompleted() : void
	{
		card.removeFromParent(true);
		deckSelected.visible = true;	
	}
}

override public function dispose() : void
{
	super.dispose();
	SFSConnection.instance.removeEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, sfsConnection_roomVariablesUpdateHandler);
	draggableCard.removeFromParent(true);
	placeHolder.removeFromParent(true);
	removeEventListener(TouchEvent.TOUCH, stage_touchHandler);
}
}
}
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.models.Assets;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
class Draggable extends BuildingCard
{
public function Draggable()
{
	super(false, false, false, false);
	touchable = false;
	showRarity = false;
	width = 220;
	height = width * BuildingCard.VERICAL_SCALE;
	pivotX = width * 0.5;
	pivotY = height * 0.5;
}
override protected function createCompleteHandler():void
{
	super.createCompleteHandler();
	
	var hilight:ImageLoader = new ImageLoader();
	hilight.touchable = false;
	hilight.scale9Grid = new Rectangle(39, 39, 4, 4);
	hilight.layoutData = new AnchorLayoutData(-2, -2, -2, -2);
	hilight.source = Assets.getTexture("cards/hilight", "gui");
	addChild(hilight);
}
}