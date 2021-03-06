package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.groups.Devider;
import com.gerantech.towercraft.controls.popups.CardDetailsPopup;
import com.gerantech.towercraft.controls.screens.FactionsScreen;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.arenas.Arena;

import flash.geom.Rectangle;
import flash.utils.setTimeout;

import dragonBones.starling.StarlingArmatureDisplay;

import feathers.controls.LayoutGroup;
import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.TiledRowsLayout;
import feathers.layout.VerticalAlign;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class FactionItemRenderer extends AbstractListItemRenderer
{
public static var _height:Number;
private var ready:Boolean;
public static var playerLeague:int;

private var faction:Arena;
private var padding:int;
private var commited:Boolean;

public function FactionItemRenderer()
{
	super();
}
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	height = _height;
	padding = 48 * appModel.scale;
	var iconSize:int = 400 * appModel.scale;
}

override protected function commitData():void
{
	super.commitData();
	if( index < 0 )
		return;
	
	faction = _data as Arena;//trace(index, faction.index , playerLeague)
	ready = faction.index == playerLeague;
	if( ready )
		createElements();
	else
	{
		_owner.addEventListener(Event.OPEN, _owner_openHandler);
		_owner.addEventListener(Event.SCROLL, _owner_scrollHandler);
	}
}

private function _owner_scrollHandler():void
{
	visible = onScreen(getBounds(stage))
}

private function _owner_openHandler(event:starling.events.Event):void
{
	_owner.removeEventListener(Event.OPEN, _owner_openHandler);
	ready = true;
	if( visible )
		createElements();
	else
		setTimeout(createElements, 800);
}

private function createElements():void
{
	if( commited || !ready )
		return;
	
	if( index > 0 )
	{
		var divider:Devider = new Devider(0, 2*appModel.scale);
		divider.layoutData = new AnchorLayoutData(0, padding, NaN, padding);
		divider.alpha = 0.4;
		addChild(divider);
	}
	// header elements
	var header:LayoutGroup = new LayoutGroup();
	header.layout = new AnchorLayout();
	var ribbon:Image = new Image(Assets.getTexture("ribbon-blue", "gui"));
	ribbon.scale = appModel.scale * 2;
	header.layoutData = new AnchorLayoutData(padding*3, NaN, NaN, NaN, 0); 
	ribbon.scale9Grid = new Rectangle(46, 30, 3, 3);
	header.backgroundSkin = ribbon;
	header.width = width * 0.6;
	header.height = 160  * appModel.scale;
	addChild(header);
	
	var factionNumber:RTLLabel = new RTLLabel(loc("arena_text") + " " + loc("num_"+(faction.index+1)) , 0xCCDDFF, null, null, false, null, 0.9);
	factionNumber.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -padding * 1.8); 
	factionNumber.pixelSnapping = false;
	header.addChild(factionNumber);
	
	var factionLabel:ShadowLabel = new ShadowLabel(loc("arena_title_" + faction.index), 1, 0, null, null, false, null, 1.2);
	factionLabel.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -padding * 0.4); 
	header.addChild(factionLabel);
	
	var factionMeature:RTLLabel = new RTLLabel((faction.min-(faction.min==0?0:1)) + "+" , 0xAABBCC, null, null, false, null, 0.9);
	factionMeature.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, padding); 
	factionMeature.pixelSnapping = false;
	header.addChild(factionMeature);
	
	// icon 
	var factionIcon:StarlingArmatureDisplay = FactionsScreen.animFactory.buildArmatureDisplay("arena-" + Math.min(8, faction.index));
	factionIcon.x = width * 0.5;
	factionIcon.y = padding * 12;
	factionIcon.scale = appModel.scale * 1.4;
	if( playerLeague >= faction.index )
		factionIcon.animation.gotoAndPlayByTime("selected", 0, 50);
	else
	{
		factionIcon.animation.gotoAndStopByTime("normal", 0);
		factionIcon.alpha = 0.7
	}
	addChild(factionIcon);
	
	var cards:Array = new Array();
	for (var i:int = 0; i < faction.cards.size(); i++) 
		cards.push( faction.cards.get(i) );
	
	
	// cards elements
	var cardsLayout:TiledRowsLayout = new TiledRowsLayout();
	cardsLayout.useVirtualLayout = false;
	cardsLayout.gap = 0;
	cardsLayout.typicalItemWidth = padding*(cards.length<5?4:3.6);
	cardsLayout.typicalItemHeight = cardsLayout.typicalItemWidth*1.3;
	cardsLayout.horizontalAlign = "center";
	cardsLayout.verticalAlign = VerticalAlign.JUSTIFY;
	
	var cardsList:List = new List();
	cardsList.layout = cardsLayout;
	cardsList.verticalScrollPolicy = cardsList.horizontalScrollPolicy = ScrollPolicy.OFF;
	cardsList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	cardsList.height = cardsLayout.typicalItemHeight*(cards.length<5?1:2);
	cardsList.itemRendererFactory = function ():IListItemRenderer { return new BuildingItemRenderer ( false, false ); };
	cardsList.layoutData = new AnchorLayoutData(padding * 19, 0, NaN, 0);
	cardsList.addEventListener(FeathersEventType.FOCUS_IN, cardsList_focusInHandler);
	cardsList.dataProvider = new ListCollection(cards);
	addChild(cardsList);
	
	var unlocksDisplay:RTLLabel = new RTLLabel(loc("arena_chance_to"), 0xCCCCCC, null, null, true, null, 0.8);
	unlocksDisplay.layoutData = new AnchorLayoutData(padding * 17, NaN, NaN, NaN, 0);
	addChild(unlocksDisplay);
	
	// rank button
	var rankButton:CustomButton = new CustomButton();
	rankButton.label = loc("ranking_label", [""]);
	rankButton.width = 320 * appModel.scale;
	rankButton.height = 110 * appModel.scale;
	rankButton.layoutData = new AnchorLayoutData(NaN, NaN, padding * (cards.length<5?3:0), NaN, 0);
	rankButton.addEventListener(Event.TRIGGERED, rankButton_triggeredHandler);
	function rankButton_triggeredHandler():void { _owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, faction); }
	addChild(rankButton);
	
	if( visible )
	{
		header.width = 0;
		factionIcon.scale = appModel.scale * 1.6 * 0.9;
		rankButton.alpha = cardsList.alpha = unlocksDisplay.alpha = unlocksDisplay.alpha = factionMeature.alpha = factionLabel.alpha = factionNumber.alpha = 0;
		Starling.juggler.tween(factionIcon, 0.3, {scale:appModel.scale*1.4, transition:Transitions.EASE_OUT_BACK});
		Starling.juggler.tween(header, 0.3, {width:this.width*0.6, transition:Transitions.EASE_OUT_BACK});
		Starling.juggler.tween(factionNumber, 0.2, {delay:0.3, alpha:1});
		Starling.juggler.tween(factionLabel, 0.2, {delay:0.4, alpha:1});
		Starling.juggler.tween(factionMeature, 0.2, {delay:0.4, alpha:1});
		Starling.juggler.tween(unlocksDisplay, 0.2, {delay:0.5, alpha:1});
		Starling.juggler.tween(cardsList, 0.2, {delay:0.5, alpha:1});
		Starling.juggler.tween(rankButton, 0.2, {delay:0.6, alpha:1});
	}
	
	if( faction.index == playerLeague )
		setTimeout(_owner.dispatchEventWith, 500, Event.OPEN);
	commited = true;
}

private function cardsList_focusInHandler(event:Event):void
{
	var type:int = BuildingItemRenderer(event.data).data as int;
	if( playerLeague < faction.index )
		return;
	var detailsPopup:CardDetailsPopup = new CardDetailsPopup();
	detailsPopup.buildingType = type;
	appModel.navigator.addPopup(detailsPopup);
}
}
}