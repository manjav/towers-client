package com.gerantech.towercraft.views.units
{
import com.gerantech.towercraft.controls.indicators.CountdownIcon;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.views.BattleFieldView;
import com.gerantech.towercraft.views.HealthBar;
import com.gerantech.towercraft.views.weapons.BulletView;
import com.gt.towers.battle.GameObject;
import com.gt.towers.battle.units.Unit;
import com.gt.towers.events.BattleEvent;
import com.gt.towers.utils.CoreUtils;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.display.MovieClip;
import starling.events.Event;
import starling.filters.ColorMatrixFilter;
import starling.textures.Texture;
import starling.utils.Color;

public class UnitView extends BaseUnit
{
private var hitFilter:ColorMatrixFilter;
private var _state:int;
private var _muted:Boolean = true;
private var direction:String;
private var textureType:String;
private var bodyDisplay:MovieClip;
private var shadowDisplay:Image;
private var healthDisplay:HealthBar;
private var troopScale:Number = 2;
private var deployIcon:CountdownIcon;
private var hitTimeoutId:uint;
private var rangeDisplay:Image;
private var sizeDisplay:Image;

public function UnitView(id:int, type:int, level:int, side:int, x:Number, y:Number)
{
	
	super(id, type, level, side, x, y);

	//if( type < 200 )
	//{
		shadowDisplay = new Image(Assets.getTexture("troops-shadow", "troops"));
		shadowDisplay.pivotX = shadowDisplay.width * 0.55;
		shadowDisplay.pivotY = shadowDisplay.height * 0.55;
		shadowDisplay.width = card.sizeH * 2;
		shadowDisplay.height = card.sizeH * 1.42;
		shadowDisplay.x = this.x;
		shadowDisplay.y = this.y;
		fieldView.unitsContainer.addChildAt(shadowDisplay, 0);
	//}
	
	var appearanceDelay:Number = Math.random() * 0.5;
	
	textureType = Math.min(208, type) + "/" + battleField.getColorIndex(side) + "/";
	bodyDisplay = new MovieClip(Assets.getTextures(textureType + "m_" + (side == battleField.side ? "000_" : "180_"), "troops"), 15);
	bodyDisplay.pivotX = bodyDisplay.width * 0.5;
	bodyDisplay.pivotY = bodyDisplay.height * 0.75;
	bodyDisplay.x = this.x;
	bodyDisplay.y = this.y;
	bodyDisplay.scaleX = troopScale;
	bodyDisplay.scaleY = troopScale;
	fieldView.unitsContainer.addChild(bodyDisplay);

	if( movable )
	{
		bodyDisplay.alpha = 0;
		bodyDisplay.y = this.y - 100;
		bodyDisplay.scaleY = troopScale * 4;
		Starling.juggler.tween(bodyDisplay, 0.3, {delay:appearanceDelay,		alpha:1, y:this.y, transition:Transitions.EASE_OUT, onComplete:defaultSummonEffectFactory});
		Starling.juggler.tween(bodyDisplay, 0.3, {delay:appearanceDelay + 0.1,	scaleY:troopScale, transition:Transitions.EASE_OUT_BACK});		
	}
	
	deployIcon = new CountdownIcon();
	deployIcon.stop();
	deployIcon.scale = 0.5;
	deployIcon.x = this.x;
	deployIcon.y = this.y - 80;
    deployIcon.rotateTo(0, 360, card.summonTime);
    setTimeout(fieldView.guiImagesContainer.addChild, appearanceDelay * 1000, deployIcon);
	
	if( BattleFieldView.DEBUG_MODE )
	{
		sizeDisplay = new Image(Assets.getTexture("damage-range"));
		sizeDisplay.pivotX = sizeDisplay.width * 0.5;
		sizeDisplay.pivotY = sizeDisplay.height * 0.5;
		sizeDisplay.width = card.sizeH * 2;
		sizeDisplay.height = card.sizeH * 1.42;
		//sizeDisplay.alpha = 0.1;
		sizeDisplay.color = Color.NAVY;
		sizeDisplay.x = this.x;
		sizeDisplay.y = this.y;
		fieldView.unitsContainer.addChildAt(sizeDisplay, 0);
		
		rangeDisplay = new Image(Assets.getTexture("damage-range"));
		rangeDisplay.pivotX = rangeDisplay.width * 0.5;
		rangeDisplay.pivotY = rangeDisplay.height * 0.5;
		rangeDisplay.width = card.bulletRangeMax * 2;
		rangeDisplay.height = card.bulletRangeMax * 1.42;
		rangeDisplay.alpha = 0.1;
		rangeDisplay.x = this.x;
		rangeDisplay.y = this.y;
		fieldView.unitsContainer.addChildAt(rangeDisplay, 0);
	}
}

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
		battleField.bullets.set(enemy.bulletId, new BulletView(battleField, enemy.bulletId, card, side, x, y, enemy.x, enemy.y));
		enemy.bulletId ++;
		attacks(enemy.id);
		return;
	}
}

public function attacks(target:int): void
{
	switchAnimation("s_", battleField.units.get(target).x, x, battleField.units.get(target).y, y);
	bodyDisplay.currentFrame = 0;
	bodyDisplay.play();
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
	if( bodyDisplay != null )
	{
		bodyDisplay.x = this.x;
		bodyDisplay.y = this.y;		
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
	
	if( sizeDisplay != null )
	{
		sizeDisplay.x = this.x;
		sizeDisplay.y = this.y;
	}
	return true;
}


private function switchAnimation(anim:String, x:Number, oldX:Number, y:Number, oldY:Number):void
{
	if( bodyDisplay == null )
		return;
	if( x == GameObject.NaN )
		x = this.x;
	if( y == GameObject.NaN )
		y = this.y;
	var flipped:Boolean = false;
	var dir:String = CoreUtils.getRadString(Math.atan2(oldX - x, oldY - y));
	if( dir == "-45" || dir == "-90" || dir == "-35" )
	{
		if( dir == "-45" )
			dir = dir.replace("-45", "045");
		else if( dir == "-90" )
			dir = dir.replace("-90", "090");
		else
			dir = dir.replace("-35", "135");
		flipped = true;
	}
	
	bodyDisplay.loop = anim == "m_";
	dir = anim + dir;
	bodyDisplay.scaleX = (flipped ? -troopScale : troopScale );
	
	if( direction == dir )
		return;

	//movieClip.fps = 20 * 3000 / building.get_troopSpeed();
	//movieClip.fps = building.get_troopSpriteCount()*3000/building.get_troopSpeed();
	direction = dir;
	var numFrames:int = bodyDisplay.numFrames - 1;// trace(textureType + direction, numFrames);
	while( numFrames > 0 )
	{
		bodyDisplay.removeFrameAt(numFrames);
		numFrames --;
	}
	var textures:Vector.<Texture> = Assets.getTextures(textureType + direction, "troops");
	bodyDisplay.setFrameTexture(0, textures[0]);
	for ( var i:int = 1; i < textures.length; i++ )
		bodyDisplay.addFrame(textures[i]);
	bodyDisplay.currentFrame = 0;
}

override public function hit(damage:Number):void
{
	super.hit(damage);
	if( disposed )
		return;
	//trace(id, health, damage)
	if( bodyDisplay != null )
	{
		if( hitFilter == null )
		{
			hitFilter = new ColorMatrixFilter();
			hitFilter.adjustBrightness(0.6);
		}
		bodyDisplay.filter = hitFilter;
		hitTimeoutId = setTimeout( function():void{ bodyDisplay.filter = null; }, 50);
	}

	setHealth(health);
}

private function setHealth(health:Number):void
{
	if( health > 0 && health < card.health )
	{
		if( healthDisplay == null )
		{
			healthDisplay = new HealthBar(battleField.getColorIndex(side), health, card.health);
			healthDisplay.x = this.x;
			healthDisplay.y = this.y - 180;
			fieldView.guiImagesContainer.addChild(healthDisplay);
		}
		else
		{
			healthDisplay.value = health;
		}
		return;
	}
	
	if( health < 0 )
		dispose();
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
	if( bodyDisplay == null )
		return;
		
	bodyDisplay.muted = _muted;
	if ( _muted )
	{
		//Starling.juggler.removeTweens(this);
		Starling.juggler.remove(bodyDisplay);
	}
	else
	{
		Starling.juggler.add(bodyDisplay);
	}
}

protected function defaultSummonEffectFactory() : void
{
	var summonDisplay:MovieClip = new MovieClip(Assets.getTextures("summons/explosion-", "effects"), 35);
	summonDisplay.pivotX = summonDisplay.width * 0.5;
	summonDisplay.pivotY = summonDisplay.height * 0.5;
	summonDisplay.width = card.sizeH * 2.00;
	summonDisplay.height = card.sizeH * 1.42;
	summonDisplay.x = this.x;
	summonDisplay.y = this.y;
	fieldView.unitsContainer.addChildAt(summonDisplay, 0);
	summonDisplay.play();
	Starling.juggler.add(summonDisplay);
	summonDisplay.addEventListener(Event.COMPLETE, function() : void { Starling.juggler.remove(summonDisplay); summonDisplay.removeFromParent(true); });
	return;
}

override public function dispose() : void
{
	super.dispose();
	clearTimeout(hitTimeoutId);
	muted = true;
	bodyDisplay.removeFromParent(true);
	if( shadowDisplay != null )
		shadowDisplay.removeFromParent(true);
	if( rangeDisplay != null )
		rangeDisplay.removeFromParent(true);
	if( healthDisplay != null )
		healthDisplay.removeFromParent(true);
	if( deployIcon != null )
		deployIcon.removeFromParent(true);
	if( sizeDisplay != null )
		sizeDisplay.removeFromParent(true);
}

public function set alpha(value:Number):void 
{
	bodyDisplay.alpha = value;
	if( shadowDisplay != null )
		shadowDisplay.alpha = value;
	if( rangeDisplay != null )
		rangeDisplay.alpha = value;
	if( healthDisplay != null )
		healthDisplay.alpha = value;
	if( deployIcon != null )
		deployIcon.alpha = value;
}
}
}