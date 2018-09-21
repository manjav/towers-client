package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.groups.Devider;
import com.gerantech.towercraft.controls.screens.FactionsScreen;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gt.towers.others.Arena;
import dragonBones.starling.StarlingArmatureDisplay;
import feathers.controls.LayoutGroup;
import feathers.controls.List;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalLayout;
import feathers.layout.TiledRowsLayout;
import feathers.layout.VerticalAlign;
import flash.geom.Rectangle;
import flash.utils.setTimeout;
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

public function FactionItemRenderer(){	super(); }
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	height = _height;
	padding = 48;
	var iconSize:int = 400;
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
		var divider:Devider = new Devider(0, 5);
		divider.layoutData = new AnchorLayoutData(0, padding, NaN, padding);
		addChild(divider);
	}
	// header elements
	var header:LayoutGroup = new LayoutGroup();
	header.layout = new AnchorLayout();
	var ribbon:Image = new Image(Assets.getTexture("ribbon-blue", "gui"));
	header.layoutData = new AnchorLayoutData(padding * 3, NaN, NaN, NaN, 0);
	ribbon.scale9Grid = MainTheme.RIBBON_SCALE9_GRID;
	header.backgroundSkin = ribbon;
	header.width = width * 0.6;
	header.height = 160;
	addChild(header);
	
	var factionNumber:RTLLabel = new RTLLabel(loc("arena_text") + " " + loc("num_" + (faction.index + 1)) , 0xCCDDFF, null, null, false, null, 0.9);
	factionNumber.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -padding * 1.8); 
	factionNumber.pixelSnapping = false;
	header.addChild(factionNumber);
	
	var factionLabel:ShadowLabel = new ShadowLabel(loc("arena_title_" + faction.index), 1, 0, null, null, false, null, 1.2);
	factionLabel.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -padding * 0.4); 
	header.addChild(factionLabel);
	
	var factionMeature:RTLLabel = new RTLLabel((faction.min - (faction.min == 0?0:1)) + "+" , 0xAABBCC, null, null, false, null, 0.9);
	factionMeature.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, padding); 
	factionMeature.pixelSnapping = false;
	header.addChild(factionMeature);
	
	// icon 
	var factionIcon:StarlingArmatureDisplay = FactionsScreen.factory.buildArmatureDisplay("arena-" + Math.min(8, faction.index));
	factionIcon.x = width * 0.5;
	factionIcon.y = padding * 12;
	factionIcon.scale = 1.4;
	if( playerLeague >= faction.index )
		factionIcon.animation.gotoAndPlayByTime("selected", 0, 50);
	else
	{
		factionIcon.animation.gotoAndStopByTime("normal", 0);
		factionIcon.alpha = 0.7
	}
	addChild(factionIcon);
	
	// cards elements
	var cardsLayout:TiledRowsLayout = new TiledRowsLayout();
	cardsLayout.requestedColumnCount = 4;
	cardsLayout.useVirtualLayout = false;
	cardsLayout.gap = padding;
	cardsLayout.typicalItemWidth = stageWidth / cardsLayout.requestedColumnCount - cardsLayout.gap * 2;
	cardsLayout.typicalItemHeight = cardsLayout.typicalItemWidth * BuildingCard.VERICAL_SCALE;
	cardsLayout.horizontalAlign = "center";
	cardsLayout.verticalAlign = VerticalAlign.JUSTIFY;
	
	var cardsDisplay:List = new List();
	cardsDisplay.touchable = false;
	cardsDisplay.layout = cardsLayout;
	cardsDisplay.height = cardsLayout.typicalItemHeight * 2 + cardsLayout.gap;
	cardsDisplay.itemRendererFactory = function ():IListItemRenderer { return new CardItemRenderer ( false, false ); };
	cardsDisplay.layoutData = new AnchorLayoutData(padding * 19, 0, NaN, 0);trace(player.availabledCards(faction.index, true)._list)
	cardsDisplay.dataProvider = new ListCollection(player.availabledCards(faction.index, true)._list);
	addChild(cardsDisplay);
	
	var unlocksDisplay:RTLLabel = new RTLLabel(loc("arena_chance_to"), 0xCCCCCC, null, null, true, null, 0.8);
	unlocksDisplay.layoutData = new AnchorLayoutData(padding * 17, NaN, NaN, NaN, 0);
	addChild(unlocksDisplay);
	
	if( visible )
	{
		header.width = 0;
		factionIcon.scale = 1.6 * 0.9;
		cardsDisplay.alpha = unlocksDisplay.alpha = unlocksDisplay.alpha = factionMeature.alpha = factionLabel.alpha = factionNumber.alpha = 0;
		Starling.juggler.tween(factionIcon, 0.3, {scale:1.4, transition:Transitions.EASE_OUT_BACK});
		Starling.juggler.tween(header, 0.5, {width:this.width * 0.6, transition:Transitions.EASE_OUT_BACK});
		Starling.juggler.tween(factionNumber, 0.2, {delay:0.3, alpha:1});
		Starling.juggler.tween(factionLabel, 0.2, {delay:0.4, alpha:1});
		Starling.juggler.tween(factionMeature, 0.2, {delay:0.4, alpha:1});
		Starling.juggler.tween(unlocksDisplay, 0.2, {delay:0.5, alpha:1});
		Starling.juggler.tween(cardsDisplay, 0.2, {delay:0.5, alpha:1});
	}
	if( faction.index == playerLeague )
		setTimeout(_owner.dispatchEventWith, 500, Event.OPEN);
	commited = true;
}
}
}