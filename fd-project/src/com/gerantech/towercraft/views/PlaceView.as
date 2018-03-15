package com.gerantech.towercraft.views
{
import com.gerantech.towercraft.managers.TutorialManager;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.views.decorators.BarracksDecorator;
import com.gerantech.towercraft.views.decorators.BuildingDecorator;
import com.gerantech.towercraft.views.decorators.CrystalDecorator;
import com.gerantech.towercraft.views.weapons.DefensiveWeapon;
import com.gt.towers.Game;
import com.gt.towers.Player;
import com.gt.towers.battle.fieldes.PlaceData;
import com.gt.towers.buildings.Place;
import com.gt.towers.constants.BuildingType;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.constants.TroopType;
import com.gt.towers.utils.PathFinder;
import com.gt.towers.utils.lists.PlaceDataList;
import com.gt.towers.utils.lists.PlaceList;

import flash.geom.Rectangle;
import flash.utils.clearInterval;
import flash.utils.clearTimeout;
import flash.utils.setInterval;
import flash.utils.setTimeout;

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

private var troopsCount:int = 0;
private var rushIntervalId:int = -1;
private var rushGap:int = 0;
private var arrow:MovieClip;
private var _selectable:Boolean;
private var wishedPopulation:int;

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
	bg.scaleY = bg.scaleX;
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

	createDecorator();
	createArrow();
	place.building.createEngine(place.building.troopType);
	place.building._population = wishedPopulation = place.building.get_population();
}

private function createDecorator():void
{
	if( defensiveWeapon != null )
		defensiveWeapon.dispose();
	defensiveWeapon = null;
	
	if( decorator != null )
		decorator.removeFromParent(true); 
	
	switch( place.building.category )
	{
		case BuildingType.B40_CRYSTAL:
			decorator = new CrystalDecorator(this);
			defensiveWeapon = new DefensiveWeapon(this);
			break;
		case BuildingType.B10_BARRACKS:
			decorator = new BarracksDecorator(this);
			break;
		default:
			decorator = new BuildingDecorator(this);
			break;
	}
	decorator.x = 0;
	decorator.y = 0;
	addChild(decorator);
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
	arrowContainer.rotation = MathUtil.normalizeAngle(-Math.atan2(-disX, -disY));//trace(tp.arrow.scaleX, tp.arrow.scaleY, tp.arrow.height)
}
public function hilight(appear:Boolean):void
{
	if( zoneAppear == appear || arenaIndex > 0 )
		return;
	zoneAppear = appear;
	
	if( zoneAppear )
	{
		dropZone.visible = true;
		Starling.juggler.tween(dropZone, 0.6, {alpha:0.9, scaleX:2.0, scaleY:1.6, transition:Transitions.EASE_OUT_BACK});
	}
	else
	{
		Starling.juggler.tween(dropZone, 0.6, {alpha:0.0, scaleX:1.0, scaleY:1.0, transition:Transitions.EASE_IN_BACK, onComplete:function():void{dropZone.visible = false;}});
	}
}

public function get selectable():Boolean
{
	return _selectable;
}
public function set selectable(value:Boolean):void
{
	touchable = value;
	_selectable = value;
}

public function update(population:int, troopType:int) : void
{
	showMidSwipesTutorial(troopType);
	decorator.updateElements(population, troopType);
	if( population < wishedPopulation )
		decorator.showUnderAttack();

	if( population == place.building._population + 1 || population == place.building._population + 2 || wishedPopulation == 0)
		wishedPopulation = population;
	place.building._population = population;
	place.building.troopType = troopType;
	
	if(hasEventListener(Event.UPDATE))
		dispatchEventWith(Event.UPDATE, false);
}

private function showMidSwipesTutorial(troopType:int):void
{
	if( !appModel.battleFieldView.battleData.map.isQuest || appModel.battleFieldView.battleData.map.index > 2 )
		return;
	if( place.building.troopType == player.troopType || troopType != player.troopType )
		return;
	if( place.index > appModel.battleFieldView.battleData.map.places.size()-2 )
		return;
	if( appModel.battleFieldView.battleData.map.index == 2 && player.isHardMode() )
		return;
	if( !appModel.battleFieldView.responseSender.actived )
		return;

	// set first capture tutor step
	if( player.getTutorStep() == PrefsTypes.T_123_QUEST_0_FIRST_SWIPE )
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_124_QUEST_0_FIRST_CAPTURE);

	tutorials.removeAll();
	
	var tutorialData:TutorialData = new TutorialData("occupy_" + appModel.battleFieldView.battleData.map.index + "_" + place.index);
	var places:PlaceDataList = new PlaceDataList();
	if( appModel.battleFieldView.battleData.map.index <= 2 )
	{
		for (var i:int = 0; i < place.index+2; i++) 
			places.push(getPlace(i));
	}
	else
	{
		places.push(getPlace(place.index));
		places.push(getPlace(place.index + 1));
	}
	
	if( places.size() > 0 )
		tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_SWIPE, null, places, 0, 800 * places.size()));
	tutorials.show(tutorialData);
}

private function getPlace(index:int):PlaceData
{
	var p:PlaceData = appModel.battleFieldView.battleData.map.places.get(index);
	return new PlaceData(p.index, p.x, p.y, p.type, player.troopType, "", true, p.index);
}

public function fight(destination:Place, troopsCount:Number) : void
{
	wishedPopulation = Math.floor(place.building._population * 0.5);
	path = PathFinder.find(place, destination, appModel.battleFieldView.battleData.battleField.getPlacesByTroopType(TroopType.NONE));
	if( path == null || destination.building == place.building )
		return;
	
	if( rushGap != place.building.get_exitGap() )
	{
		rushGap = place.building.get_exitGap();
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
		t.y = y ;
		t.rush(place);
		appModel.battleFieldView.troopsContainer.addChild(t);
		troopsCount --;
	}
}

public function replaceBuilding(type:int, level:int):void
{
	wishedPopulation = Math.floor(place.building._population * 0.5);
	rushGap = 0;
	var tt:int = place.building.troopType;
	var p:int = place.building._population;
	//trace("replaceBuilding", place.index, type, level, place.building._population);
	place.building = BuildingType.instantiate(game ,type, place, place.index);
	place.building.set_level( level );
	createDecorator();
	if( type == BuildingType.B01_CAMP )
		update(p,tt);
}

override public function dispose():void
{
	Starling.juggler.remove(arrow);
	clearInterval(rushIntervalId);
	if(defensiveWeapon != null)
		defensiveWeapon.dispose();
	super.dispose();
}

protected function get tutorials():		TutorialManager	{	return TutorialManager.instance;	}
protected function get appModel():		AppModel		{	return AppModel.instance;			}
protected function get game():			Game			{	return appModel.game;				}
protected function get player():		Player			{	return game.player;					}
}
}