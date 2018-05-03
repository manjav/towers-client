package com.gerantech.towercraft.views
{
import com.gerantech.towercraft.managers.TutorialManager;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.views.decorators.BarracksDecorator;
import com.gerantech.towercraft.views.decorators.BuildingDecorator;
import com.gerantech.towercraft.views.decorators.TeslaDecorator;
import com.gerantech.towercraft.views.decorators.TutorialDecorator;
import com.gerantech.towercraft.views.weapons.DefensiveWeapon;
import com.gt.towers.Game;
import com.gt.towers.Player;
import com.gt.towers.battle.fieldes.PlaceData;
import com.gt.towers.buildings.Place;
import com.gt.towers.constants.BuildingType;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.constants.TroopType;
import com.gt.towers.utils.PathFinder;
import com.gt.towers.utils.lists.PlaceList;
import flash.geom.Rectangle;
import flash.utils.clearInterval;
import flash.utils.setInterval;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.events.Event;
import starling.utils.MathUtil;

public class PlaceView extends Sprite
{
public var place:Place;
public var raduis:Number;
public var arrowContainer:Sprite;
public var decorator:BuildingDecorator;
public var defensiveWeapon:DefensiveWeapon;
private var tutors:TutorialDecorator;

private var troopsCount:int = 0;
private var rushIntervalId:int = -1;
private var rushGap:int = 0;
private var arrow:MovieClip;
private var _selectable:Boolean;

private var path:PlaceList;
private var dropZone:Image;
private var zoneAppear:Boolean;
private var arenaIndex:int;

public function PlaceView(place:Place)
{
	this.place = place;
	this.arenaIndex = player.get_arena(0)
    this.raduis = Math.max(160, 200 - arenaIndex * 6);
	
	var bg:Image = new Image(Assets.getTexture("damage-range"));
	bg.alignPivot();
	bg.width = raduis * 2;
	bg.y = -raduis * 0.1;
	bg.scaleY = bg.scaleX * 0.8;
	bg.alpha = 0;
	addChild(bg);
	
	dropZone = new Image(Assets.getTexture("damage-range"));
	dropZone.touchable = false;
	dropZone.alignPivot();
	dropZone.scaleY = dropZone.scaleX = 0;
	dropZone.alpha = 0;
	dropZone.visible = false;
	addChild(dropZone);
	
	x = place.x;
	y = place.y;

	place.building._population = place.building.get_population();
	place.building.troopSpeed = 30000 / place.building.troopSpeed;
	createDecorator();
	createArrow();
	createTutors();
}

private function createDecorator():void
{
	if( defensiveWeapon != null )
		defensiveWeapon.dispose();
	defensiveWeapon = null;
	
	if( decorator != null )
		decorator.dispose(); 
	decorator = null;
	
	switch( place.building.category )
	{
		case BuildingType.B40_CRYSTAL:
			decorator = new TeslaDecorator(this);
			defensiveWeapon = new DefensiveWeapon(this);
			break;
		case BuildingType.B10_BARRACKS:
			decorator = new BarracksDecorator(this);
			break;
		default:
			decorator = new BuildingDecorator(this);
			break;
	}
}

public function createArrow():void
{
	arrowContainer = new Sprite();
	arrowContainer.visible = arrowContainer.touchable = false;
	addChildAt(arrowContainer, 0);
	
	arrow = new MovieClip(Assets.getTextures("attack-line-"), 50);
	arrow.touchable = false;
	arrow.width = 64;
	arrow.tileGrid = new Rectangle(0, 0, arrow.width, arrow.width);
	arrow.alignPivot("center", "bottom");
	arrowContainer.addChild(arrow);
	Starling.juggler.add(arrow);
}
public function arrowTo(disX:Number, disY:Number):void
{
	arrow.height = Math.sqrt(Math.pow(disX, 2) + Math.pow(disY, 2));
	arrowContainer.rotation = MathUtil.normalizeAngle( -Math.atan2( -disX, -disY) );
}

// tutorial decorator
private function createTutors() : void 
{
	if( player.get_arena(0) > 0 || tutors != null )
		return;
	tutors = new TutorialDecorator(this);
}

// hilight for tutorial
public function hilight(appear:Boolean):void
{
	if( zoneAppear == appear || arenaIndex > 0 )
		return;
	zoneAppear = appear;
	
	if( zoneAppear )
	{
		dropZone.visible = true;
		Starling.juggler.tween(dropZone, 0.6, {alpha:0.9, scaleX:1.7, scaleY:1.2, transition:Transitions.EASE_OUT_BACK});
	}
	else
	{
		Starling.juggler.tween(dropZone, 0.6, {alpha:0.0, scaleX:1.0, scaleY:1.0, transition:Transitions.EASE_IN_BACK, onComplete:function():void{dropZone.visible = false; }});
	}
}

public function update(population:int, troopType:int) : void
{
	showMidSwipesTutorial(troopType);
	var occupied:Boolean = place.building.troopType != troopType;
	
	place.building._population = population;
	place.building.troopType = troopType;
	if( hasEventListener(Event.UPDATE) )
		dispatchEventWith(Event.UPDATE, false, [population, troopType, occupied]);
}

private function showMidSwipesTutorial(troopType : int) : void
{
	if( !player.inTutorial() )
		return;
	if( place.building.troopType == player.troopType || troopType != player.troopType )
		return;
	if( appModel.battleFieldView.battleData.map.isQuest && appModel.battleFieldView.battleData.map.index == 2 && player.emptyDeck() )
		return;
	tutorials.removeAll();
	if( place.index > appModel.battleFieldView.battleData.map.places.size() - 2 )
		return;
	
	tutorials.showMidSwipe(this);
	if( player.getTutorStep() == PrefsTypes.T_123_QUEST_0_FIRST_SWIPE )
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_124_QUEST_0_FIRST_CAPTURE); // set first capture tutor step
}

public function getData(index:int):PlaceData
{
	var p:PlaceData = appModel.battleFieldView.battleData.map.places.get(index);
	return new PlaceData(p.index, p.x, p.y, p.type, player.troopType, "", true, p.index);
}


public function fight(destination:Place, troopsCount:Number) : void
{
	path = PathFinder.find(place, destination, appModel.battleFieldView.battleData.battleField.getPlacesByTroopType(TroopType.NONE));
	if( path == null || destination.building == place.building )
		return;
	
	if( rushGap != place.building.troopRushGap )
	{
		rushGap = place.building.troopRushGap * 1.2;
		clearInterval(rushIntervalId);
		rushIntervalId = setInterval(rushTimeoutCallback, rushGap);
	}
	this.troopsCount = place.building.get_population() * troopsCount;
	
	if( place.building.troopType == player.troopType )
	{
		var soundIndex:int = 0;
		if( troopsCount > 5 && troopsCount < 10 )
			soundIndex = 1;
		else if( troopsCount >= 10 && troopsCount < 20 )
			soundIndex = 2;
		else if( troopsCount >= 20 )
			soundIndex = 3;
		
		if( !appModel.sounds.soundIsPlaying("battle-go-army-"+soundIndex) )
			appModel.sounds.addAndPlaySound("battle-go-army-"+soundIndex);
	}
}

private function rushTimeoutCallback():void
{
	if( troopsCount > 0 && path != null )
	{
		var t:TroopView = new TroopView(place.building, path);
		t.x = x;
		t.y = y;
		t.rush(place);
		if( path.get(0).y > y )
			appModel.battleFieldView.troopsContainer.addChildAt(t, 0);
		else
			appModel.battleFieldView.troopsContainer.addChild(t);
		troopsCount --;
	}
}


public function replaceBuilding(type:int, level:int, troopType:int, population:int):void
{
	rushGap = 0;
	//trace("replaceBuilding", place.index, type, level, place.building._population);
	place.building.type = type;
	place.building.set_level( level );
	place.building.setFeatures();
	place.building.troopSpeed = 30000 / place.building.troopSpeed;
	createDecorator();
	update(population, troopType);
}

override public function dispose():void
{
	Starling.juggler.remove(arrow);
	clearInterval(rushIntervalId);
	if( defensiveWeapon != null )
		defensiveWeapon.dispose();
	if( decorator != null )
		decorator.dispose();
	super.dispose();
}

protected function get tutorials():		TutorialManager	{	return TutorialManager.instance;	}
protected function get appModel():		AppModel		{	return AppModel.instance;			}
protected function get game():			Game			{	return appModel.game;				}
protected function get player():		Player			{	return game.player;					}
}
}