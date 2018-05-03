package com.gerantech.towercraft.views.decorators 
{
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.views.PlaceView;
import com.gt.towers.constants.TroopType;
import starling.display.Image;
import starling.events.Event;
import starling.animation.Transitions;
import starling.core.Starling;
/**
 * ...
 * @author Mansour Djawadi
 */
public class TutorialDecorator extends BaseDecorator
{
private var aim:Image;
public function TutorialDecorator(placeView:PlaceView) 
{
	super(placeView);
	tutorials.addEventListener(GameEvent.TUTORIAL_TASK_SHOWN, tutorials_eventsHandler);
}
override protected function update(population:int, troopType:int, occupied:Boolean) : void
{
	super.update(population, troopType, occupied);
	if( occupied )
		removeAim();
}

private function tutorials_eventsHandler(event:Event) : void 
{
	var task:TutorialTask = event.data as TutorialTask;
	if( task == null )
		return;
	
	// aim to last swiped point
	if( task.type == TutorialTask.TYPE_SWIPE && task.places.get(task.places.size() - 1).index == place.index )
		addAim(true);

	// buildings color tutorial
	if( place.building.troopType != -1 )
	{
		if( task.message == "tutor_battle_1_start_0" )
			addAim();
		else if( task.message == "tutor_battle_1_start_2" )
			removeAim();
	}
}
private function addAim(fightMode:Boolean = false) : void
{
	if( aim != null )
		return;
	aim = new Image(Assets.getTexture("aim"));
	aim.touchable = false;
	aim.x = place.x;
	aim.y = place.y;
	aim.alignPivot();
	aim.alpha = 0;
	aim.scale = 2;
	aim.color = fightMode ? 0xFF0000 : TroopType.getColor(place.building.troopType);
	fieldView.elementsContainer.addChild(aim);
	Starling.juggler.tween(aim, 1.6, {delay:1, alpha:1, scale:0.8, transition:Transitions.EASE_OUT, repeatCount:50});
}
private function removeAim() : void
{
	if( aim == null )
		return;
	Starling.juggler.removeTweens(aim);
	aim.removeFromParent(true);
	aim = null;
}
override public function dispose():void 
{
	tutorials.removeEventListener(GameEvent.TUTORIAL_TASK_SHOWN, tutorials_eventsHandler);
	super.dispose();
}
}
}