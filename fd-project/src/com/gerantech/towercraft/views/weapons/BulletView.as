package com.gerantech.towercraft.views.weapons 
{
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.views.BattleFieldView;
import com.gt.towers.battle.BattleField;
import com.gt.towers.battle.bullets.Bullet;
import com.gt.towers.battle.units.Card;
import com.gt.towers.calculators.BulletSourceCalculator;
import flash.geom.Point;
import starling.core.Starling;
import starling.display.Image;
import starling.display.MovieClip;
import starling.events.Event;

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
	
	//appModel.sounds.addAndPlaySound(
	
	var rotation:Number = Math.atan2(x - dx, y - dy);
	
	var fireOffset:Point = BulletSourceCalculator.getPoint(card.type, rotation);
	var fireDisplay:MovieClip = new MovieClip(Assets.getTextures("fires/shootFire_", "effects"), 15);
	fireDisplay.pivotX = fireDisplay.width * 0.5;
	fireDisplay.pivotY = fireDisplay.height * 0.5;
	fireDisplay.x = this.x + fireOffset.x;
	fireDisplay.y = this.y + fireOffset.y;
	fireDisplay.rotation = rotation; trace(card.type, rotation);
	fieldView.effectsContainer.addChild(fireDisplay);
	fireDisplay.play();
	Starling.juggler.add(fireDisplay);
	fireDisplay.addEventListener(Event.COMPLETE, function() : void { Starling.juggler.remove(fireDisplay); fireDisplay.removeFromParent(true); });
	
	bulletDisplay = new Image(Assets.getTexture("bullets/" + card.type, "effects"))
	bulletDisplay.pivotX = bulletDisplay.width * 0.5;
	bulletDisplay.pivotY = bulletDisplay.height * 0.5;
	bulletDisplay.rotation = rotation;
	bulletDisplay.x = this.x;
	bulletDisplay.y = this.y - card.height;
	fieldView.effectsContainer.addChild(bulletDisplay);
	
	shadowDisplay = new Image(Assets.getTexture("troops-shadow", "troops"));
	shadowDisplay.pivotX = shadowDisplay.width * 0.5;
	shadowDisplay.pivotY = shadowDisplay.height * 0.5;
	shadowDisplay.scale = 2;
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
		bulletDisplay.y = this.y - card.health;		
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
	hitDisplay.pivotX = hitDisplay.width * 0.5;
	hitDisplay.pivotY = hitDisplay.height * 0.5;
	hitDisplay.x = this.x;
	hitDisplay.y = this.y - card.height;
	fieldView.effectsContainer.addChild(hitDisplay);
	hitDisplay.play();
	Starling.juggler.add(hitDisplay);
	hitDisplay.addEventListener(Event.COMPLETE, function() : void { Starling.juggler.remove(hitDisplay); hitDisplay.removeFromParent(true); });
	
	/*shadowDisplay.texture = Assets.getTexture("damage-range");
	shadowDisplay.width = card.bulletDamageArea * 2;
	shadowDisplay.height = card.bulletDamageArea * 1.42;
	Starling.juggler.tween(shadowDisplay, 0.5, {scale:0, onComplete:shadowDisplay.removeFromParent, onCompleteArgs:[true]});*/
	
	if( bulletDisplay != null )
		bulletDisplay.removeFromParent(true);		
	
	if( shadowDisplay != null )
		shadowDisplay.removeFromParent(true);		
}


protected function get appModel():		AppModel		{	return AppModel.instance;			}
/*protected function get game():			Game			{	return appModel.game;				}
protected function get player():		Player			{	return game.player;					}*/
protected function get fieldView():		BattleFieldView {	return appModel.battleFieldView;	}
}
}