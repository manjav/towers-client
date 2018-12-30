package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.headers.DeckHeader;
import com.gerantech.towercraft.controls.items.CardItemRenderer;
import com.gerantech.towercraft.controls.overlays.BuildingUpgradeOverlay;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.popups.CardDetailsPopup;
import com.gerantech.towercraft.controls.popups.CardSelectPopup;
import com.gerantech.towercraft.controls.popups.RequirementConfirmPopup;
import com.gerantech.towercraft.controls.screens.DashboardScreen;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.models.vo.UserData;
import com.gt.towers.battle.units.Card;
import com.gt.towers.constants.CardTypes;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.Exchanger;
import com.gt.towers.utils.lists.IntList;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.ScrollContainer;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.TiledRowsLayout;
import feathers.layout.VerticalLayout;
import flash.geom.Rectangle;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Quad;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class CardsSegment extends Segment
{
private var padding:int;
private var foundCollection:ListCollection;
private var foundList:List;
private var availabledCollection:ListCollection;
private var availabledList:List;
private var unavailableCollection:ListCollection;
private var unavailableList:List;
private var selectPopup:CardSelectPopup;
private var detailsPopup:CardDetailsPopup;
private var deckHeader:DeckHeader;
private var startScrollBarIndicator:Number = 0;
private var draggableCard:BuildingCard;
private var touchId:int = -1;
private var _editMode:Boolean;
private var scroller:ScrollContainer;

public function CardsSegment(){}
override public function init():void
{
	super.init();
	updateData();
	padding = 36;
	
	backgroundSkin = new Quad(1,1);
	backgroundSkin.alpha = 0;
	
	deckHeader = new DeckHeader();
	deckHeader.addEventListener(Event.SELECT, deckHeader_selectHandler);
	deckHeader.layoutData = new AnchorLayoutData(NaN, 0, NaN, 0);
	addChild(deckHeader);
	
	var scrollerLayout:VerticalLayout = new VerticalLayout();
	scrollerLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	scrollerLayout.padding = scrollerLayout.gap = padding * 0.5;
	scrollerLayout.paddingTop = deckHeader._height + padding;
	
	scroller = new ScrollContainer();
	scroller.layout = scrollerLayout;
	scroller.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	scroller.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	scroller.addEventListener(Event.SCROLL, scroller_scrollHandler);
	addChildAt(scroller, 0);
	

	var deckSize:int = player.getSelectedDeck().keys().length;
	var foundLabel:RTLLabel = new RTLLabel(loc("found_cards", [deckSize+foundCollection.length, deckSize+foundCollection.length + availabledCollection.length]), 0xBBCCDD, null, null, false, null, 0.8);
	scroller.addChild(foundLabel);
	
	layout = new AnchorLayout();
	var foundLayout:TiledRowsLayout = new TiledRowsLayout();
	var availabledLayout:TiledRowsLayout = new TiledRowsLayout();
	foundLayout.paddingTop = padding * 0.5;
	availabledLayout.gap = foundLayout.gap = padding * 1.3;
	availabledLayout.paddingBottom = foundLayout.paddingBottom = padding * 2;
	availabledLayout.useSquareTiles = foundLayout.useSquareTiles = false;
	availabledLayout.useVirtualLayout = foundLayout.useVirtualLayout = false;
	availabledLayout.requestedColumnCount = foundLayout.requestedColumnCount = 4;
	availabledLayout.typicalItemWidth = foundLayout.typicalItemWidth = (width - foundLayout.gap * (foundLayout.requestedColumnCount - 1) - padding * 2) / foundLayout.requestedColumnCount;
	availabledLayout.typicalItemHeight = foundLayout.typicalItemHeight = foundLayout.typicalItemWidth * BuildingCard.VERICAL_SCALE;

	foundList = new List();
	foundList.verticalScrollPolicy = ScrollPolicy.OFF;
	foundList.layout = foundLayout;
	foundList.itemRendererFactory = function():IListItemRenderer { return new CardItemRenderer(true, true, true, scroller); }
	foundList.dataProvider = foundCollection;
	foundList.addEventListener(FeathersEventType.FOCUS_IN, unlocksList_focusInHandler);
	scroller.addChild(foundList);
	
	if( availabledCollection.length > 0 )
	{
		var availabledLabel:RTLLabel = new RTLLabel(loc("availabled_cards"), 0xBBCCDD, null, null, false, null, 0.8);
		availabledLabel.layoutData = new AnchorLayoutData(deckHeader._height + foundList.height + padding * 4, padding, NaN, padding);
		scroller.addChild(availabledLabel);	
		
		availabledList = new List();
		availabledList.verticalScrollPolicy = ScrollPolicy.OFF;
		availabledList.layout = availabledLayout;
		availabledList.itemRendererFactory = function():IListItemRenderer { return new CardItemRenderer(false, false, false, scroller); }
		availabledList.dataProvider = availabledCollection;
		availabledList.addEventListener(FeathersEventType.FOCUS_IN, availabledList_focusInHandler);
		scroller.addChild(availabledList);
	}
	
	if( unavailableCollection.length > 0 )
	{
		var unavailableLabel:RTLLabel = new RTLLabel(loc("unavailable_cards"), 0xBBCCDD, null, null, false, null, 0.8);
		unavailableLabel.layoutData = new AnchorLayoutData(deckHeader._height + foundList.height + padding * 4, padding, NaN, padding);
		scroller.addChild(unavailableLabel);	
		
		unavailableList = new List();
		unavailableList.verticalScrollPolicy = ScrollPolicy.OFF;
		unavailableList.alpha = 0.8;
		unavailableList.layout = availabledLayout;
		unavailableList.itemRendererFactory = function():IListItemRenderer { return new CardItemRenderer(false, false, false, scroller); }
		unavailableList.dataProvider = unavailableCollection;
		//unavailabledList.addEventListener(FeathersEventType.FOCUS_IN, availabledList_focusInHandler);
		scroller.addChild(unavailableList);
	}
	
	initializeCompleted = true;
	showTutorial();
	exchangeManager.addEventListener(FeathersEventType.END_INTERACTION, exchangeManager_endHandler);
}
protected function exchangeManager_endHandler(event:Event):void
{
	deckHeader.update();
	updateData();
}

override public function focus():void
{
	if( initializeCompleted )
		showTutorial();
}
protected function scroller_scrollHandler(event:Event):void
{
	var scrollPos:Number = Math.max(0, scroller.verticalScrollPosition);
	var changes:Number = startScrollBarIndicator - scrollPos;
	deckHeader.y = Math.max( -deckHeader._height, Math.min(0, deckHeader.y + changes));
	deckHeader.visible = deckHeader.y > -deckHeader._height
	startScrollBarIndicator = scrollPos;
}
private function showTutorial():void
{
	/*if( player.getTutorStep() != PrefsTypes.TUTE_113_SELECT_DECK )
		return;
	
	player.prefs.set(PrefsTypes.TUTOR, PrefsTypes.TUTE_114_SELECT_BUILDING.toString() );
	var tutorialData:TutorialData = new TutorialData("deck_start");
	tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_deck_0", null, 500, 1500, 0));
	tutorials.show(tutorialData);*/
}		
override public function updateData():void
{
	if( foundCollection == null )
		foundCollection = new ListCollection();
	var founds:Array = new Array();
	var _founds:Vector.<int> = player.cards.keys();
	var c:int = 0;
	while( _founds.length > 0 )
	{
		c = _founds.shift();
		if( !player.getSelectedDeck().existsValue(c) )
			founds.push(c);
	}
	foundCollection.data = founds;
	
	// availabled cards
	if( availabledCollection == null )
		availabledCollection = new ListCollection();
	var availables:Array = new Array();
	var _availables:IntList = player.availabledCards();
	c = 0;
	while( c < _availables.size() )
	{
		if( !player.cards.exists(_availables.get(c)) )
			availables.push(_availables.get(c));
		c ++;
	}
	availables.reverse();
	availabledCollection.data = availables;
	
	// unavailabled cards
	if( unavailableCollection == null )
		unavailableCollection = new ListCollection();
	var unavailables:Array = new Array();
	var _unavailables:IntList = CardTypes.getAll();
	c = 0;
	while( c < _unavailables.size() )
	{
		if( _availables.indexOf(_unavailables.get(c)) == -1 )
			unavailables.push(_unavailables.get(c));
		c ++;
	}
	unavailableCollection.data = unavailables;
}

private function unlocksList_focusInHandler(event:Event):void
{
	var item:CardItemRenderer = event.data as CardItemRenderer;
	selectCard(item.data as int, item.getBounds(this));
}
private function deckHeader_selectHandler(event:Event):void
{
	var item:BuildingCard = event.data as BuildingCard;
	selectCard(item.type, item.getBounds(this));
}
private function selectCard(cardType:int, cardBounds:Rectangle):void
{
	var inDeck:Boolean = player.getSelectedDeck().existsValue(cardType);
	/*if( player.inTutorial() && cardType != CardTypes.B11_BARRACKS )
	return;// disalble all items in tutorial
	
	if( !player.cards.exists( cardType ) )
	{
	var unlockedAt:int = game.unlockedBuildingAt( cardType );
	if( unlockedAt <= player.get_arena(0) )
	appModel.navigator.addLog(loc("earn_at_chests"));
	else
	appModel.navigator.addLog(loc("arena_unlocked_at", [loc("arena_text") + " " + loc("num_"+(unlockedAt+1))]));
	return;
	}
	
	if( player.inTutorial() )
	{
	seudUpgradeRequest(player.cards.get(cardType), 0);
	UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.TUTE_115_UPGRADE_BUILDING );
	tutorials.dispatchEventWith("upgrade");
	return;
	}*/
	
	// create transition data
	var ti:TransitionData = new TransitionData(0.1);
	var to:TransitionData = new TransitionData(0.1);
	to.destinationBound = ti.sourceBound = cardBounds;
	ti.destinationBound = to.sourceBound = new Rectangle(cardBounds.x - padding * 0.5, cardBounds.y - padding, cardBounds.width + padding, cardBounds.height + padding * (inDeck?4.5:8));
	to.destinationConstrain = ti.destinationConstrain = this.getBounds(stage);
	
	selectPopup = new CardSelectPopup();
	selectPopup.cardType = cardType;
	selectPopup.data = inDeck;
	selectPopup.transitionIn = ti;
	selectPopup.transitionOut = to;
	selectPopup.addEventListener(Event.CLOSE, selectPopup_closeHandler);
	appModel.navigator.addPopup(selectPopup);
	selectPopup.addEventListener(Event.OPEN, selectPopup_openHandler);
	selectPopup.addEventListener(Event.SELECT, selectPopup_selectHandler);
	function selectPopup_closeHandler(event:Event):void { foundList.selectedIndex = -1; }
	function selectPopup_openHandler(event:Event):void { showCardDetails(cardType); }	
}

private function availabledList_focusInHandler(event:Event):void
{
	showCardDetails(CardItemRenderer(event.data).data as int);
}

private function showCardDetails(cardType:int):void
{
	detailsPopup = new CardDetailsPopup();
	detailsPopup.cardType = cardType;
	detailsPopup.addEventListener(Event.SELECT, selectPopup_selectHandler);
	detailsPopup.addEventListener(Event.UPDATE, details_updateHandler);
	appModel.navigator.addPopup(detailsPopup);	
}
private function selectPopup_selectHandler(event:Event):void
{
	var type:int = -1;
	if( event.currentTarget is CardDetailsPopup )
		type = detailsPopup.cardType;
	else
		type = selectPopup.cardType;
	setTimeout(setEditMode, 10, true, type);
}

private function touchHandler(event:TouchEvent):void
{
	var touch:Touch = event.getTouch(this);
	if( touch == null )
		return;
	
	if( touch.phase == TouchPhase.BEGAN)
	{
		if( touch.target.parent == draggableCard )
			touchId = touch.id;
		dispatchEventWith(Event.READY, true, false);
	}
	else if( touch.phase == TouchPhase.MOVED )
	{
		if( touchId != touch.id )
			return;
		draggableCard.x = touch.globalX;
		draggableCard.y = touch.globalY;
		deckHeader.getCardIndex(touch);
	}
	else if(touch.phase == TouchPhase.ENDED)
	{
		var cardIndex:int = deckHeader.getCardIndex(touch);
		if( touchId == -1 && cardIndex > -1 )
			Starling.juggler.tween(draggableCard, 0.2, {x:deckHeader.cardsBounds[cardIndex].x+deckHeader.cardsBounds[cardIndex].width*0.5, y:deckHeader.cardsBounds[cardIndex].y+deckHeader.cardsBounds[cardIndex].height*0.5, onComplete:pushToDeck, onCompleteArgs:[cardIndex] });
		else
			pushToDeck(cardIndex);
	}
}
private function pushToDeck(cardIndex:int):void
{
	if( cardIndex == -1 )
	{
		setEditMode(false, -1);
		return;
	}
	deckHeader.cards[cardIndex].iconDisplay.setData(draggableCard.type);
	player.getSelectedDeck().set(cardIndex, draggableCard.type);
	
	var params:SFSObject = new SFSObject();
	params.putShort("index", cardIndex);
	params.putShort("type", draggableCard.type);
	params.putShort("deckIndex", player.selectedDeckIndex);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.CHANGE_DECK, params);
	
	setEditMode(false, -1);
}

private function setEditMode(value:Boolean, type:int):void
{
	if( _editMode == value )
		return;
	
	_editMode = value;
	if( value )
	{
		scroller.scrollToPosition(0, 0);
		scroller.visible = false;
		deckHeader.removeEventListener(Event.SELECT, deckHeader_selectHandler);
		deckHeader.startHanging();
		
		draggableCard = new BuildingCard(false, false, false, false);
		draggableCard.width = 240;
		draggableCard.height = draggableCard.width * BuildingCard.VERICAL_SCALE;
		draggableCard.pivotX = draggableCard.width * 0.5;
		draggableCard.pivotY = draggableCard.height * 0.5;
		draggableCard.x = stage.stageWidth * 0.5;
		draggableCard.y = stage.stageHeight * 0.7;
		draggableCard.alpha = 0;
		Starling.juggler.tween(draggableCard, 0.5, {alpha:1, y:stage.stageHeight * 0.6, transition:Transitions.EASE_OUT});
		addChild(draggableCard);
		draggableCard.setData(type);
		
		addEventListener(TouchEvent.TOUCH, touchHandler);
		return;
	}

	deckHeader.addEventListener(Event.SELECT, deckHeader_selectHandler);
	deckHeader.fix();
	draggableCard.removeFromParent(true);
	draggableCard = null;	
	touchId = -1;
	updateData();
	scroller.visible = true;
	scroller.alpha = 0;
	Starling.juggler.tween(scroller, 0.3, {alpha:1});
	removeEventListener(TouchEvent.TOUCH, touchHandler);
	dispatchEventWith(Event.READY, true, true);
}

private function details_updateHandler(event:Event):void
{
	var cardType:int = event.data as int;
	if( !player.cards.exists(cardType) )
		return;
	
	var card:Card = player.cards.get(cardType);
	var confirmedHards:int = 0;
	if( !player.has(card.get_upgradeRequirements()) )
	{
		var confirm:RequirementConfirmPopup = new RequirementConfirmPopup(loc("popup_cardtogem_message"), card.get_upgradeRequirements());
		confirm.data = card;
		confirm.addEventListener(FeathersEventType.ERROR, upgradeConfirm_errorHandler);
		confirm.addEventListener(Event.SELECT, upgradeConfirm_selectHandler);
		appModel.navigator.addPopup(confirm);
		return;
	}
	
	seudUpgradeRequest(card, 0);
}
private function upgradeConfirm_errorHandler(event:Event):void
{
    appModel.navigator.toolbar.dispatchEventWith(Event.SELECT, true, {resourceType:ResourceType.R3_CURRENCY_SOFT});
    appModel.navigator.addLog(loc("log_not_enough", [loc("resource_title_" + ResourceType.R3_CURRENCY_SOFT)]));
    detailsPopup.close();
}
private function upgradeConfirm_selectHandler(event:Event):void
{
	var confirm:RequirementConfirmPopup = event.currentTarget as RequirementConfirmPopup;
	seudUpgradeRequest( confirm.data as Card, Exchanger.toHard(player.deductions(confirm.requirements)) );
}

private function seudUpgradeRequest(card:Card, confirmedHards:int):void
{
	if( selectPopup != null )
	{
		selectPopup.close();
		selectPopup = null;
	}
	
	if( !card.upgrade(confirmedHards) )
		return;
	
	var sfs:SFSObject = new SFSObject();
	sfs.putInt("type", card.type);
	sfs.putInt("confirmedHards", confirmedHards);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.CARD_UPGRADE, sfs);
	
	var upgradeOverlay:BuildingUpgradeOverlay = new BuildingUpgradeOverlay();
	upgradeOverlay.card = card;
	upgradeOverlay.addEventListener(Event.CLOSE, upgradeOverlay_closeHandler);
	appModel.navigator.addOverlay(upgradeOverlay);
	
	deckHeader.update();
	updateData();
}		

private function upgradeOverlay_closeHandler(event:Event):void 
{
	var upgradeOverlay:BuildingUpgradeOverlay = event.currentTarget as BuildingUpgradeOverlay;
	if( player.inTutorial() && upgradeOverlay.card.type == CardTypes.INITIAL && upgradeOverlay.card.level == 2 )
	{
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_018_CARD_UPGRADED );
		
		// dispatch tutorial event
		var tutorialData:TutorialData = new TutorialData("deck_end");
		tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_deck_0", null, 500, 1500, 0));
		tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_finishHandler);
		tutorials.show(tutorialData);
	}	
}

private function tutorials_finishHandler(event:Event):void 
{
	var tutorial:TutorialData = event.data as TutorialData;
	if( tutorial.name != "deck_end" )
		return;
	tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_finishHandler);
	UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_019_RETURN_TO_BATTLE );
	DashboardScreen.TAB_INDEX = 2;
	appModel.navigator.runBattle();

}
}
}