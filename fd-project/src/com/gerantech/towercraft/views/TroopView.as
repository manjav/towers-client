package com.gerantech.towercraft.views
{
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.buildings.Building;
import com.gt.towers.buildings.Place;
import com.gt.towers.constants.BuildingType;
import com.gt.towers.utils.PathFinder;
import com.gt.towers.utils.lists.PlaceList;

import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.events.Event;

public class TroopView extends Sprite
{
public var id:int;
public var type:int;
private var _health:Number;

private var path:Vector.<PlaceView>;
private var building:Building;

private var direction:String;
private var rushTimeoutId:uint;
private var textureType:String;

private var movieClip:MovieClip;
private var healthDisplay:HealthBar;
private var battleSide:int = 0;
private var troopScale:Number = 1.2;

public function TroopView(building:Building, path:PlaceList)
{
	this.id = building.place.getIncreasedId();
	this.type = building.troopType;
	this.battleSide = type == AppModel.instance.game.player.troopType?0:1;
	this.building = building;
	this.health = building.troopPower;
	
	textureType = BuildingType.getTroopName(building.type) + battleSide + "/";
	movieClip = new MovieClip(Assets.getTextures(textureType+"do", "troops"), 20);
	movieClip.pivotX = movieClip.width * 0.5;
	movieClip.pivotY = movieClip.height * 0.75;
	movieClip.scale = troopScale;
	addChild(movieClip);
	
	touchable = false;
	
	this.path = new Vector.<PlaceView>();
	for (var p:uint=0; p<path.size(); p++)
		this.path.push(AppModel.instance.battleFieldView.places[path.get(p).index]);
}


public function rush(source:Place):void
{
	var next:PlaceView = path.shift();
	if( next == null )
	{
		removeFromParent(true);
		return;
	}
	
	switchAnimation(source, next.place);
	visible = true;
	movieClip.muted = false;
	Starling.juggler.add(movieClip);

	var randomGap:Number = Math.max(0, Math.random() * building.troopRushGap - Math.random()* building.troopRushGap * 0.5) / 1000;
	var distance:Number = PathFinder.getDistance(source, next.place) * 1.1;
	Starling.juggler.tween(this, (building.troopSpeed/1000) * distance - randomGap + 0.1, {x:next.x, y:next.y, delay:randomGap, onComplete:onTroopArrived, onCompleteArgs:[next]});
}
private function onTroopArrived(next:PlaceView):void
{
	visible = false;
	movieClip.muted = true;
	Starling.juggler.remove(movieClip);
	if( next.place.building.troopType == type )
		rushTimeoutId = setTimeout(rush, building.troopRushGap, next.place);
	else
		next.decorator.showUnderAttack();
}

private function switchAnimation(source:Place, destination:Place):void
{
	var rad:Number = Math.atan2(destination.x - source.x, destination.y - source.y);
	var flipped:Boolean = false;
	var dir:String;
	
	if(rad >= Math.PI * -0.125 && rad < Math.PI * 0.125 )
		dir = "do";
	else if( rad <= Math.PI * -0.125 && rad > Math.PI * -0.375 )
		dir = "ld";
	else if( rad <= Math.PI * -0.375 && rad > Math.PI * -0.625 )
		dir = "le";
	else if( rad <= Math.PI * -0.625 && rad > Math.PI * -0.875 )
		dir = "lu";
	else if( rad >= Math.PI * 0.125 && rad < Math.PI * 0.375 )
		dir = "rd";
	else if( rad >= Math.PI * 0.375 && rad < Math.PI * 0.625 )
		dir = "ri";
	else if( rad >= Math.PI * 0.625 && rad < Math.PI * 0.875 )
		dir = "ru";
	else
		dir = "up";
	
	if( dir == "ld" || dir == "le" || dir == "lu" )
	{
		if( dir == "le" )
			dir = dir.replace("le", "ri");
		else if( dir == "lu" )
			dir = dir.replace("lu", "ru");
		else
			dir = dir.replace("ld", "rd");
		flipped = true;
	}
	
	movieClip.scaleX = (flipped ? -troopScale : troopScale );
	
	if(direction == dir)
		return;

	//movieClip.fps = 20 * 3000 / building.get_troopSpeed();
	//movieClip.fps = building.get_troopSpriteCount()*3000/building.get_troopSpeed();
	direction = dir;
	for( var i:int=0; i < movieClip.numFrames; i++ )
		movieClip.setFrameTexture(i, Assets.getTexture(textureType + direction + ( i > 9 ? "-00" + (i) : "-000" + (i)), "troops"));
}

public function hit(damage:Number):void
{
	health -= damage;
	dispatchEventWith(Event.TRIGGERED, false, damage);
	
	if( health > 0 )
		return;

	AppModel.instance.sounds.addAndPlaySound("kill");
	var blood:Image = new Image(Assets.getTexture("blood"));
	blood.pivotX = blood.width/2;
	blood.pivotY = blood.height/2;
	blood.x = x;
	blood.y = y;
	parent.addChildAt(blood, 1);
	Starling.juggler.tween(blood, 2, {delay:1, alpha:0, onComplete:blood.removeFromParent, onCompleteArgs:[true]});
	Starling.juggler.tween(blood, 0.05, {scale:scale, transition:Transitions.EASE_OUT});
	blood.scale = 0;
}


public function get health():Number
{
	return _health;
}
public function set health(value:Number):void
{
	if ( _health == value )
		return;
	
	_health = value;
	//trace(_health)
	if( _health < building.troopPower )
		updateHealthDisplay(_health);

		
}

private function updateHealthDisplay(health:Number):void
{
	if( health > 0 )
	{
		if( healthDisplay == null )
		{
			healthDisplay = new HealthBar(battleSide, health, building.troopPower);
			addChild(healthDisplay);
			healthDisplay.y = -80;
			healthDisplay.scale = scale;
		}
		else
		{
			healthDisplay.value = health;
		}
	}
	else
	{
		if( healthDisplay )
			healthDisplay.removeFromParent(true);	
	}
}

public function get muted():Boolean
{
	return movieClip.muted;
}

override public function dispose():void
{
	clearTimeout(rushTimeoutId);
	super.dispose();
}
}
}