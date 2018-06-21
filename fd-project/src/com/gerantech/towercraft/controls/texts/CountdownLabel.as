package com.gerantech.towercraft.controls.texts 
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.utils.StrUtils;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import flash.utils.setInterval;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;

/**
* ...
* @author Mansour Djawadi
*/
public class CountdownLabel extends TowersLayout 
{
private var clockDisplay:ImageLoader;
private var needleDisplay:Image;
private var labelDisplay:RTLLabel;
private var _scale:Number;
private var intervalId:uint;
private var timeoutId:uint;
private var _time:uint;
private var padding:Number;

public function CountdownLabel() { super(); height = 84 * appModel.scale;}
override protected function initialize() : void
{
	padding = height * 0.15;
	layout = new AnchorLayout();
	
	var skin:ImageLoader = new ImageLoader();
	skin.source = Assets.getTexture("theme/indicator-background", "gui");
	skin.scale9Grid = new Rectangle(8, 12, 4, 4);
	skin.layoutData = new AnchorLayoutData(padding, 0, padding * 1.5, height * 0.5);
	skin.alpha = 0.9;
	addChild(skin);
	
	clockDisplay = new ImageLoader();
	clockDisplay.source = Assets.getTexture("timer", "gui");
	clockDisplay.layoutData = new AnchorLayoutData(0, NaN, 0, 0);
	clockDisplay.height = clockDisplay.width = height;
	addChild(clockDisplay);
	
	needleDisplay = new Image(Assets.getTexture("timer-needle", "gui"));
	needleDisplay.pivotX = needleDisplay.width * 0.5;
	needleDisplay.pivotY = needleDisplay.height * 0.5;
	needleDisplay.height = height * 0.6;
	needleDisplay.scaleX = needleDisplay.scaleY;
	needleDisplay.x = height * 0.5;
	needleDisplay.y = height * 0.5;
	needleDisplay.rotation = 0.55;
	addChild(needleDisplay);
	
	labelDisplay = new RTLLabel(StrUtils.toTimeFormat(_time), 1, "center", "ltr", false, null, height / 128 / appModel.scale);
	labelDisplay.layoutData = new AnchorLayoutData(NaN, 0, NaN, height * 0.8, NaN, -6 * appModel.scale);
	addChild(labelDisplay);
	
	play();
}

public function play():void
{
	rotate();
	intervalId = setInterval(rotate, 2000);
}

public function rotate():void
{
	Starling.juggler.tween(needleDisplay, 0.5, {rotation:needleDisplay.rotation + Math.PI * 0.5, transition:Transitions.EASE_OUT_ELASTIC});
}

public function get time():uint 
{
	return _time;
}
public function set time(value:uint):void 
{
	if( _time == value )
		return;
	
	_time = value;
	if( labelDisplay != null )
		labelDisplay.text = StrUtils.toTimeFormat(_time);
}
}
}