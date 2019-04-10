package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.buttons.LeagueButton;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.others.Arena;
import feathers.controls.ImageLoader;
import feathers.controls.List;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.TiledRowsLayout;
import feathers.layout.VerticalAlign;
import flash.geom.Rectangle;
import flash.utils.setTimeout;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class LeagueItemRenderer extends AbstractListItemRenderer
{
static public var LEAGUE:int;
static public var HEIGHT:int;
static public const ICON_X:int = -400;
static public const ICON_WIDTH:int = 180;
static public const ICON_HEIGHT:int = 198;
static public const CARDS_WIDTH:int = 210;
static public const SLIDER_WIDTH:int = 48;
static private var ICON_LAYOUT_DATA:AnchorLayoutData = new AnchorLayoutData(-ICON_HEIGHT * 0.54, NaN, NaN, NaN, ICON_X);
static public const MIN_POINT_LAYOUT_DATA:AnchorLayoutData = new AnchorLayoutData(ICON_HEIGHT * 0.5, NaN, NaN, NaN, ICON_X);
static private const MIN_POINT_GRID:Rectangle = new Rectangle(39, 39, 1, 1);
private var ready:Boolean;
private var league:Arena;
private var commited:Boolean;
public function LeagueItemRenderer(){ super(); }
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	height = HEIGHT;
}

override protected function commitData():void
{
	super.commitData();
	if( index < 0 )
		return;
	
	league = _data as Arena;//trace(index, league.index , playerLeague)
	if( league.index == 0 )
		height = 500;
	
	ready = league.index > LEAGUE - 2 && league.index < LEAGUE + 3;
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
		setTimeout(createElements, 1200);
}

private function createElements():void
{
	if( commited || !ready )
		return;
	
	// icon
	var leagueIcon:LeagueButton = new LeagueButton(league.index);
	leagueIcon.layoutData = ICON_LAYOUT_DATA;
	leagueIcon.width = ICON_WIDTH;
	leagueIcon.height = ICON_HEIGHT;
	leagueIcon.pivotX = leagueIcon.width * 0.5;
	leagueIcon.pivotY = leagueIcon.height * 0.5;
	leagueIcon.touchable = false;
	addChild(leagueIcon);
	if( league.index == LEAGUE )
	{
		leagueIcon.scale = 1.2;
		Starling.juggler.tween(leagueIcon, 0.3, {scale:1});
	}
	
	// cards elements
	var cards:Array = player.availabledCards(league.index, 0);
	var cardsLayout:TiledRowsLayout = new TiledRowsLayout();
	cardsLayout.requestedColumnCount = Math.min(cards.length, 3);
	cardsLayout.requestedRowCount = Math.ceil(cards.length / 3);
	cardsLayout.horizontalAlign = HorizontalAlign.CENTER;
	cardsLayout.verticalAlign = VerticalAlign.MIDDLE;
	cardsLayout.gap = cardsLayout.padding = 12;
	cardsLayout.useVirtualLayout = false;
	cardsLayout.typicalItemWidth = Math.min(CARDS_WIDTH, 580 / cardsLayout.requestedColumnCount - cardsLayout.padding * 2 - (cardsLayout.requestedColumnCount - 1) * cardsLayout.gap);
	cardsLayout.typicalItemHeight = cardsLayout.typicalItemWidth * BuildingCard.VERICAL_SCALE;
	
	var listSkin:Image = new Image(appModel.theme.roundMediumInnerSkin);
	listSkin.scale9Grid = MainTheme.ROUND_MEDIUM_SCALE9_GRID;
	listSkin.alpha = 0.3;
	listSkin.color = 0;

	var cardsList:List = new List();
	cardsList.touchable = false;
	cardsList.layout = cardsLayout;
	cardsList.backgroundSkin = listSkin;
	//cardsList.width = cardsLayout.typicalItemWidth + cardsLayout.padding * 2;
	//cardsList.height = cardsLayout.typicalItemHeight + cardsLayout.padding * 2;
	cardsList.itemRendererFactory = function ():IListItemRenderer { return new CardItemRenderer ( false, false ); };
	cardsList.layoutData = new AnchorLayoutData(NaN, NaN, NaN, stageWidth * 0.5 + ICON_LAYOUT_DATA.horizontalCenter + 180, NaN, -HEIGHT * 0.5);
	cardsList.dataProvider = new ListCollection(cards);
	addChild(cardsList);

	var arrowSkin:ImageLoader = new ImageLoader();
	arrowSkin.source = appModel.theme.calloutLeftArrowSkinTexture;
	arrowSkin.layoutData = new AnchorLayoutData(NaN, -0.1, NaN, NaN, NaN, -HEIGHT * 0.5);
	AnchorLayoutData(arrowSkin.layoutData).rightAnchorDisplayObject = cardsList;
	arrowSkin.alpha = listSkin.alpha;
	arrowSkin.color = listSkin.color;
	addChild(arrowSkin);
	
	
	if( league.index <= 0 )
	{
		if( league.index == 0 )
		{
			AnchorLayoutData(arrowSkin.layoutData).verticalCenter = -280;
			AnchorLayoutData(cardsList.layoutData).verticalCenter = -140;
		}
		commited = true;
		return;
	}
	
	// progress bar
	var l:Arena = game.arenas.get(LEAGUE);
	if( LEAGUE + 1 >= league.index )
	{
		var fillHeight:Number = HEIGHT * (l.max  - player.get_point()) / (l.max - l.min);
		var sliderFill:ImageLoader = new ImageLoader();
		sliderFill.layoutData = new AnchorLayoutData(LEAGUE + 1 > league.index ? 0 : fillHeight, NaN, 0, NaN, ICON_LAYOUT_DATA.horizontalCenter);
		sliderFill.source = Assets.getTexture("leagues/slider-fill", "gui");
		sliderFill.scale9Grid = MainTheme.SMALL_BACKGROUND_SCALE9_GRID;
		sliderFill.width = SLIDER_WIDTH;
		addChildAt(sliderFill, 0);
		
		if( LEAGUE + 1 == league.index )
		{
			var pointLine:ImageLoader = new ImageLoader();
			pointLine.source = appModel.theme.quadSkin;
			pointLine.scale9Grid = MainTheme.QUAD_SCALE9_GRID;
			pointLine.width = 640;
			pointLine.height = 4;
			pointLine.layoutData = new AnchorLayoutData(fillHeight - pointLine.height * 0.5, NaN, NaN, stageWidth * 0.5 + ICON_LAYOUT_DATA.horizontalCenter - SLIDER_WIDTH);
			addChild(pointLine);
			
			var pointRect:ImageLoader = new ImageLoader();
			pointRect.source = Assets.getTexture("leagues/point-rect", "gui");
			pointRect.width = 260;
			pointRect.height = 72;
			pointRect.scale9Grid = new Rectangle(17, 17, 2, 2);
			pointRect.layoutData = new AnchorLayoutData(fillHeight - pointRect.height * 0.5, 40);
			addChild(pointRect);
			
			var pointIcon:ImageLoader = new ImageLoader();
			pointIcon.source = Assets.getTexture("res-2", "gui");
			pointIcon.width = pointIcon.height = 52;
			pointIcon.layoutData = new AnchorLayoutData(fillHeight - pointIcon.height * 0.5, pointRect.width - 30);
			addChild(pointIcon);
		}
	}
	if( LEAGUE + 1 <= league.index )
	{
		var sliderBackground:ImageLoader = new ImageLoader();
		sliderBackground.source = Assets.getTexture("leagues/slider-background", "gui");
		sliderBackground.layoutData = new AnchorLayoutData(0, NaN, 0, NaN, ICON_LAYOUT_DATA.horizontalCenter);
		sliderBackground.scale9Grid = MainTheme.SMALL_BACKGROUND_SCALE9_GRID;
		sliderBackground.width = SLIDER_WIDTH;
		addChildAt(sliderBackground, 0);
	}
	
	var minPointRect:ImageLoader = new ImageLoader();
	minPointRect.source = Assets.getTexture("leagues/min-point-rect", "gui");
	minPointRect.layoutData = MIN_POINT_LAYOUT_DATA;
	minPointRect.scale9Grid = MIN_POINT_GRID;
	minPointRect.width = 190;
	minPointRect.height = 68;
	addChild(minPointRect);
	
	if( LEAGUE + 1 == league.index )
	{
		var pointLabel:RTLLabel = new RTLLabel(StrUtils.getNumber(player.get_point()), 1, "center", null, false, null, 0.8);
		pointLabel.layoutData = new AnchorLayoutData(fillHeight - pointRect.height * 0.5, 50);
		pointLabel.width = pointRect.width - 70;
		pointLabel.height = 72;
		addChild(pointLabel);
	}

	var minPointLabel:RTLLabel = new RTLLabel(StrUtils.getNumber((league.min - 1) + "+"), 1, "center", null, false, null, 0.8);
	minPointLabel.layoutData = MIN_POINT_LAYOUT_DATA;
	addChild(minPointLabel);

	
	/*var leagueNumber:RTLLabel = new RTLLabel(loc("arena_text") + " " + loc("num_" + (league.index + 1)) , 0xDDEEFF, null, null, false, null, 0.9);
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
	unlocksDisplay.layoutData = new AnchorLayoutData(111, NaN, NaN, NaN, 0);
	addChild(unlocksDisplay);
	if( visible )
	{
		//header.width = 0;
		leagueIcon.scale = 1.6 * 0.9;
		//cardsDisplay.alpha = unlocksDisplay.alpha = unlocksDisplay.alpha = leagueMeature.alpha = leagueLabel.alpha = leagueNumber.alpha = 0;
		Starling.juggler.tween(leagueIcon, 0.3, {scale:1, transition:Transitions.EASE_OUT_BACK});
		//Starling.juggler.tween(header, 0.5, {width:this.width * 0.6, transition:Transitions.EASE_OUT_BACK});
		//Starling.juggler.tween(leagueNumber, 0.2, {delay:0.3, alpha:1});
		//Starling.juggler.tween(leagueLabel, 0.2, {delay:0.4, alpha:1});
		//Starling.juggler.tween(leagueMeature, 0.2, {delay:0.4, alpha:1});
		Starling.juggler.tween(unlocksDisplay, 0.2, {delay:0.5, alpha:1});
		Starling.juggler.tween(cardsList, 0.2, {delay:0.5, alpha:1});
	}*/
	if( league.index == LEAGUE )
		setTimeout(_owner.dispatchEventWith, 500, Event.OPEN);
	commited = true;
}
}
}