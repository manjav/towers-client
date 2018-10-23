package com.gerantech.towercraft.controls 
{
import com.gerantech.towercraft.models.Assets;
import feathers.controls.LayoutGroup;
import feathers.events.FeathersEventType;
import flash.geom.Rectangle;
import starling.events.Event;
import flash.geom.Point;
import starling.display.Image;

/**
* ...
* @author Mansour Djawadi
*/
public class TileBackground extends TowersLayout 
{
private var tiledBG:Image;
private var movingSpeed:Number;
public function TileBackground(image:String, movingSpeed:Number = 0.05) 
{
	this.movingSpeed = movingSpeed;
	tiledBG = new Image(Assets.getTexture(image, "gui"));
	tiledBG.tileGrid = new Rectangle(0, 0, tiledBG.width, tiledBG.height);
	tiledBG.alpha = 0.1;
	tiledBG.pixelSnapping = false;
	addChild(tiledBG);
	
	addEventListener(FeathersEventType.CREATION_COMPLETE, creationCompleteHandler);
}

protected function creationCompleteHandler(e:Event):void 
{
	removeEventListener(FeathersEventType.CREATION_COMPLETE, creationCompleteHandler);
	tiledBG.x = -tiledBG.tileGrid.width;
	tiledBG.y = 0;
	tiledBG.width = width + tiledBG.tileGrid.width;
	tiledBG.height = height + tiledBG.tileGrid.height;
	if( timeManager != null )
		timeManager.addEventListener(Event.UPDATE, timeManager_updateHandler);
}

protected function timeManager_updateHandler(e:Event):void 
{
	if( tiledBG.x > 0 )
		tiledBG.x = -tiledBG.tileGrid.width;
	if( tiledBG.y < -tiledBG.tileGrid.height )
		tiledBG.y = 0;
	
	var delta:Number = e.data as int;
	tiledBG.x += movingSpeed * delta;
	tiledBG.y -= movingSpeed * delta;
}
override public function dispose() : void
{
	if( timeManager != null )
		timeManager.removeEventListener(Event.UPDATE, timeManager_updateHandler);
	super.dispose();
}
}
}