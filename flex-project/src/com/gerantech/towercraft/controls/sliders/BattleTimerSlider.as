package com.gerantech.towercraft.controls.sliders
{
import com.gerantech.towercraft.controls.StarCheck;
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.items.TimerIcon;

import flash.utils.clearTimeout;

import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;

import starling.core.Starling;

public class BattleTimerSlider extends TowersLayout
{
private var timeoutId:uint;
private var progressBar:Slider;
public var iconDisplay:TimerIcon;
private var stars:Vector.<StarCheck>;
private var _value:Number = 0;

public function BattleTimerSlider()
{
	super();
}

override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	width = 280 * appModel.scale;
	height = 72 * appModel.scale;

	progressBar = new Slider();
	progressBar.value = 1;
	progressBar.isEnabled = false;
	progressBar.horizontalAlign = HorizontalAlign.RIGHT;
	progressBar.layoutData = new AnchorLayoutData (0,0,0,0);
	addChild(progressBar)

	iconDisplay = new TimerIcon();
	iconDisplay.width = iconDisplay.height = height * 2.0;
	iconDisplay.x = width;
	iconDisplay.y = height * 0.5;
	//iconDisplay.layoutData = new AnchorLayoutData (NaN, -height/2, NaN, NaN, NaN, 0);
	addChild(iconDisplay);
	
	stars = new Vector.<StarCheck>();
	for ( var i:int=0; i<3; i++ )
	{
		var star:StarCheck = new StarCheck();
		star.width = star.height = height * 0.85;
		star.x = i * (width-height) * 0.33 + height * 0.25;
		star.y = height * 0.05;
		addChild(star)
		stars.push(star);
	}
	stars.reverse();
}

public function get value():Number
{
	return _value;
}
public function set value(newValue:Number):void
{
	if( _value == newValue )
		return;
	if( newValue < 0 )
		newValue = 0;
	if( maximum == 0 )
		return;
	try {
	progressBar.value = _value = Math.max(0, Math.min( newValue, maximum ) );
	} catch(e:Error){trace(e.message);}
}

public function get minimum():Number
{
	return progressBar.minimum;
}
public function set minimum(value:Number):void
{
	progressBar.minimum = value;
}

public function get maximum():Number
{
	return progressBar.maximum;
}
public function set maximum(value:Number):void
{
	progressBar.maximum = value;
}


public function enableStars(score:int):void
{
	for ( var i:int=0; i<stars.length; i++ )
	{
		stars[i].isEnabled = score >= i;
		stars[i].alpha = 0;
		Starling.juggler.tween(stars[i], 0.3, {delay:i/10, alpha:1});
	}
	if( score == 0 )
		iconDisplay.punch();
}

override public function dispose():void
{
	clearTimeout(timeoutId);
	Starling.juggler.removeTweens(iconDisplay);
	super.dispose();
}
}
}