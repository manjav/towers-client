package com.gerantech.towercraft.views.units
{
import com.gerantech.towercraft.controls.indicators.CountdownIcon;
import com.gerantech.towercraft.controls.sliders.battle.HealthBarLeveled;
import com.gerantech.towercraft.views.BattleFieldView;
import com.gerantech.towercraft.views.weapons.BulletView;
import com.gt.towers.battle.BattleField;
import com.gt.towers.battle.GameObject;
import com.gt.towers.battle.bullets.Bullet;
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
private var _muted:Boolean = true;
private var direction:String;
private var textureType:String;
private var bodyDisplay:MovieClip;
private var shadowDisplay:Image;
private var healthDisplay:HealthBarLeveled;
private var troopScale:Number = 2;
private var deployIcon:CountdownIcon;
private var hitTimeoutId:uint;
private var rangeDisplay:Image;
private var sizeDisplay:Image;
private var __x:Number;
private var __y:Number;

public function UnitView(id:int, type:int, level:int, side:int, x:Number, y:Number, z:Number)
{
	super(id, type, level, side, x, y, z);
	__x = getSideX();
	__y = getSideY();
	shadowDisplay = new Image(appModel.assets.getTexture("troops-shadow"));
	shadowDisplay.pivotX = shadowDisplay.width * 0.55;
	shadowDisplay.pivotY = shadowDisplay.height * 0.55;
	shadowDisplay.width = card.sizeH * 2;
	shadowDisplay.height = card.sizeH * 1.42;
	shadowDisplay.x = __x;
	shadowDisplay.y = __y;
	fieldView.unitsContainer.addChildAt(shadowDisplay, 0);
	
	var appearanceDelay:Number = Math.random() * 0.5;
	
	textureType = Math.min(208, type) + "/" + battleField.getColorIndex(side) + "/";
	bodyDisplay = new MovieClip(appModel.assets.getTextures(textureType + "m_" + (side == battleField.side ? "000_" : "180_")), 15);
	bodyDisplay.pivotX = bodyDisplay.width * 0.5;
	bodyDisplay.pivotY = bodyDisplay.height * 0.75;
	bodyDisplay.x = __x;
	bodyDisplay.y = __y;
	bodyDisplay.scaleX = troopScale;
	bodyDisplay.scaleY = troopScale;
	fieldView.unitsContainer.addChild(bodyDisplay);
	setHealth(card.health);

	if( movable )
	{
		bodyDisplay.alpha = 0;
		bodyDisplay.y = __y - 100;
		bodyDisplay.scaleY = troopScale * 4;
		Starling.juggler.tween(bodyDisplay, 0.3, {delay:appearanceDelay,		alpha:1, y:__y, transition:Transitions.EASE_OUT, onComplete:defaultSummonEffectFactory});
		Starling.juggler.tween(bodyDisplay, 0.3, {delay:appearanceDelay + 0.1,	scaleY:troopScale, transition:Transitions.EASE_OUT_BACK});		
	}
	
	if( card.summonTime > 0 )
	{
		deployIcon = new CountdownIcon();
		deployIcon.stop();
		deployIcon.scale = 0.5;
		deployIcon.x = __x;
		deployIcon.y = __y - 80;
		deployIcon.rotateTo(0, 360, card.summonTime / 1000);
		setTimeout(fieldView.guiImagesContainer.addChild, appearanceDelay * 1000, deployIcon);
	}
	
	if( BattleField.DEBUG_MODE )
	{
		sizeDisplay = new Image(appModel.assets.getTexture("damage-range"));
		sizeDisplay.pivotX = sizeDisplay.width * 0.5;
		sizeDisplay.pivotY = sizeDisplay.height * 0.5;
		sizeDisplay.width = card.sizeH * 2;
		sizeDisplay.height = card.sizeH * 1.42;
		//sizeDisplay.alpha = 0.1;
		sizeDisplay.color = Color.NAVY;
		sizeDisplay.x = __x;
		sizeDisplay.y = __y;
		fieldView.unitsContainer.addChildAt(sizeDisplay, 0);
		
		rangeDisplay = new Image(appModel.assets.getTexture("damage-range"));
		rangeDisplay.pivotX = rangeDisplay.width * 0.5;
		rangeDisplay.pivotY = rangeDisplay.height * 0.5;
		rangeDisplay.width = card.bulletRangeMax * 2;
		rangeDisplay.height = card.bulletRangeMax * 1.42;
		rangeDisplay.alpha = 0.1;
		rangeDisplay.x = __x;
		rangeDisplay.y = __y;
		fieldView.unitsContainer.addChildAt(rangeDisplay, 0);
	}
}

override public function setState(state:int) : Boolean
{
	if( !super.setState(state) )
		return false;
	
	if( state == GameObject.STATE_1_DIPLOYED )
	{
		muted = false;
		if( deployIcon != null )
			deployIcon.scaleTo(0, 0, 0.5, function():void{deployIcon.removeFromParent(true);} );
	}
	else if( state == GameObject.STATE_3_WAITING )
	{
		bodyDisplay.currentFrame = 0;
		bodyDisplay.pause();
	}
	else if ( state == GameObject.STATE_2_MOVING )
	{
		bodyDisplay.play();
	}

	return true;
}

override public function fireEvent(dispatcherId:int, type:String, data:*) : void
{
	if( type == BattleEvent.ATTACK )
	{
		var enemy:Unit = data as Unit;
		
		var b:BulletView = new BulletView(battleField, enemy.bulletId, card, side, x, y, 0, enemy.x, enemy.y, 0);
		b.targetId = enemy.id;
		battleField.bullets.set(enemy.bulletId, b);
		enemy.bulletId ++;
		attacks(enemy.id);
		return;
	}
	super.fireEvent(dispatcherId, type, data);
}

public function attacks(target:int): void
{
	switchAnimation("s_", battleField.units.get(target).getSideX(), __x, battleField.units.get(target).getSideY(), __y);
	bodyDisplay.currentFrame = 0;
	bodyDisplay.play();
}

override public function setPosition(x:Number, y:Number, z:Number, forced:Boolean = false) : Boolean
{
	if( disposed() )
		return false;
	
	var _x:Number = getSideX();
	var _y:Number = getSideY();
	if( !super.setPosition(x, y, z, forced) )
		return false;
	
	__x = getSideX();
	__y = getSideY();
	switchAnimation("m_", __x, _x, __y, _y);
	
	if( bodyDisplay != null )
	{
		bodyDisplay.x = __x;
		bodyDisplay.y = __y;		
	}
	
	if( shadowDisplay != null )
	{
		shadowDisplay.x = __x;
		shadowDisplay.y = __y;		
	}

	if( healthDisplay != null )
		healthDisplay.setPosition(__x, __y - card.sizeV - 60);

	if( rangeDisplay != null )
	{
		rangeDisplay.x = __x;
		rangeDisplay.y = __y;
	}
	
	if( sizeDisplay != null )
	{
		sizeDisplay.x = __x;
		sizeDisplay.y = __y;
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
	var textures:Vector.<Texture> = appModel.assets.getTextures(textureType + direction);
	bodyDisplay.setFrameTexture(0, textures[0]);
	for ( var i:int = 1; i < textures.length; i++ )
		bodyDisplay.addFrame(textures[i]);
	bodyDisplay.currentFrame = 0;
}

override public function hit(damage:Number):void
{
	super.hit(damage);
	if( disposed() )
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
	if( healthDisplay == null )
	{
		healthDisplay = new HealthBarLeveled(fieldView, battleField.getColorIndex(side), card.level, health, card.health);
		healthDisplay.setPosition(__x, __y - card.sizeV - 60);
	}
	else
	{
		healthDisplay.value = health;
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
	var summonDisplay:MovieClip = new MovieClip(appModel.assets.getTextures("summons/explosion-"), 35);
	summonDisplay.pivotX = summonDisplay.width * 0.5;
	summonDisplay.pivotY = summonDisplay.height * 0.5;
	summonDisplay.width = card.sizeH * 2.00;
	summonDisplay.height = card.sizeH * 2.00 * BattleField.CAMERA_ANGLE;
	summonDisplay.x = getSideX();
	summonDisplay.y = getSideY();
	fieldView.unitsContainer.addChildAt(summonDisplay, 0);
	summonDisplay.play();
	Starling.juggler.add(summonDisplay);
	summonDisplay.addEventListener(Event.COMPLETE, function() : void { Starling.juggler.remove(summonDisplay); summonDisplay.removeFromParent(true); });
	return;
}

public function showWinnerFocus():void 
{
	var winnerDisplay:Image = new Image(appModel.assets.getTexture("damage-range"));
	winnerDisplay.pivotX = winnerDisplay.width * 0.5;
	winnerDisplay.pivotY = winnerDisplay.height * 0.5;
	winnerDisplay.width = 500;
	winnerDisplay.height = 500 * BattleField.CAMERA_ANGLE;
	winnerDisplay.x = getSideX();
	winnerDisplay.y = getSideY();
	fieldView.unitsContainer.addChildAt(winnerDisplay, 0);
	Starling.juggler.tween(winnerDisplay, 1, {scale:0, transition:Transitions.EASE_IN_BACK, onComplete:winnerDisplay.removeFromParent, onCompleteArgs:[true]});
}

private function showBloodSplashhAnimation():void 
{
	var bloodSplashDisplay:MovieClip = new MovieClip(appModel.assets.getTextures("die/blood_splash_"), 30);
	bloodSplashDisplay.pivotX = bloodSplashDisplay.width * 0.5;
	bloodSplashDisplay.pivotY = bloodSplashDisplay.height * 0.5;
	bloodSplashDisplay.width = (card.sizeH * 0.7) + 130;
	bloodSplashDisplay.scaleY = bloodSplashDisplay.scaleX;
	bloodSplashDisplay.scaleX *= Math.random() > 0.5 ? -1 : 1;
	bloodSplashDisplay.color = 0xFF0000 + Math.random() * 5000;
	bloodSplashDisplay.x = getSideX();
	bloodSplashDisplay.y = getSideY();
	fieldView.unitsContainer.addChildAt(bloodSplashDisplay, 0);
	bloodSplashDisplay.play();
	Starling.juggler.add(bloodSplashDisplay);
	bloodSplashDisplay.addEventListener(Event.COMPLETE, function() : void { Starling.juggler.remove(bloodSplashDisplay); bloodSplashDisplay.removeFromParent(true); });
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
	if( deployIcon != null )
		deployIcon.removeFromParent(true);
	if( sizeDisplay != null )
		sizeDisplay.removeFromParent(true);
	if( healthDisplay != null )
		healthDisplay.dispose();
	showBloodSplashhAnimation();
}


public function set alpha(value:Number):void 
{
	bodyDisplay.alpha = value;
	if( shadowDisplay != null )
		shadowDisplay.alpha = value;
	if( rangeDisplay != null )
		rangeDisplay.alpha = value;
	if( healthDisplay != null )
		rangeDisplay.alpha = value;
	if( deployIcon != null )
		deployIcon.alpha = value;
}
}
}