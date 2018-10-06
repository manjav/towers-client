package com.gerantech.towercraft.views.units
{
import com.gerantech.towercraft.controls.indicators.CountdownIcon;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.views.HealthBar;
import com.gerantech.towercraft.views.weapons.BulletView;
import com.gt.towers.battle.bullets.Bullet;
import com.gt.towers.battle.units.Unit;
import com.gt.towers.events.BattleEvent;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;
import flash.xml.XMLTag;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.display.MovieClip;
import starling.events.Event;
import starling.filters.ColorMatrixFilter;
import starling.textures.Texture;

public class UnitView extends BaseUnit
{
private var hitFilter:ColorMatrixFilter;
private var _state:int;
private var _muted:Boolean = true;
private var direction:String;
private var textureType:String;
private var movieClip:MovieClip;
private var shadowDisplay:Image;
private var healthDisplay:HealthBar;
private var troopScale:Number = 2;
private var deployIcon:CountdownIcon;
private var rangeDisplay:Image;
private var debugMode:Boolean = true;
private var hitTimeoutId:uint;

public function UnitView(id:int, type:int, level:int, side:int, x:Number, y:Number)
{
	
	super(id, type, level, side, x, y);
	//trace("UnitView", id, type, side, x.toFixed(), y.toFixed());

	shadowDisplay = new Image(Assets.getTexture("troops-shadow", "troops"));
	shadowDisplay.pivotX = shadowDisplay.width * 0.55;
	shadowDisplay.pivotY = shadowDisplay.height * 0.45;
	shadowDisplay.scale = 3;
	shadowDisplay.x = this.x;
	shadowDisplay.y = this.y;
	fieldView.unitsContainer.addChildAt(shadowDisplay, 0);
	
	textureType = Math.min(108, type) + "/" + battleField.getColorIndex(side) + "/";
	movieClip = new MovieClip(Assets.getTextures(textureType + "m_" + (side == battleField.side ? "000_" : "180_"), "troops"), 15);
	movieClip.pivotX = movieClip.width * 0.5;
	movieClip.pivotY = movieClip.height * 0.75;
	movieClip.scale = troopScale;
	movieClip.x = this.x;
	movieClip.y = this.y;
	fieldView.unitsContainer.addChild(movieClip);
	
	deployIcon = new CountdownIcon();
	deployIcon.stop();
	deployIcon.scale = 0.6;
	deployIcon.x = this.x;
	deployIcon.y = this.y - 80;
    deployIcon.rotateTo(0, 360, card.deployTime);
    fieldView.guiImagesContainer.addChild(deployIcon);
	
	if( debugMode )
	{
		rangeDisplay = new Image(Assets.getTexture("damage-range"));
		rangeDisplay.pivotX = rangeDisplay.width * 0.5;
		rangeDisplay.pivotY = rangeDisplay.height * 0.5;
		rangeDisplay.width = card.bulletRangeMax * 2;
		rangeDisplay.height = card.bulletRangeMax * 2 * 0.7;
		rangeDisplay.alpha = 0.2;
		rangeDisplay.x = this.x;
		rangeDisplay.y = this.y;
		fieldView.unitsContainer.addChildAt(rangeDisplay, 0);
	}
}

/*override public function update() : void
{
	super.update();
}*/

override public function fireEvent(dispatcherId:int, type:String, data:*) : void
{
	if( type == BattleEvent.DEPLOY )
	{
		deployIcon.punch();
		setTimeout(deployIcon.removeFromParent, 50);
		muted = false;
		return;
	}
	
	if( type == BattleEvent.ATTACK )
	{
		var enemy:Unit = data as Unit;
		battleField.bullets.set(battleField.bulletId, new BulletView(battleField, battleField.bulletId, card, side, x, y, enemy.x, enemy.y));
		battleField.bulletId ++;
		attacks(enemy.id);
		return;
	}
}

public function attacks(target:int): void
{
	switchAnimation("s_", battleField.units.get(target).x, x, battleField.units.get(target).y, y);
	movieClip.play();
}


override public function setPosition(x:Number, y:Number, forced:Boolean = false) : Boolean
{
	if( disposed )
		return false;
	
	var _x:Number = this.x;
	var _y:Number = this.y;
	if( !super.setPosition(x, y, forced) )
	{
		//state = Unit.STATE_WAIT;
		return false;
	}

	switchAnimation("m_", x, _x, y, _y);
	
	//state = Unit.STATE_MOVE;
	if( movieClip != null )
	{
		movieClip.x = this.x;
		movieClip.y = this.y;		
	}
	
	if( shadowDisplay != null )
	{
		shadowDisplay.x = this.x;
		shadowDisplay.y = this.y;		
	}

	if( healthDisplay != null )
	{
		healthDisplay.x = this.x;
		healthDisplay.y = this.y - 180;
	}

	if( healthDisplay != null )
	{
		healthDisplay.x = this.x;
		healthDisplay.y = this.y - 180;
	}

	if( rangeDisplay != null )
	{
		rangeDisplay.x = this.x;
		rangeDisplay.y = this.y;
	}
	return true;
}


private function switchAnimation(anim:String, x:Number, oldX:Number, y:Number, oldY:Number):void
{
	if( movieClip == null )
		return;
	if( x == -1 )
		x = this.x;
	if( y == -1 )
		y = this.y;
	var rad:Number = Math.atan2(oldX - x, oldY - y);
	var flipped:Boolean = false;
	var dir:String;
	

	if( rad >= Math.PI * -0.125 && rad < Math.PI * 0.125 )
		dir = "000";
	else if( rad <= Math.PI * -0.125 && rad > Math.PI * -0.375 )
		dir = "945";
	else if( rad <= Math.PI * -0.375 && rad > Math.PI * -0.625 )
		dir = "990";
	else if( rad <= Math.PI * -0.625 && rad > Math.PI * -0.875 )
		dir = "935";
	else if( rad >= Math.PI * 0.125 && rad < Math.PI * 0.375 )
		dir = "045";
	else if( rad >= Math.PI * 0.375 && rad < Math.PI * 0.625 )
		dir = "090";
	else if( rad >= Math.PI * 0.625 && rad < Math.PI * 0.875 )
		dir = "135";
	else
		dir = "180";
	
	if( dir == "945" || dir == "990" || dir == "935" )
	{
		if( dir == "945" )
			dir = dir.replace("945", "045");
		else if( dir == "990" )
			dir = dir.replace("990", "090");
		else
			dir = dir.replace("935", "135");
		flipped = true;
	}
	
	movieClip.loop = anim == "m_";
	dir = anim + dir;
	movieClip.scaleX = (flipped ? -troopScale : troopScale );
	
	if( direction == dir )
		return;

	//movieClip.fps = 20 * 3000 / building.get_troopSpeed();
	//movieClip.fps = building.get_troopSpriteCount()*3000/building.get_troopSpeed();
	direction = dir;
	var numFrames:int = movieClip.numFrames - 1;// trace(textureType + direction, numFrames);
	while ( numFrames > 0 )
	{
		movieClip.removeFrameAt(numFrames);
		numFrames --;
	}
	var textures:Vector.<Texture> = Assets.getTextures(textureType + direction, "troops");
	movieClip.setFrameTexture(0, textures[0]);
	for ( var i:int = 1; i < textures.length; i++ )
		movieClip.addFrame(textures[i]);
	movieClip.currentFrame = 0;
}

override public function hit(damage:Number):void
{
	super.hit(damage);
	if( disposed )
		return;
	//trace(id, health, damage)
	if( movieClip != null )
	{
		if( hitFilter == null )
		{
			hitFilter = new ColorMatrixFilter();
			hitFilter.adjustBrightness(1);
		}
		movieClip.filter = hitFilter;
		hitTimeoutId = setTimeout( function():void{ movieClip.filter = null; }, 60);
	}

	setHealth(health);
}

private function setHealth(health:Number):void
{
	if( health < card.health )
	{
		if( healthDisplay == null )
		{
			healthDisplay = new HealthBar(battleField.getColorIndex(side), health, card.health);
			healthDisplay.x = this.x;
			healthDisplay.y = this.y - 180;
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
		dispose();
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
		//Starling.juggler.removeTweens(this);
		Starling.juggler.remove(movieClip);
	}
	else
	{
		Starling.juggler.add(movieClip);
	}
}

override public function dispose() : void
{
	super.dispose();
	clearTimeout(hitTimeoutId);
	muted = true;
	movieClip.removeFromParent(true);
	shadowDisplay.removeFromParent(true);
	if( rangeDisplay != null )
		rangeDisplay.removeFromParent(true);
	if( healthDisplay != null )
		healthDisplay.removeFromParent(true);
	if( deployIcon != null )
		deployIcon.removeFromParent(true);
}

/*public function set alpha(value:Number):void 
{
	movieClip.alpha = value;
	shadowDisplay.alpha = value;
	if( rangeDisplay != null )
		rangeDisplay.alpha = value;
	if( healthDisplay != null )
		healthDisplay.alpha = value;
	if( deployIcon != null )
		deployIcon.alpha = value;
}*/
}
}