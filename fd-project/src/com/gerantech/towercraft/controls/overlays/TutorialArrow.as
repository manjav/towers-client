package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.TowersLayout;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;

public class TutorialArrow extends TowersLayout
{
private var isUp:Boolean;
private var arrow:Image;
public var _height:Number;

public function TutorialArrow(isUp:Boolean = true)
{
	scale = appModel.scale;
	this.isUp = isUp;
	arrow = new Image(isUp ? appModel.theme.buttonForwardUpSkinTexture : appModel.theme.buttonBackUpSkinTexture);
	arrow.pivotY = isUp ? 0 : arrow.height;
	addChild(arrow);
	_height = arrow.height;
}

override protected function initialize():void
{
	super.initialize();
	animation_0();
}

private function animation_0():void
{
	Starling.juggler.tween(arrow, 0.5, {delay:0.3, y:_height * (isUp?0.2:-0.2), transition:Transitions.EASE_IN_OUT, onComplete:animation_1});
}
private function animation_1():void
{
	Starling.juggler.tween(arrow, 0.5, {delay:0.4, y:_height * (isUp?0.1:-0.1), height:_height*1.1, transition:Transitions.EASE_IN, onComplete:animation_2});
}
private function animation_2():void
{
	Starling.juggler.tween(arrow, 0.5, {y:0, height:_height, transition:Transitions.EASE_OUT_BACK, onComplete:animation_0});
}
}
}