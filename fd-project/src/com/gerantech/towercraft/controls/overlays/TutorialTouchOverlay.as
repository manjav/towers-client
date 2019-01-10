package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import feathers.layout.AnchorLayout;
import flash.geom.Point;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.DisplayObjectContainer;
import starling.display.Image;

public class TutorialTouchOverlay extends TutorialOverlay
{
public var context:DisplayObjectContainer;
private var finger:Image;
private var point:Point;
public function TutorialTouchOverlay(task:TutorialTask)
{
	super(task);
	point = task.points[0];
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	
	finger = new Image(Assets.getTexture("hand"));
	//finger.pivotX = finger.width  * 0.0;
	//finger.pivotY = finger.height * 0.4
	finger.rotation = 0.4;
	finger.x = point.x;
	finger.y = (point.y - 300);
	finger.touchable = false;
	if( context == null )
		context = appModel.battleFieldView;
}
protected override function transitionInStarted():void
{
	super.transitionInStarted();
	context.addChild(finger);
	touchFinger();
}
private function touchFinger(delay:Number=0):void
{
	Starling.juggler.tween( finger, 0.2, {delay:delay,			rotation:0.0, y:point.y - 200, scale:0.9});
	Starling.juggler.tween( finger, 0.5, {delay:delay + 0.4,	rotation:0.4, y:point.y - 300, scale:1.0, onComplete:touchFinger, onCompleteArgs:[2], transition:Transitions.EASE_OUT_BACK});
}

override public function close(dispose:Boolean = true):void 
{
	Starling.juggler.removeTweens(finger);
	finger.removeFromParent(dispose);
	super.close(dispose);
}
}
}