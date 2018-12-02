package com.gerantech.towercraft.views.weapons 
{
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.views.BattleFieldView;
import com.gt.towers.battle.BattleField;
import com.gt.towers.battle.GameObject;
import com.gt.towers.battle.bullets.Bullet;
import com.gt.towers.battle.units.Card;
import com.gt.towers.calculators.BulletFirePositionCalculator;
import com.gt.towers.constants.CardTypes;
import com.gt.towers.events.BattleEvent;
import com.gt.towers.utils.Point3;
import starling.core.Starling;
import starling.display.Image;
import starling.display.MovieClip;
import starling.events.Event;
import starling.utils.MathUtil;

/**
* ...
* @author Mansour Djawadi
*/
public class BulletView extends Bullet 
{
public var bulletDisplayFactory:Function;
public var fireDisplayFactory:Function;
public var hitDisplayFactory:Function;
private var bulletDisplay:MovieClip;
private var shadowDisplay:Image;
private var rotation:Number;

public function BulletView(battleField:BattleField, id:int, card:Card, side:int, x:Number, y:Number, z:Number, fx:Number, fy:Number, fz:Number) 
{
	super(battleField, id, card, side, x, y, z, fx, fy, fz);
	
	rotation = MathUtil.normalizeAngle( -Math.atan2(-dx, -dy -dz * BattleField.CAMERA_ANGLE));
	
	if( bulletDisplayFactory == null )
		bulletDisplayFactory = defaultBulletDisplayFactory;
	
	if( fireDisplayFactory == null )
		fireDisplayFactory = defaultFireDisplayFactory;
		
	if( hitDisplayFactory == null )
		hitDisplayFactory = defaultHitDisplayFactory;
}

override public function fireEvent(dispatcherId:int, type:String, data:*) : void
{
	if( type == BattleEvent.STATE_CHANGE && state == GameObject.STATE_1_DIPLOYED )
	{
		appModel.sounds.addAndPlaySound(card.type + "-shoot");
		bulletDisplayFactory();
		fireDisplayFactory();
	}
}

override public function setPosition(x:Number, y:Number, z:Number, forced:Boolean = false) : Boolean
{
	if( disposed() )
		return false;

	if( !super.setPosition(x, y, z, forced) )
		return false;

	var _x:Number = this.getSideX();
	var _y:Number = this.getSideY() + (this.z * BattleField.CAMERA_ANGLE);
	//if( card.type == 151 )
	//	trace("setPosition"," x:" + this.x, " y:" + this.y, " z:" + this.z, " _y:" + _y);
	
	if( bulletDisplay != null )
	{
		bulletDisplay.x = _x;
		bulletDisplay.y = _y - card.sizeV * BattleField.CAMERA_ANGLE;	
	}
	
	if( shadowDisplay != null )
	{
		shadowDisplay.x = _x;
		shadowDisplay.y = _y;
	} 

	return true;
}

override public function dispose():void
{
	super.dispose();
	hitDisplayFactory();

	if( shadowDisplay != null )
		shadowDisplay.removeFromParent(true);
	
	if( bulletDisplay != null )
	{
		Starling.juggler.remove(bulletDisplay);
		bulletDisplay.removeFromParent(true);
	}
	
	if( BattleField.DEBUG_MODE )
	{
		var damageAreaDisplay:Image = new Image(appModel.assets.getTexture("damage-range"));
		damageAreaDisplay.pivotX = damageAreaDisplay.width * 0.5;
		damageAreaDisplay.pivotY = damageAreaDisplay.height * 0.5;
		damageAreaDisplay.width = card.bulletDamageArea * 2;
		damageAreaDisplay.height = card.bulletDamageArea * 2 * BattleField.CAMERA_ANGLE;
		damageAreaDisplay.x = this.x;
		damageAreaDisplay.y = this.y;
		fieldView.effectsContainer.addChild(damageAreaDisplay);
		Starling.juggler.tween(damageAreaDisplay, 0.5, {scale:0, onComplete:damageAreaDisplay.removeFromParent, onCompleteArgs:[true]});
	}
}

private function defaultBulletDisplayFactory() : void 
{
	bulletDisplay = new MovieClip(appModel.assets.getTextures("bullets/" + card.type + "/"))
	bulletDisplay.pivotX = bulletDisplay.width * 0.5;
	bulletDisplay.pivotY = bulletDisplay.height * 0.5;
	bulletDisplay.loop = CardTypes.isSpell(card.type);
	bulletDisplay.rotation = rotation;
	fieldView.effectsContainer.addChild(bulletDisplay);
	if( bulletDisplay.numFrames > 1 )
	{
		Starling.juggler.add(bulletDisplay);
		bulletDisplay.play();
	}
	
	shadowDisplay = new Image(appModel.assets.getTexture("troops-shadow"));
	shadowDisplay.pivotX = shadowDisplay.width * 0.5;
	shadowDisplay.pivotY = shadowDisplay.height * 0.5;
	//fieldView.unitsContainer.addChildAt(shadowDisplay, 0);
}

protected function defaultFireDisplayFactory() : void 
{
	if( CardTypes.isSpell(card.type) || card.bulletDamage < 0 || card.type == 106 || card.type == 108 || card.type == 201 )
		return;
	
	var fireOffset:Point3 = BulletFirePositionCalculator.getPoint(card.type, rotation);
	//trace("type", card.type, "  rotation", rotation, fireOffset);
	var fireDisplay:MovieClip = new MovieClip(appModel.assets.getTextures("fires/shootFire_"), 45);
	fireDisplay.pivotX = 1;
	fireDisplay.pivotY = fireDisplay.height * 0.5;
	fireDisplay.x = this.x + fireOffset.x;
	fireDisplay.y = this.y + fireOffset.y;
	fireDisplay.rotation = rotation;
	fireDisplay.width = card.sizeH * 3.5;
	fireDisplay.scaleY = fireDisplay.scaleX;
	fieldView.effectsContainer.addChild(fireDisplay);
	fireDisplay.play();
	Starling.juggler.add(fireDisplay);
	fireDisplay.addEventListener(Event.COMPLETE, function() : void { Starling.juggler.remove(fireDisplay); fireDisplay.removeFromParent(true); });
}

protected function defaultHitDisplayFactory() : void
{
	var hasDamageArea:Boolean = card.bulletDamageArea > 50 && card.bulletDamage > 0;
	if( hasDamageArea )
	{
		var textureURL:String = "hits/explosion-";
		if( card.type == CardTypes.C152 )
			textureURL = "hits/arrows-";
		
		var explosionDisplay:MovieClip = new MovieClip(appModel.assets.getTextures(textureURL), card.type == CardTypes.C152 ? 1 : 45);
		explosionDisplay.pivotX = explosionDisplay.width * 0.5;
		explosionDisplay.pivotY = explosionDisplay.height * 0.5;
		explosionDisplay.width = card.bulletDamageArea * 1.8;
		explosionDisplay.scaleY = explosionDisplay.scaleX;
		explosionDisplay.x = this.x;
		explosionDisplay.y = this.y;
		fieldView.effectsContainer.addChild(explosionDisplay);
		explosionDisplay.play();
		Starling.juggler.add(explosionDisplay);
		explosionDisplay.addEventListener(Event.COMPLETE, function() : void { Starling.juggler.remove(explosionDisplay); explosionDisplay.removeFromParent(true); });
		return;
	}

	var hitDisplay:Image = new Image(appModel.assets.getTexture("hits/hit"));
	hitDisplay.pivotX = hitDisplay.width * 0.5;
	hitDisplay.pivotY = hitDisplay.height * 0.5;
	hitDisplay.x = this.x;
	hitDisplay.y = this.y - 25;
	fieldView.effectsContainer.addChild(hitDisplay);
	Starling.juggler.tween(hitDisplay, 0.2, {scale:0, onComplete:hitDisplay.removeFromParent, onCompleteArgs:[true]});
}

protected function get appModel():		AppModel		{	return AppModel.instance;			}
protected function get fieldView():		BattleFieldView {	return appModel.battleFieldView;	}
}
}