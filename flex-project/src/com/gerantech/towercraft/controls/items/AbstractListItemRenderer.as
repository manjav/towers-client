package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.managers.TimeManager;
import com.gerantech.towercraft.managers.TutorialManager;
import com.gerantech.towercraft.models.AppModel;
import com.gt.towers.Game;
import com.gt.towers.Player;
import com.gt.towers.exchanges.Exchanger;

import flash.geom.Rectangle;
import flash.utils.clearInterval;
import flash.utils.setInterval;

import mx.resources.ResourceManager;

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import feathers.skins.ImageSkin;

import starling.events.Event;

public class AbstractListItemRenderer extends LayoutGroupListItemRenderer
{
public var deleyCommit:Boolean = false;
public static var FAST_COMMIT_TIMEOUT:uint = 0;
public static var SLOW_COMMIT_TIMEOUT:uint = 400;

protected var skin:ImageSkin;

private var intevalId:uint;
private var tempY:Number;
private var screenRect:Rectangle;
private var commitPhase:uint;
private var ownerBounds:Rectangle;
	
override protected function initialize():void
{
	addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler );
}

/*protected function createSkin():void
{
skin = new ImageSkin(Assets.getBackgroundTexture());
for each(var s:String in stateNames)
skin.setTextureForState(s, Assets.getBackgroundTexture(s));
skin.scale9Grid = Assets.BACKGROUND_GRID;
backgroundSkin = skin;
}*/

override protected function commitData():void
{
	super.commitData();
	if( ownerBounds == null && _owner != null )
		ownerBounds = _owner.getBounds(stage);
	
	if( deleyCommit )
	{
		clearInterval(intevalId);
		intevalId = setInterval(checkScrolling, SLOW_COMMIT_TIMEOUT);
		commitPhase = 0;
	}
}		

protected function onScreen (itemBounds:Rectangle) : Boolean
{
	if( ownerBounds == null )
		return true;
	//trace(index, ownerBounds, itemBounds.x+1, itemBounds.y+1, itemBounds.x + itemBounds.width-1, itemBounds.y + itemBounds.height-1, ownerBounds.contains(itemBounds.x+1, itemBounds.y+1) , ownerBounds.contains(itemBounds.x + itemBounds.width-1, itemBounds.y + itemBounds.height-1))
	return ownerBounds.contains(itemBounds.x+1, itemBounds.y+1) || ownerBounds.contains(itemBounds.x + itemBounds.width-1, itemBounds.y + itemBounds.height-1);
}
private function checkScrolling():void
{
	var itemBounds:Rectangle = getBounds(_owner);
	if( !onScreen(itemBounds) )
		return;
	
	var speed:Number = Math.abs(tempY - itemBounds.y);
	if( commitPhase == 0 && speed < 500 )
	{
		commitPhase = 1;
		commitBeforeStopScrolling();
	}
	else if( commitPhase == 1 && speed < 100 )
	{
		commitPhase = 2;
		clearInterval(intevalId);
		commitAfterStopScrolling();
	}
	tempY = itemBounds.y;
}		

protected function commitBeforeStopScrolling():void
{
}
protected function commitAfterStopScrolling():void
{
}

protected function removedFromStageHandler( event:Event ):void
{
	clearInterval(intevalId);
}

protected function loc(resourceName:String, parameters:Array=null, locale:String=null):String
{
	return ResourceManager.getInstance().getString("loc", resourceName, parameters, locale);
}
protected function get timeManager():	TimeManager		{	return TimeManager.instance;		}
protected function get tutorials():		TutorialManager	{	return TutorialManager.instance;	}
protected function get appModel():		AppModel		{	return AppModel.instance;			}
protected function get game():			Game			{	return appModel.game;				}
protected function get player():		Player			{	return game.player;					}
protected function get exchanger():		Exchanger		{	return game.exchanger;				}
}
}