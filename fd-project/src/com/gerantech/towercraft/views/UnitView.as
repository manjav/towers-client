package com.gerantech.towercraft.views
{
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.battle.units.Card;
import flash.utils.clearTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.events.Event;

public class UnitView extends Sprite
{
public var id:int;
public var type:int;
public var side:int = 0;
private var _health:Number;
private var _muted:Boolean = true;

private var card:Card;
private var direction:String;
private var rushTimeoutId:uint;
private var textureType:String;
private var movieClip:MovieClip;
private var healthDisplay:HealthBar;
private var troopScale:Number = 1.2;

public function UnitView(id:int, type:int, side:int, level:int)
{
	this.id = id;
	this.side = side;
	this.card = new Card(AppModel.instance.game, type, level);
	
	var shadow:Image = new Image(Assets.getTexture("troops-shadow", "troops"));
	shadow.pivotX = shadow.width * 0.6;
	shadow.pivotY = shadow.height * 0.3;
	shadow.scale = 2;
	addChild(shadow);
	
	textureType = 30 + "/" + side + "/";
	movieClip = new MovieClip(Assets.getTextures(textureType + "up-", "troops"), 15);
	movieClip.pivotX = movieClip.width * 0.5;
	movieClip.pivotY = movieClip.height * 0.75;
	movieClip.scale = troopScale;
	addChild(movieClip);
	
	touchable = false;
	switchAnimation();
}

private function switchAnimation():void
{
	var rad:Number = 0;// Math.atan2(destination.x - source.x, destination.y - source.y);
	var flipped:Boolean = false;
	var dir:String;
	
	if( rad >= Math.PI * -0.125 && rad < Math.PI * 0.125 )
		dir = "180";
	else if( rad <= Math.PI * -0.125 && rad > Math.PI * -0.375 )
		dir = "ld";
	else if( rad <= Math.PI * -0.375 && rad > Math.PI * -0.625 )
		dir = "le";
	else if( rad <= Math.PI * -0.625 && rad > Math.PI * -0.875 )
		dir = "lu";
	else if( rad >= Math.PI * 0.125 && rad < Math.PI * 0.375 )
		dir = "135";
	else if( rad >= Math.PI * 0.375 && rad < Math.PI * 0.625 )
		dir = "090";
	else if( rad >= Math.PI * 0.625 && rad < Math.PI * 0.875 )
		dir = "045";
	else
		dir = "000";
	
	if( dir == "ld" || dir == "le" || dir == "lu" )
	{
		if( dir == "le" )
			dir = dir.replace("le", "090");
		else if( dir == "lu" )
			dir = dir.replace("lu", "045");
		else
			dir = dir.replace("ld", "135");
		flipped = true;
	}
	
	movieClip.scaleX = (flipped ? -troopScale : troopScale );
	
	if( direction == dir )
		return;

	//movieClip.fps = 20 * 3000 / building.get_troopSpeed();
	//movieClip.fps = building.get_troopSpriteCount()*3000/building.get_troopSpeed();
	direction = dir;
	for ( var i:int = 0; i < movieClip.numFrames; i++ ){trace(textureType + direction + ( i > 9 ? "_00" + (i) : "_000" + (i)), "troops");
	movieClip.setFrameTexture(i, Assets.getTexture(textureType + direction + ( i > 9 ? "_00" + (i) : "_000" + (i)), "troops"));}
}

public function hit(damage:Number):void
{
	health -= damage;
	//trace(id, health, damage)
	dispatchEventWith(Event.TRIGGERED, false, damage);
	
	if( health > 0 )
		return;
	
	AppModel.instance.sounds.addAndPlaySound("kill");
	var blood:Image = new Image(Assets.getTexture("blood", "troops"));
	blood.pivotX = blood.width * 0.5
	blood.pivotY = blood.height * 0.5
	blood.x = x;
	blood.y = y;
	parent.addChildAt(blood, 1);
	Starling.juggler.tween(blood, 2, {delay:1, alpha:0, onComplete:remove, onCompleteArgs:[blood]});
	Starling.juggler.tween(blood, 0.05, {scale:scale, transition:Transitions.EASE_OUT});
	blood.scale = 0;

	muted = true;
}

private function remove(blood:Image):void 
{
	blood.removeFromParent(true);
	removeFromParent(true);
}


public function get health():Number
{
	return _health;
}
public function set health(value:Number):void
{
	if( _health == value )
		return;
	
	_health = value;
	if( _health < card.health )
		updateHealthDisplay(_health);
}

private function updateHealthDisplay(health:Number):void
{
	if( health > 0 )
	{
		if( healthDisplay == null )
		{
			healthDisplay = new HealthBar(side, health, card.health);
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
	return _muted;
}
public function set muted(value:Boolean):void 
{
	if( _muted == value )
		return;
	_muted = value;
	
	visible = !_muted;
	
	if( movieClip == null )
		return;
		
	movieClip.muted = _muted;
	if ( _muted )
	{
		Starling.juggler.removeTweens(this);
		Starling.juggler.remove(movieClip);
	}
	else
	{
		Starling.juggler.add(movieClip);
	}
}

override public function dispose():void
{
	clearTimeout(rushTimeoutId);
	super.dispose();
}
}
}