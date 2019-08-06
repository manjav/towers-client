package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.tooltips.ConfirmTooltip;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import feathers.controls.ImageLoader;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;
import feathers.layout.VerticalAlign;
import flash.geom.Rectangle;
import starling.events.Event;
import starling.events.TouchEvent;

public class TutorialMessageOverlay extends TutorialOverlay
{
protected var side:int;
private var mentorImageLoaded:Boolean;
public function TutorialMessageOverlay(task:TutorialTask):void
{
	super(task);
	side = int(task.data) % 2;
}

override protected function transitionInCompleted():void
{
	super.transitionInCompleted();
	appModel.sounds.addAndPlay("whoosh");
	overlay.touchable = true;
	
	var charachter:ImageLoader = new ImageLoader();
	charachter.source =  Assets.getTexture("chars/char-" + side, "gui");
	charachter.verticalAlign = VerticalAlign.BOTTOM;
	charachter.layoutData = new AnchorLayoutData(NaN, side == 0?NaN:0, 0, side == 0?0:NaN);
	charachter.height = stage.stageHeight * (side == 0?0.4:0.5);
    charachter.addEventListener(FeathersEventType.CREATION_COMPLETE, character_completeHandler);
	charachter.touchable = false;
	addChild(charachter);
}

protected function character_completeHandler(event:Event):void 
{
	var charachter:ImageLoader = event.currentTarget as ImageLoader;
	charachter.removeEventListener(FeathersEventType.CREATION_COMPLETE, character_completeHandler);

	var position:Rectangle = new Rectangle(stage.stageWidth * (side == 0?0.20:0.8), height - charachter.height - 100, 1, 1);
	var tootlip:ConfirmTooltip = new ConfirmTooltip( loc(task.message), position, 1, 0.75, task.type == TutorialTask.TYPE_CONFIRM);
	tootlip.addEventListener(Event.SELECT, tootlip_eventsHandler); 
	tootlip.addEventListener(Event.CANCEL, tootlip_eventsHandler); 
	addChild(tootlip);
}

protected function tootlip_eventsHandler(event:Event):void
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