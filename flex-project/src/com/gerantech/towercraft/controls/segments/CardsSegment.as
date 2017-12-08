package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.headers.DeckHeader;
import com.gerantech.towercraft.controls.items.BuildingItemRenderer;
import com.gerantech.towercraft.controls.overlays.BuildingUpgradeOverlay;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.popups.CardDetailsPopup;
import com.gerantech.towercraft.controls.popups.CardSelectPopup;
import com.gerantech.towercraft.controls.popups.RequirementConfirmPopup;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gt.towers.buildings.Building;
import com.gt.towers.utils.lists.IntList;
import com.smartfoxserver.v2.entities.data.SFSObject;

import flash.geom.Rectangle;
import flash.utils.setTimeout;

import feathers.controls.Header;
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

private var selectPopup:CardSelectPopup;
private var detailsPopup:CardDetailsPopup;

private var deckHeader:DeckHeader;
private var startScrollBarIndicator:Number = 0;

private var draggableCard:BuildingCard;
private var touchId:int = -1;
private var _editMode:Boolean;
private var scroller:ScrollContainer;

override public function init():void
{
	super.init();
	updateData();
	padding = 36 * appModel.scale;
	
	backgroundSkin = new Quad(1,1);
	backgroundSkin.alpha = 0;
	
	
	deckHeader = new DeckHeader();
	deckHeader.addEventListener(Event.SELECT, deckHeader_selectHandler);
	deckHeader.layoutData = new AnchorLayoutData(NaN, 0, NaN, 0);
	addChild(deckHeader);
	
	var scrollerLayout:VerticalLayout = new VerticalLayout();
	scrollerLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	scrollerLayout.padding = scrollerLayout.gap = padding;
	scrollerLayout.paddingTop = deckHeader._height + padding;
	
	scroller = new ScrollContainer();
	scroller.layout = scrollerLayout;
	scroller.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	scroller.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	scroller.addEventListener(Event.SCROLL, scroller_scrollHandler);
	addChildAt(scroller, 0);
	
	var foundLabel:RTLLabel = new RTLLabel(loc("found_cards", [player.decks.get(player.selectedDeck).size()+foundCollection.length, player.decks.get(player.selectedDeck).size()+foundCollection.length+availabledCollection.length]), 0xBBCCDD, null, null, false, null, 0.8);
	scroller.addChild(foundLabel);
	
	layout = new AnchorLayout();
	var foundLayout:TiledRowsLayout = new TiledRowsLayout();
	var availabledLayout:TiledRowsLayout = new TiledRowsLayout();
	availabledLayout.gap = foundLayout.gap = padding * 0.5;
	availabledLayout.useSquareTiles = foundLayout.useSquareTiles = false;
	availabledLayout.useVirtualLayout = foundLayout.useVirtualLayout = false;
	availabledLayout.requestedColumnCount = foundLayout.requestedColumnCount = 4;
	availabledLayout.typicalItemWidth = foundLayout.typicalItemWidth = (width - foundLayout.gap*(foundLayout.requestedColumnCount-1) - padding*2) / foundLayout.requestedColumnCount;
	foundLayout.typicalItemHeight = foundLayout.typicalItemWidth * 1.5;
	availabledLayout.typicalItemHeight = foundLayout.typicalItemWidth * 1.3;
	
	foundList = new List();
	foundList.verticalScrollPolicy = ScrollPolicy.OFF;
	foundList.elasticity = 0.01;
	//unlocksList.decelerationRate = 1;
	foundList.layout = foundLayout;
	foundList.itemRendererFactory = function():IListItemRenderer { return new BuildingItemRenderer(true, scroller); }
	foundList.dataProvider = foundCollection;
	foundList.addEventListener(FeathersEventType.FOCUS_IN, unlocksList_focusInHandler);
	scroller.addChild(foundList);
		
	var availabledLabel:RTLLabel = new RTLLabel(loc("availabled_cards"), 0xBBCCDD, null, null, false, null, 0.8);
	availabledLabel.layoutData = new AnchorLayoutData(deckHeader._height + foundList.height + padding*4, padding, NaN, padding);
	scroller.addChild(availabledLabel);	
	
	availabledList = new List();
	availabledList.verticalScrollPolicy = ScrollPolicy.OFF;
	availabledList.elasticity = 0.01;
	//availabledList.decelerationRate = 1;
	availabledList.layout = availabledLayout;
	availabledList.itemRendererFactory = function():IListItemRenderer { return new BuildingItemRenderer(true, scroller); }
	availabledList.dataProvider = availabledCollection;
	availabledList.addEventListener(FeathersEventType.FOCUS_IN, availabledList_focusInHandler);
	scroller.addChild(availabledList);

	initializeCompleted = true;
	showTutorial();
}

override public function focus():void
{
	if( initializeCompleted )
		showTutorial();
}
protected function scroller_scrollHandler(event:Event):void
{
	var scrollPos:Number = Math.max(0, scroller.verticalScrollPosition);
	var changes:Number = startScrollBarIndicator-scrollPos;
	deckHeader.y = Math.max(-deckHeader._height, Math.min(0, deckHeader.y+changes));
	deckHeader.visible = deckHeader.y > -deckHeader._height
	startScrollBarIndicator = scrollPos;
}
private function showTutorial():void
{
	//if( player.prefs.getAsInt(PrefsTypes.TUTE_STEP_101) != PrefsTypes.TUTE_113_SELECT_DECK )
		return;
	
	/*player.prefs.set(PrefsTypes.TUTE_STEP_101, PrefsTypes.TUTE_114_SELECT_BUILDING.toString() );
	var tutorialData:TutorialData = new TutorialData("deck_start");
	tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_deck_0", null, 1000, 1000, 0));
	tutorials.show(tutorialData);*/
}		
override public function updateData():void
{
	if(foundCollection == null)
		foundCollection = new ListCollection();
	var founds:Array = new Array();
	var _founds:Vector.<int> = player.buildings.keys();
	var c:int = 0;
	while( _founds.length > 0 )
	{
		c = _founds.pop();
		if( player.decks.get(player.selectedDeck).indexOf(c) == -1 )
			founds.push(c);
	}
	foundCollection.data = founds;
	
	
	if(availabledCollection == null)
		availabledCollection = new ListCollection();
	var availables:Array = new Array();
	var _availables:IntList = player.availabledCards();
	c = 0;
	while( c < _availables.size() )
	{
		if( !player.buildings.exists(_availables.get(c)) )
			availables.push(_availables.get(c));
		c ++;
	}
	availables.reverse();
	availabledCollection.data = availables;
}

private function unlocksList_focusInHandler(event:Event):void
{
	var item:BuildingItemRenderer = event.data as BuildingItemRenderer;
	selectCard(item.data as int, item.getBounds(this));
}
private function deckHeader_selectHandler(event:Event):void
{
	var item:BuildingCard = event.data as BuildingCard;
	selectCard(item.type, item.getBounds(this));
}
private function selectCard(buildingType:int, cardBounds:Rectangle):void
{
	/*if( player.inTutorial() && buildingType != BuildingType.B11_BARRACKS )
	return;// disalble all items in tutorial
	
	if( !player.buildings.exists( buildingType ) )
	{
	var unlockedAt:int = game.unlockedBuildingAt( buildingType );
	if( unlockedAt <= player.get_arena(0) )
	appModel.navigator.addLog(loc("earn_at_chests"));
	else
	appModel.navigator.addLog(loc("arena_unlocked_at", [loc("arena_text") + " " + loc("num_"+(unlockedAt+1))]));
	return;
	}
	
	if( player.inTutorial() )
	{
	seudUpgradeRequest(player.buildings.get(buildingType), 0);
	UserData.instance.prefs.setInt(PrefsTypes.TUTE_STEP_101, PrefsTypes.TUTE_115_UPGRADE_BUILDING );
	tutorials.dispatchEventWith("upgrade");
	return;
	}*/
	
	var deckInex:int = player.decks.get(player.selectedDeck).indexOf(buildingType);
	// create transition data
	var ti:TransitionData = new TransitionData(0.1);
	var to:TransitionData = new TransitionData(0.1);
	to.destinationBound = ti.sourceBound = cardBounds;
	ti.destinationBound = to.sourceBound = new Rectangle(cardBounds.x-padding*0.5, cardBounds.y-padding, cardBounds.width+padding, cardBounds.height+padding*(deckInex>-1?4.9:7.4)); 
	to.destinationConstrain = ti.destinationConstrain = this.getBounds(stage);
	
	selectPopup = new CardSelectPopup();
	selectPopup.data = deckInex;
	selectPopup.buildingType = buildingType;
	selectPopup.transitionIn = ti;
	selectPopup.transitionOut = to;
	selectPopup.addEventListener(Event.CLOSE, selectPopup_closeHandler);
	appModel.navigator.addPopup(selectPopup);
	selectPopup.addEventListener(Event.OPEN, selectPopup_openHandler);
	selectPopup.addEventListener(Event.SELECT, selectPopup_selectHandler);
	function selectPopup_closeHandler(event:Event):void { foundList.selectedIndex = -1; }
	function selectPopup_openHandler(event:Event):void { showCardDetails(buildingType); }	
}

private function availabledList_focusInHandler(event:Event):void
{
	showCardDetails(BuildingItemRenderer(event.data).data as int);
}

private function showCardDetails(buildingType:int):void
{
	detailsPopup = new CardDetailsPopup();
	detailsPopup.buildingType = buildingType;
	detailsPopup.addEventListener(Event.SELECT, selectPopup_selectHandler);
	detailsPopup.addEventListener(Event.UPDATE, details_updateHandler);
	appModel.navigator.addPopup(detailsPopup);	
}
private function selectPopup_selectHandler(event:Event):void
{
	var type:int = -1;
	if( event.currentTarget is CardDetailsPopup )
		type = detailsPopup.buildingType;
	else
		type = selectPopup.buildingType;
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
		dispatchEventWith("scrollPolicy", true, false);
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
	deckHeader.cards[cardIndex].type = draggableCard.type;
	player.get_current_deck().set(cardIndex, draggableCard.type);
	
	var params:SFSObject = new SFSObject();
	params.putShort("index", cardIndex);
	params.putShort("type", draggableCard.type);
	params.putShort("deckIndex", player.selectedDeck);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.CHANGE_DECK, params);
	
	dispatchEventWith("scrollPolicy", true, true);
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
		
		draggableCard = new BuildingCard();
		draggableCard.showLevel = false;
		draggableCard.showSlider = false;
		draggableCard.width = 240 * appModel.scale;
		draggableCard.height = 360 * appModel.scale;
		draggableCard.pivotX = draggableCard.width * 0.5;
		draggableCard.pivotY = draggableCard.height * 0.5;
		draggableCard.x = stage.stageWidth * 0.5;
		draggableCard.y = stage.stageHeight * 0.7;
		draggableCard.alpha = 0;
		Starling.juggler.tween(draggableCard, 0.5, {alpha:1, y:stage.stageHeight * 0.6, transition:Transitions.EASE_OUT});
		addChild(draggableCard);
		draggableCard.type = type;
		
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
}

private function details_updateHandler(event:Event):void
{
	var building:Building = event.data as Building;
	var confirmedHards:int = 0;
	if( !player.has(building.get_upgradeRequirements()) )
	{
		var confirm:RequirementConfirmPopup = new RequirementConfirmPopup(loc("popup_cardtogem_message"), building.get_upgradeRequirements());
		confirm.data = building;
		confirm.addEventListener(FeathersEventType.ERROR, upgradeConfirm_errorHandler);
		confirm.addEventListener(Event.SELECT, upgradeConfirm_selectHandler);
		appModel.navigator.addPopup(confirm);
		return;
	}
	
	seudUpgradeRequest(building, 0);
}
private function upgradeConfirm_errorHandler(event:Event):void
{
	appModel.navigator.addLog(loc("log_not_enough", [loc("resource_title_1003")]));
}
private function upgradeConfirm_selectHandler(event:Event):void
{
	var confirm:RequirementConfirmPopup = event.currentTarget as RequirementConfirmPopup;
	seudUpgradeRequest( confirm.data as Building, exchanger.toHard(player.deductions(confirm.requirements)) );
}

private function seudUpgradeRequest(building:Building, confirmedHards:int):void
{
	if( selectPopup != null )
	{
		selectPopup.close();
		selectPopup = null;
	}
	
	if( !building.upgrade(confirmedHards) )
		return;
	
	var sfs:SFSObject = new SFSObject();
	sfs.putInt("type", building.type);
	sfs.putInt("confirmedHards", confirmedHards);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.BUILDING_UPGRADE, sfs);
	
	var upgradeOverlay:BuildingUpgradeOverlay = new BuildingUpgradeOverlay();
	upgradeOverlay.building = building;
	appModel.navigator.addOverlay(upgradeOverlay);
	
	deckHeader.update();
	updateData();
}
}
}