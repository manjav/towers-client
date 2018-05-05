package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.tooltips.ConfirmTooltip;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;
import feathers.layout.VerticalAlign;
import flash.geom.Rectangle;
import starling.events.Event;
import starling.events.TouchEvent;

public class TutorialMessageOverlay extends TutorialOverlay
{
private var side:int;
public function TutorialMessageOverlay(task:TutorialTask):void
{
	super(task);
	side = int(task.data) % 2;
}

override protected function transitionInCompleted():void
{
	super.transitionInCompleted();
	appModel.sounds.addAndPlaySound("whoosh");
	overlay.touchable = true;
	
	var charachter:ImageLoader = new ImageLoader();
	charachter.source =  Assets.getTexture("chars/char-" + side, "gui");
	charachter.verticalAlign = VerticalAlign.BOTTOM;
	charachter.layoutData = new AnchorLayoutData(NaN, side == 0?NaN:0, 0, side == 0?0:NaN);
	charachter.height = stage.stageHeight * (side == 0?0.45:0.5);
	charachter.touchable = false;
	addChild(charachter);
	
	var msg:String = loc(task.message);
	if( msg == null )
		msg = task.message;
	
	var position:Rectangle = new Rectangle(width * (side == 0?0.20:0.65), height * (side == 0?0.5:0.5), 1, 1);
	var tootlip:ConfirmTooltip = new ConfirmTooltip(msg, position, 1, 0.75, task.type == TutorialTask.TYPE_CONFIRM);
	tootlip.addEventListener(Event.SELECT, tootlip_eventsHandler); 
	tootlip.addEventListener(Event.CANCEL, tootlip_eventsHandler); 
	addChild(tootlip);
}
private function tootlip_eventsHandler(event:Event):void
{
	dispatchEventWith(event.type);
	ConfirmTooltip(event.currentTarget).close();
	close();
}
override protected function stage_touchHandler(event:TouchEvent):void
{
	//if( !_isEnabled || task.type == TutorialTask.TYPE_CONFIRM )
		return;
	super.stage_touchHandler(event);
}
}
}