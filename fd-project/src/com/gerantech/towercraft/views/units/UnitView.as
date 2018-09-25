package com.gerantech.towercraft.views.units
{
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.views.HealthBar;
import com.gt.towers.battle.units.Unit;
import flash.utils.clearTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.display.MovieClip;
import starling.events.Event;

public class UnitView extends BaseUnit
{
private var _state:int;
private var _muted:Boolean = true;
private var direction:String;
private var textureType:String;
private var movieClip:MovieClip;
private var shadowDisplay:Image;
private var healthDisplay:HealthBar;
private var troopScale:Number = 1.2;

public function UnitView(id:int, type:int, level:int, side:int, x:Number, y:Number)
{
	super(id, type, level, side, x, y);
	
	shadowDisplay = new Image(Assets.getTexture("troops-shadow", "troops"));
	shadowDisplay.pivotX = shadowDisplay.width * 0.6;
	shadowDisplay.pivotY = shadowDisplay.height * 0.3;
	shadowDisplay.scale = 2;
	fieldView.unitsContainer.addChildAt(shadowDisplay, 0);
	
	textureType = 30 + "/" + side + "/";
	movieClip = new MovieClip(Assets.getTextures(textureType + "up-", "troops"), 15);
	movieClip.pivotX = movieClip.width * 0.5;
	movieClip.pivotY = movieClip.height * 0.75;
	movieClip.scale = troopScale;
	fieldView.unitsContainer.addChild(movieClip);
	
	setPosition(x, y, true);
	//muted = false
}

public function setPosition(x:Number, y:Number, forced:Boolean = false) : void
{
	var changed:Boolean = forced || this.x != x || this.y != y;
	if( !changed )
	{
		state = Unit.STATE_WAIT;
		return;
	}
	
	switchAnimation(x, y);
	state = Unit.STATE_MOVE;
	movieClip.x = shadowDisplay.x = x;
	movieClip.y = shadowDisplay.y = y;
	if( healthDisplay != null )
	{
		healthDisplay.x = x;
		healthDisplay.y = y - 80;
	}
}

public function get state() : int
{
	return _state;
}
public function set state(value:int) : void 
{
	if( _state == value )
		return;
	
	_state = value;
	if( _state == Unit.STATE_WAIT )
	{
		movieClip.pause();
	}
	else 
	{
		movieClip.play();
	}
}

private function switchAnimation(x:Number, y:Number) : void
{
	var rad:Number = Math.atan2(x - this.x, y - this.y);
	var flipped:Boolean = false;
	var dir:String;
	
	if( rad >= Math.PI * -0.125 && rad < Math.PI * 0.125 )
		dir = "do";
	else if( rad <= Math.PI * -0.125 && rad > Math.PI * -0.375 )
		dir = "ld";
	else if( rad <= Math.PI * -0.375 && rad > Math.PI * -0.625 )
		dir = "le";
	else if( rad <= Math.PI * -0.625 && rad > Math.PI * -0.875 )
		dir = "lu";
	else if( rad >= Math.PI * 0.125 && rad < Math.PI * 0.375 )
		dir = "dr";
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
	
	if( direction == dir )
		return;

	//movieClip.fps = 20 * 3000 / building.get_troopSpeed();
	//movieClip.fps = building.get_troopSpriteCount()*3000/building.get_troopSpeed();
	direction = dir;
	for ( var i:int = 0; i < movieClip.numFrames; i++ ){//trace(textureType + direction + ( i > 9 ? "_00" + (i) : "_000" + (i)), "troops");
	movieClip.setFrameTexture(i, Assets.getTexture(textureType + direction + ( i > 9 ? "_00" + (i) : "_000" + (i)), "troops"));}
}

override public function hit(damage:Number):void
{
	super.hit(damage);
	//trace(id, health, damage)
	if( health < card.health )
		updateHealthDisplay();
	if( health > 0 )
		return;
	
	/*AppModel.instance.sounds.addAndPlaySound("kill");
	var blood:Image = new Image(Assets.getTexture("blood", "troops"));
	blood.pivotX = blood.width * 0.5
	blood.pivotY = blood.height * 0.5
	blood.x = x;
	blood.y = y;
	parent.addChildAt(blood, 1);
	Starling.juggler.tween(blood, 2, {delay:1, alpha:0, onComplete:remove, onCompleteArgs:[blood]});
	Starling.juggler.tween(blood, 0.05, {scale:scale, transition:Transitions.EASE_OUT});
	blood.scale = 0;*/

	muted = true;
}

private function remove(blood:Image):void 
{
	blood.removeFromParent(true);
}

private function updateHealthDisplay():void
{
	if( health > 0 )
	{
		if( healthDisplay == null )
		{
			healthDisplay = new HealthBar(side, health, card.health);
			fieldView.guiImagesContainer.addChild(healthDisplay);
			//healthDisplay.scale = scale;
		}
		else
		{
			healthDisplay.value = health;
		}
	}
	else
	{
		if( healthDisplay != null )
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
	
	//visible = !_muted;
	
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
	movieClip.removeFromParent(true);
	shadowDisplay.removeFromParent(true);
	if( healthDisplay != null )
		healthDisplay.removeFromParent(true);
	super.dispose();
}
}
}