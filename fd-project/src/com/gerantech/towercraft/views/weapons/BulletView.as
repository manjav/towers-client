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
private var shadowDisplay:Image;
private var bulletDisplay:Image;

public function BulletView(battleField:BattleField, id:int, card:Card, side:int, x:Number, y:Number, dx:Number, dy:Number) 
{
	super(battleField, id, card, side, x, y, dx, dy);
	
	appModel.sounds.addAndPlaySound(card.type + "-shoot");
	
	var rotation:Number = MathUtil.normalizeAngle( -Math.atan2(x - dx, y - dy));// - 1.5708;
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
	shadowDisplay.width = card.sizeH * 2;
	shadowDisplay.height = card.sizeH * 1.42;
	shadowDisplay.x = this.x;
	shadowDisplay.y = this.y;
	fieldView.unitsContainer.addChildAt(shadowDisplay, 0);
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
		bulletDisplay.y = this.y - card.sizeV;		
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
	
	var hitDisplay:MovieClip = new MovieClip(Assets.getTextures("hits/hit_effect_", "effects"), 15);
	hitDisplay.scale = 0.4;
	hitDisplay.pivotX = hitDisplay.width * 0.5;
	hitDisplay.pivotY = hitDisplay.height * 0.5;
	hitDisplay.x = this.x;
	hitDisplay.y = this.y - card.sizeV;
	fieldView.effectsContainer.addChild(hitDisplay);
	hitDisplay.play();
	Starling.juggler.add(hitDisplay);
	hitDisplay.addEventListener(Event.COMPLETE, function() : void { Starling.juggler.remove(hitDisplay); hitDisplay.removeFromParent(true); });
	
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

protected function get appModel():		AppModel		{	return AppModel.instance;			}
protected function get fieldView():		BattleFieldView {	return appModel.battleFieldView;	}
}
}