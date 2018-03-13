package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.models.Assets;

import flash.utils.clearInterval;
import flash.utils.clearTimeout;
import flash.utils.setInterval;
import flash.utils.setTimeout;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;

public class TimerIcon extends Sprite
{
private var background:Image;
private var needle:Image;
private var _scale:Number;

private var intervalId:uint;
private var timeoutId:uint;

public function TimerIcon()
{
	background =  new Image(Assets.getTexture("timer", "gui"));
	background.pivotX = background.width/2;
	background.pivotY = background.height/2;
	addChild(background);
	
	needle = new Image(Assets.getTexture("timer-needle", "gui"));
	needle.pivotX = needle.width/2;
	needle.pivotY = needle.height/2;
	needle.rotation = 0.47;
	addChild(needle);
	
	play()
}

public function play():void
{
	rotate();
	intervalId = setInterval(rotate, 1000);
}

public function rotate():void
{
	Starling.juggler.tween(needle, 0.5, {rotation:needle.rotation+Math.PI*0.5, transition:Transitions.EASE_OUT_ELASTIC});
}

public function punch():void
{
	_scale = scale;
	timeoutId = setTimeout(animatePunchScale, 1000+Math.random()*1000);
}
private function animatePunchScale():void
{
	Starling.juggler.tween(this, 0.5, {scale:_scale, transition:Transitions.EASE_OUT_BACK, onComplete:punch});
	scale = _scale * 1.5;
}		

public function stop():void
{
	clearInterval(intervalId);
	clearTimeout(timeoutId);
	Starling.juggler.removeTweens(background);
	Starling.juggler.removeTweens(this);
}
override public function dispose():void
{
	stop();
	super.dispose();
}
}
}