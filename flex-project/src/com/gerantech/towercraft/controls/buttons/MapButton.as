package com.gerantech.towercraft.controls.buttons
{
import com.gerantech.towercraft.controls.overlays.TutorialArrow;
import com.gerantech.towercraft.models.AppModel;
import feathers.events.FeathersEventType;

public class MapButton extends SimpleButton
{
private var tutorialArrow:TutorialArrow;

public function showArrow():void
{
	tutorialArrow = new TutorialArrow(false);
	tutorialArrow.addEventListener(FeathersEventType.CREATION_COMPLETE , tutorialArrow_createHandler);
	addChild(tutorialArrow);
}

private function tutorialArrow_createHandler():void
{
	tutorialArrow.removeEventListener(FeathersEventType.CREATION_COMPLETE , tutorialArrow_createHandler);
	tutorialArrow.x = -tutorialArrow.width * 0.5;
	tutorialArrow.y = -132 * AppModel.instance.scale;
}

override protected function trigger():void
{
	if( tutorialArrow != null )
		tutorialArrow.removeFromParent(true);
	super.trigger();
}
}
}