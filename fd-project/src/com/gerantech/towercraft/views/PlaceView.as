package com.gerantech.towercraft.views
{
import com.gerantech.towercraft.controls.items.TimerIcon;
import com.gerantech.towercraft.managers.TutorialManager;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.views.decorators.BuildingDecorator;
import com.gerantech.towercraft.views.decorators.CardDecorator;
import com.gerantech.towercraft.views.decorators.CrystalDecorator;
import com.gerantech.towercraft.views.weapons.DefensiveWeapon;
import com.gt.towers.Game;
import com.gt.towers.Player;
import com.gt.towers.battle.fieldes.PlaceData;
import com.gt.towers.buildings.Building;
import com.gt.towers.buildings.Place;
import com.gt.towers.constants.CardTypes;
import com.gt.towers.constants.TroopType;
import com.gt.towers.utils.PathFinder;
import com.gt.towers.utils.lists.PlaceDataList;
import com.gt.towers.utils.lists.PlaceList;

import flash.geom.Rectangle;
import flash.utils.clearTimeout;
import flash.utils.setInterval;
import flash.utils.setTimeout;

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
private var timerIcon:TimerIcon;
private var decorator:BuildingDecorator;
private var defensiveWeapon:DefensiveWeapon;

private var arrow:MovieClip;
private var rushTimeoutId:uint;
private var _selectable:Boolean;
private var elixirCollector:ElixirCollector;

public function PlaceView(place:Place)
{
	this.place = place;
	this.raduis = 160;
	
	var bg:Image = new Image(Assets.getTexture("damage-range"));
	bg.alignPivot();
	bg.width = raduis * 2;
	bg.scaleY = bg.scaleX * 0.8;
	bg.alpha = 0//.2;
	addChild(bg);
	
	x = place.x;
	y = place.y;

	createDecorator();
	createArrow();
	place.building.reset(place.building.troopType);
	place.building._health = place.building.get_health();
	place.building._population = place.building.get_population();
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
		case CardTypes.C500:
			defensiveWeapon = new DefensiveWeapon(this);
			decorator = new CrystalDecorator(this);
			break;

		default:
			decorator = new CardDecorator(this);
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
	arrowContainer.rotation = MathUtil.normalizeAngle(-Math.atan2(-disX, -disY));//trace(tp.arrow.scaleX, tp.arrow.scaleY, tp.arrow.height)
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

public function update(population:int, troopType:int, health:int) : void
{
	showMidSwipesTutorial(troopType);
	decorator.updateTroops(population, troopType, health);
	if( place.building._health > health )
		decorator.showUnderAttack();

	//if( population == place.building._population + 1 || population == place.building._population + 2 || wishedPopulation == 0)
	//	wishedPopulation = population;
	place.building._population = population;
	place.building._health = health;
	if( place.building.troopType != troopType )
	{
		place.building.troopType = troopType;
		
		if( player.troopType == troopType )
		{
			elixirCollector = new ElixirCollector(place);
		}
		else if( elixirCollector != null )
		{
			elixirCollector.dispose();
			elixirCollector = null;
		}
	}
	
	if( hasEventListener(Event.UPDATE) )
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
	if( !appModel.battleFieldView.responseSender.actived )
		return;

	tutorials.removeAll();
	
	var tutorialData:TutorialData = new TutorialData("occupy_" + appModel.battleFieldView.battleData.map.index + "_" + place.index);
	var places:PlaceDataList = new PlaceDataList();
	if( appModel.battleFieldView.battleData.map.index == 1 )
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
	tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_SWIPE, null, places, 0, 1700 * places.size()));
	tutorials.show(tutorialData);
}

private function getPlace(index:int):PlaceData
{
	var p:PlaceData = appModel.battleFieldView.battleData.map.places.get(index);
	return new PlaceData(p.index, p.x, p.y, p.type, player.troopType, "", true, p.index);
}

public function fight(destination:Place) : void
{
	var path:PlaceList = PathFinder.find(place, destination, appModel.battleFieldView.battleData.battleField.getPlacesByTroopType(TroopType.NONE));
	if( path == null || destination.building == place.building )
		return;
	
	var len:int = place.building.get_population() ;
	for(var i:uint=0; i<len; i++)
	{
		var t:TroopView = new TroopView(place.building, path);
		t.x = x;
		t.y = y ;
		appModel.battleFieldView.troopsContainer.addChild(t);
		rushTimeoutId = setTimeout(t.rush, place.building.troopRushGap * i + 300, place);
	}
	
	if ( place.building.troopType == player.troopType )
	{
		var soundIndex:int = 0;
		if( len > 5 && len < 10 )
			soundIndex = 1;
		else if ( len >= 10 && len < 20 )
			soundIndex = 2;
		else if ( len >= 20 )
			soundIndex = 3;
		
		if( !appModel.sounds.soundIsPlaying("battle-go-army-"+soundIndex) )
			appModel.sounds.addAndPlaySound("battle-go-army-"+soundIndex);
	}
}

public function showDeployWaiting(card:Building):void
{
	if( timerIcon == null )
	{
		timerIcon = new TimerIcon();
		timerIcon.stop();
		timerIcon.x = x;
		timerIcon.y = y - 80;
	}
	appModel.battleFieldView.guiImagesContainer.addChild(timerIcon);
	setTimeout(timerIcon.punch, 100);
	var delay:Number = card.deployTime + 0.1;
	timerIcon.rotateTo(0, 360, delay);
	setTimeout(timerIcon.punch, delay*1000);
	setTimeout(timerIcon.removeFromParent, card.deployTime*1000+50);
}

public function replaceBuilding(type:int, level:int, improveLevel:int):void
{
	/*wishedPopulation = Math.floor(place.building._population/2);
	var tt:int = place.building.troopType;
	var p:int = place.building._population;
	//trace("replaceBuilding", place.index, type, level, place.building._population);
	place.building = BuildingType.instantiate(game ,type, place, place.index);
	place.building.set_level( level );
	createDecorator();
	if( type == BuildingType.B01_CAMP )
		update(p,tt);*/
	
	var _oldcate:int = place.building.category;
	var _newcate:int = CardTypes.get_category(type);
	
	place.building.set_level(level);
	place.building._health = place.health;
	//place.building.improveLevel = improveLevel;
	place.building.type = type;
	place.building.setFeatures();
	decorator.updateBuilding();
	if( ( _newcate == CardTypes.C500 || _oldcate == CardTypes.C500 ) && _newcate != _oldcate )
		createDecorator();
}

override public function dispose():void
{
	Starling.juggler.remove(arrow);
	clearTimeout(rushTimeoutId);
	
	if( decorator != null )
		decorator.dispose();
	if( defensiveWeapon != null )
		defensiveWeapon.dispose();
	if( elixirCollector != null )
		elixirCollector.dispose();
	super.dispose();
}

protected function get tutorials():		TutorialManager	{	return TutorialManager.instance;	}
protected function get appModel():		AppModel		{	return AppModel.instance;			}
protected function get game():			Game			{	return appModel.game;				}
protected function get player():		Player			{	return game.player;					}
}
}