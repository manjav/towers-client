package com.gerantech.towercraft.views.weapons 
{
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.views.BattleFieldView;
import com.gt.towers.battle.BattleField;
import com.gt.towers.battle.bullets.Bullet;
import com.gt.towers.battle.units.Card;
import com.gt.towers.calculators.BulletFirePositionCalculator;
import com.gt.towers.utils.CoreUtils;
import flash.geom.Point;
import starling.core.Starling;
import starling.display.DisplayObject;
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
public var fireDisplayFactory:Function;
public var hitDisplayFactory:Function;
private var shadowDisplay:Image;
private var bulletDisplay:Image;
private var rotation:Number;

public function BulletView(battleField:BattleField, id:int, card:Card, side:int, x:Number, y:Number, dx:Number, dy:Number) 
{
	super(battleField, id, card, side, x, y, dx, dy);
	
	appModel.sounds.addAndPlaySound(card.type + "-shoot");
	
	rotation = MathUtil.normalizeAngle( -Math.atan2(x - dx, y - dy));

	bulletDisplay = new Image(Assets.getTexture("bullets/" + card.type, "effects"))
	bulletDisplay.pivotX = bulletDisplay.width * 0.5;
	bulletDisplay.pivotY = bulletDisplay.height * 0.5;
	bulletDisplay.rotation = rotation;
	bulletDisplay.x = this.x;
	bulletDisplay.y = this.y - card.sizeV;
	fieldView.effectsContainer.addChild(bulletDisplay);
	
	shadowDisplay = new Image(Assets.getTexture("troops-shadow", "troops"));
	shadowDisplay.pivotX = shadowDisplay.width * 0.5;
	shadowDisplay.pivotY = shadowDisplay.height * 0.5;
	shadowDisplay.x = this.x;
	shadowDisplay.y = this.y;
	fieldView.unitsContainer.addChildAt(shadowDisplay, 0);
	
	if( fireDisplayFactory == null )
		fireDisplayFactory = defaultFireDisplayFactory;
		
	if( hitDisplayFactory == null )
		hitDisplayFactory = defaultHitDisplayFactory;
}

override public function setPosition(x:Number, y:Number, forced:Boolean = false) : Boolean
{
	if( disposed )
		return false;
	
	if( !super.setPosition(x, y, forced) )
		return false;

	if( bulletDisplay != null )
	{
		bulletDisplay.x = this.x;
		bulletDisplay.y = this.y - card.sizeV * 0.65;		
	}
	
	if( shadowDisplay != null )
	{
		shadowDisplay.x = this.x;
		shadowDisplay.y = this.y;		
	}

	return true;
}

override public function dispose():void
{
	super.dispose();
	
	hitDisplayFactory();
	
	if( BattleFieldView.DEBUG_MODE )
	{
		shadowDisplay.texture = Assets.getTexture("damage-range");
		shadowDisplay.width = card.bulletDamageArea * 2;
		shadowDisplay.height = card.bulletDamageArea * 1.42;
		shadowDisplay.x = this.x;
		shadowDisplay.y = this.y;
		fieldView.effectsContainer.addChild(shadowDisplay);
		Starling.juggler.tween(shadowDisplay, 0.5, {scale:0, onComplete:shadowDisplay.removeFromParent, onCompleteArgs:[true]});
	}
	else
	{
		if( shadowDisplay != null )
			shadowDisplay.removeFromParent(true);
	}
	
	if( bulletDisplay != null )
		bulletDisplay.removeFromParent(true);
}

protected function defaultFireDisplayFactory() : void 
{
	if( card.type == 106 || card.type == 108 || card.type == 201 )
		return;
	
	var fireOffset:Point = BulletFirePositionCalculator.getPoint(card.type, rotation);
	//trace("type", card.type, "  rotation", rotation, CoreUtils.getRadString(rotation), " ", fireOffset);
	var fireDisplay:MovieClip = new MovieClip(Assets.getTextures("fires/shootFire_", "effects"), 45);
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
	var isExplosive:Boolean = card.type == 104 || card.type == 105 || card.type == 106;
	
	if( isExplosive )
	{
		var explosionDisplay:MovieClip = new MovieClip(Assets.getTextures("hits/explosion-", "effects"), 45);
		explosionDisplay.pivotX = explosionDisplay.width * 0.5;
		explosionDisplay.pivotY = explosionDisplay.height * 0.5;
		explosionDisplay.width = card.bulletDamageArea * 3.00;
		explosionDisplay.scaleY = explosionDisplay.scaleX;
		explosionDisplay.x = this.x;
		explosionDisplay.y = this.y;
		fieldView.effectsContainer.addChild(explosionDisplay);
		explosionDisplay.play();
		Starling.juggler.add(explosionDisplay);
		explosionDisplay.addEventListener(Event.COMPLETE, function() : void { Starling.juggler.remove(explosionDisplay); explosionDisplay.removeFromParent(true); });
		return;
	}

	var hitDisplay:Image = new Image(Assets.getTexture("hits/hit", "effects"));
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