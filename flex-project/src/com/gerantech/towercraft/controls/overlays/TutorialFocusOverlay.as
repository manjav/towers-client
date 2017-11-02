package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.models.Assets;

import flash.geom.Rectangle;
import flash.utils.setTimeout;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class TutorialFocusOverlay extends TowersLayout
{
private var rect:Rectangle;
private var delay:Number;
private var gap:Number;
private var time:Number;

public function TutorialFocusOverlay(rect:Rectangle, time:Number=1.5, delay:Number=1, gap:Number=1)
{
	this.rect = rect;
	this.time = time;
	this.delay = delay;
	this.gap = gap;
	touchable = false;
	addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
}

private function addedToStageHandler(event:Event):void
{
	removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	
	var skin:Image = new Image(Assets.getTexture("theme/focus-rect", "gui"));
	skin.scale9Grid = new Rectangle(7,6,2,2);
	backgroundSkin = skin;
	setTimeout(focusNow, delay);
}

private function focusNow():void
{
	x = -10;
	y = -10;
	width = stage.stageWidth+20;
	height = stage.stageHeight+20;
	Starling.juggler.tween( this, time, {delay:gap, x:rect.x, y:rect.y, width:rect.width, height:rect.height, onComplete:focusNow, transition:Transitions.EASE_IN_OUT});
}

override public function dispose():void
{
	Starling.juggler.removeTweens(this);
	super.dispose();
}
}
}