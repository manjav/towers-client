package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gt.towers.battle.fieldes.PlaceData;
import com.gt.towers.utils.lists.PlaceDataList;
import flash.geom.Point;
import starling.display.DisplayObjectContainer;
import starling.display.Image;

public class TutorialTouchOverlay extends TutorialOverlay
{
private var handDisplay:Image;
private var context:DisplayObjectContainer;
public function TutorialTouchOverlay(task:TutorialTask, x:Number = 0, y:Number = 0, context:DisplayObjectContainer = null)
{
	if( task == null )
	{
		var pdl:PlaceDataList = new PlaceDataList();
		pdl.push(new PlaceData(0, x, y, 0, 0, null));
		task = new  TutorialTask(TutorialTask.TYPE_TOUCH, "", pdl, 100, 200);
	}
	super(task);
	this.context = context;
}

override protected function transitionInStarted():void
{
	super.transitionInStarted();
	overlay.alpha = 0;
	if( context == null )
		context = appModel.battleFieldView;
	handDisplay = new HandPoint(task.places.get(0).x, task.places.get(0).y);
	context.addChild(handDisplay);
}

override public function close(dispose:Boolean = true):void 
{
	handDisplay.removeFromParent(true);
	super.close(dispose);
}
}
}