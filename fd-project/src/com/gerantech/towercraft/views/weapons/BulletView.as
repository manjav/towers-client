package com.gerantech.towercraft.views.weapons 
{
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.views.BattleFieldView;
import com.gt.towers.battle.BattleField;
import com.gt.towers.battle.bullets.Bullet;
import com.gt.towers.battle.units.Card;
import starling.core.Starling;
import starling.display.Image;

/**
* ...
* @author Mansour Djawadi
*/
public class BulletView extends Bullet 
{
private var shadowDisplay:Image;

public function BulletView(battleField:BattleField, id:int, card:Card, side:int, x:Number, y:Number, dx:Number, dy:Number) 
{
	super(battleField, id, card, side, x, y, dx, dy);
	
	//textureType = Math.min(108, type) + "/" + battleField.getColorIndex(side) + "/";
	
	shadowDisplay = new Image(Assets.getTexture("troops-shadow", "troops"));
	shadowDisplay.pivotX = shadowDisplay.width * 0.5;
	shadowDisplay.pivotY = shadowDisplay.height * 0.5;
	shadowDisplay.scale = 2;
	shadowDisplay.x = this.x;
	shadowDisplay.y = this.y;
	fieldView.unitsContainer.addChild(shadowDisplay);
	
	/*movieClip = new MovieClip(Assets.getTextures(textureType + "m_" + (side == battleField.side ? "000_" : "180_"), "troops"), 15);
	movieClip.pivotX = movieClip.width * 0.5;
	movieClip.pivotY = movieClip.height * 0.75;
	movieClip.scale = troopScale;
	movieClip.x = this.x;
	movieClip.y = this.y;
	fieldView.unitsContainer.addChild(movieClip);*/
}


override public function setPosition(x:Number, y:Number, forced:Boolean = false) : Boolean
{
	if( disposed )
		return false;
	
	/*var _x:Number = this.x;
	var _y:Number = this.y;*/
	if( !super.setPosition(x, y, forced) )
		return false;

/*	switchAnimation("m_", x, _x, y, _y);
	
	//state = Unit.STATE_MOVE;
	if( movieClip != null )
	{
		movieClip.x = this.x;
		movieClip.y = this.y;		
	}*/
	
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
	shadowDisplay.texture = Assets.getTexture("damage-range");
	shadowDisplay.width = card.bulletDamageArea * 2;
	shadowDisplay.height = card.bulletDamageArea * 1.42;
	Starling.juggler.tween(shadowDisplay, 0.5, {scale:0, onComplete:shadowDisplay.removeFromParent, onCompleteArgs:[true]});
	//muted = true;
	//shadowDisplay.removeFromParent(true);
	//movieClip.removeFromParent(true);
}


protected function get appModel():		AppModel		{	return AppModel.instance;			}
/*protected function get game():			Game			{	return appModel.game;				}
protected function get player():		Player			{	return game.player;					}*/
protected function get fieldView():		BattleFieldView {	return appModel.battleFieldView;	}
}
}