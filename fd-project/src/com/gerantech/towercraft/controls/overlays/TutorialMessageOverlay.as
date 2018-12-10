package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.tooltips.ConfirmTooltip;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;
import feathers.layout.VerticalAlign;
import flash.filesystem.File;
import flash.geom.Rectangle;
import starling.events.Event;
import starling.events.TouchEvent;

public class TutorialMessageOverlay extends TutorialOverlay
{
private var side:int;
private var mentorImageLoaded:Boolean;
public function TutorialMessageOverlay(task:TutorialTask):void
{
	super(task);
	side = int(task.data) % 2;
	appModel.assets.enqueue( File.applicationDirectory.resolvePath("assets/images/gui") );
	appModel.assets.loadQueue(assetManagerLoaded);
}

private function assetManagerLoaded(ratio:Number):void 
{
	if( ratio < 1 )
		return;
	mentorImageLoaded = true;
	if( transitionState < TransitionData.STATE_IN_COMPLETED )
		return;
}

override protected function transitionInCompleted():void
{
	super.transitionInCompleted();
	if( !mentorImageLoaded )
		return;
	
	appModel.sounds.addAndPlaySound("whoosh");
	overlay.touchable = true;
	
	var charachter:ImageLoader = new ImageLoader();
	charachter.source =  Assets.getTexture("chars/char-" + side, "gui");
	charachter.verticalAlign = VerticalAlign.BOTTOM;
	charachter.layoutData = new AnchorLayoutData(NaN, side == 0?NaN:0, 0, side == 0?0:NaN);
	charachter.height = stage.stageHeight * (side == 0?0.45:0.5);
	charachter.touchable = false;
	addChild(charachter);
	
	var position:Rectangle = new Rectangle(width * (side == 0?0.20:0.8), height * (side == 0?0.5:0.5), 1, 1);
	var tootlip:ConfirmTooltip = new ConfirmTooltip( loc(task.message), position, 1, 0.75, task.type == TutorialTask.TYPE_CONFIRM);
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