package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gt.towers.battle.fieldes.PlaceData;
import feathers.layout.AnchorLayout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;

public class TutorialTouchOverlay extends TutorialOverlay
{
private var finger:Image;
private var place:PlaceData;
public function TutorialTouchOverlay(task:TutorialTask)
{
	super(task);
	place = task.places.get(0);
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	
	finger = new Image(Assets.getTexture("hand"));
	//finger.pivotX = finger.width  * 0.0;
	//finger.pivotY = finger.height * 0.4
	finger.rotation = 0.4;
	finger.x = place.x;
	finger.y = (place.y - 300);
	finger.touchable = false;
}
protected override function transitionInStarted():void
{
	super.transitionInStarted();
	appModel.battleFieldView.addChild(finger);
	touchFinger();
}
private function touchFinger(delay:Number=0):void
{
	Starling.juggler.tween( finger, 0.2, {delay:delay,			rotation:0.0, y:place.y - 200, scale:0.9});
	Starling.juggler.tween( finger, 0.5, {delay:delay + 0.4,	rotation:0.4, y:place.y - 300, scale:1.0, onComplete:touchFinger, onCompleteArgs:[2], transition:Transitions.EASE_OUT_BACK});
}

override public function close(dispose:Boolean = true):void 
{
	Starling.juggler.removeTweens(finger);
	finger.removeFromParent(dispose);
	super.close(dispose);
}
}
}