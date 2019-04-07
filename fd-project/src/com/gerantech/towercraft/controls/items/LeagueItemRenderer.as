package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.buttons.LeagueButton;
import com.gerantech.towercraft.controls.groups.Devider;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.others.Arena;
import com.gt.towers.scripts.ScriptEngine;
import feathers.controls.LayoutGroup;
import feathers.controls.List;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.TiledRowsLayout;
import feathers.layout.VerticalAlign;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class LeagueItemRenderer extends AbstractListItemRenderer
{
public static var _height:Number;
private var ready:Boolean;
public static var playerLeague:int;
private var league:Arena;
private var padding:int;
private var commited:Boolean;

public function LeagueItemRenderer(){ super(); }
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
	
	league = _data as Arena;//trace(index, league.index , playerLeague)
	ready = league.index == playerLeague;
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
		var divider:Devider = new Devider(0, 2);
		divider.layoutData = new AnchorLayoutData(0, padding, NaN, padding);
		addChild(divider);
	}
	// header elements
	var header:LayoutGroup = new LayoutGroup();
	header.layout = new AnchorLayout();
	var ribbon:Image = new Image(Assets.getTexture("ribbon-blue"));
	header.layoutData = new AnchorLayoutData(padding * 3, NaN, NaN, NaN, 0);
	ribbon.scale9Grid = MainTheme.RIBBON_SCALE9_GRID;
	header.backgroundSkin = ribbon;
	header.width = width * 0.6;
	header.height = 160;
	addChild(header);
	
	// icon 
	var leagueIcon:LeagueButton = new LeagueButton(league.index);
	leagueIcon.width = 300;
	leagueIcon.height = 330;
	leagueIcon.pivotX = leagueIcon.width * 0.5;
	leagueIcon.pivotY = leagueIcon.height * 0.5;
	leagueIcon.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -180);
	leagueIcon.touchable = false;
	if( playerLeague < league.index )
		leagueIcon.alpha = 0.7
	addChild(leagueIcon);
	
	// cards elements
	var cardsLayout:TiledRowsLayout = new TiledRowsLayout();
	cardsLayout.requestedColumnCount = 4;
	cardsLayout.useVirtualLayout = false;
	cardsLayout.gap = padding;
	cardsLayout.typicalItemWidth = stageWidth / cardsLayout.requestedColumnCount - cardsLayout.gap ;
	cardsLayout.typicalItemHeight = cardsLayout.typicalItemWidth * BuildingCard.VERICAL_SCALE;
	cardsLayout.horizontalAlign = "center";
	cardsLayout.verticalAlign = VerticalAlign.JUSTIFY;
	
	var cardsDisplay:List = new List();
	cardsDisplay.touchable = false;
	cardsDisplay.layout = cardsLayout;
	cardsDisplay.height = cardsLayout.typicalItemHeight * 2 + cardsLayout.gap;
	cardsDisplay.itemRendererFactory = function ():IListItemRenderer { return new CardItemRenderer ( false, false ); };
	cardsDisplay.layoutData = new AnchorLayoutData(padding * 19, 0, NaN, 0);
	cardsDisplay.dataProvider = new ListCollection(player.availabledCards(league.index, 0));
	addChild(cardsDisplay);
	
	var leagueNumber:RTLLabel = new RTLLabel(loc("arena_text") + " " + loc("num_" + (league.index + 1)) , 0xDDEEFF, null, null, false, null, 0.9);
	leagueNumber.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -padding * 1.8); 
	leagueNumber.pixelSnapping = false;
	header.addChild(leagueNumber);
	
	var leagueLabel:ShadowLabel = new ShadowLabel(loc("arena_title_" + league.index), 1, 0, null, null, false, null, 1.1);
	leagueLabel.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -padding * 0.4); 
	header.addChild(leagueLabel);
	
	var leagueMeature:RTLLabel = new RTLLabel(StrUtils.getNumber(league.min - (league.min == 0?0:1)) + "+" , 0xDDEEFF, null, null, false, null, 1.2);
	leagueMeature.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, padding); 
	leagueMeature.pixelSnapping = false;
	header.addChild(leagueMeature);

	var unlocksDisplay:RTLLabel = new RTLLabel(loc("arena_chance_to"), 0xDDEEFF, null, null, true, null, 0.8);
	unlocksDisplay.layoutData = new AnchorLayoutData(padding * 17, NaN, NaN, NaN, 0);
	addChild(unlocksDisplay);
	if( visible )
	{
		header.width = 0;
		leagueIcon.scale = 1.6 * 0.9;
		cardsDisplay.alpha = unlocksDisplay.alpha = unlocksDisplay.alpha = leagueMeature.alpha = leagueLabel.alpha = leagueNumber.alpha = 0;
		Starling.juggler.tween(leagueIcon, 0.3, {scale:1, transition:Transitions.EASE_OUT_BACK});
		Starling.juggler.tween(header, 0.5, {width:this.width * 0.6, transition:Transitions.EASE_OUT_BACK});
		Starling.juggler.tween(leagueNumber, 0.2, {delay:0.3, alpha:1});
		Starling.juggler.tween(leagueLabel, 0.2, {delay:0.4, alpha:1});
		Starling.juggler.tween(leagueMeature, 0.2, {delay:0.4, alpha:1});
		Starling.juggler.tween(unlocksDisplay, 0.2, {delay:0.5, alpha:1});
		Starling.juggler.tween(cardsDisplay, 0.2, {delay:0.5, alpha:1});
	}
	if( league.index == playerLeague )
		setTimeout(_owner.dispatchEventWith, 500, Event.OPEN);
	commited = true;
}
}
}