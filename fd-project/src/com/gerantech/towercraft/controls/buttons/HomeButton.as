package com.gerantech.towercraft.controls.buttons
{
import com.gerantech.towercraft.controls.overlays.TutorialArrow;
import com.gerantech.towercraft.models.AppModel;
import feathers.controls.ButtonState;
import feathers.events.FeathersEventType;
import starling.display.DisplayObject;

public class HomeButton extends SimpleButton
{
private var tutorialArrow:TutorialArrow;

public function HomeButton(icon:DisplayObject, iconScale:Number=1)
{
	icon.alignPivot();
	icon.scale = 2 * iconScale;
	addChild(icon);
}

public function showArrow():void
{
	if( tutorialArrow != null )
		return;
	tutorialArrow = new TutorialArrow(false);
	tutorialArrow.addEventListener(FeathersEventType.CREATION_COMPLETE , tutorialArrow_createHandler);
	addChild(tutorialArrow);
}

private function tutorialArrow_createHandler():void
{
	tutorialArrow.removeEventListener(FeathersEventType.CREATION_COMPLETE , tutorialArrow_createHandler);
	tutorialArrow.x = -tutorialArrow.width * 0.5;
	tutorialArrow.y = -60;
}

override public function set currentState(value:String):void
{
	super.currentState = value;
	scale = value == ButtonState.DOWN ? 0.9 : 1;
}

override protected function trigger():void
{
	if( tutorialArrow != null )
		tutorialArrow.removeFromParent(true);
	tutorialArrow = null;
	super.trigger();
}
}
}