package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.items.TaskListItemRenderer;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.controls.List;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.VerticalAlign;
import starling.events.Event;
import flash.geom.Rectangle;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;

public class TutorialTaskOverlay extends TutorialOverlay
{
private var taskList:feathers.controls.List;
public function TutorialTaskOverlay(task:TutorialTask):void
{
	super(task);
	hasOverlay = false;
	_isEnabled = false;
}

override protected function transitionInCompleted():void
{
	super.transitionInCompleted();
	appModel.sounds.addAndPlaySound("whoosh");
	touchable = false;
	
	var padding:int = 20 * appModel.scale;
	layout = new AnchorLayout();
	
	// balloon
	var balloon:LayoutGroup = new LayoutGroup();
	balloon.height = padding * 14;
	balloon.layout = new AnchorLayout();
	balloon.alpha = 0;
	balloon.y = padding * 2;
	balloon.layoutData = new AnchorLayoutData(NaN, padding, NaN, padding * 5);
	addChild( balloon );
	
	var skin:Image = new Image(Assets.getTexture("tooltip-bg-bot-left", "gui"));
	skin.scale9Grid = new Rectangle(18, 7, 1, 1);
	balloon.backgroundSkin = skin;
	
	// task list
	taskList = new List();
	taskList.itemRendererFactory = function ():IListItemRenderer { return new TaskListItemRenderer(); };
	taskList.dataProvider = new ListCollection(task.places._list);
	taskList.layoutData = new AnchorLayoutData(padding, padding * 0.1, padding, padding);
	taskList.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, taskList_taskFinishHandler);
	balloon.addChild( taskList );
	
	var charachter:ImageLoader = new ImageLoader();
	charachter.source =  Assets.getTexture("chars/char-small-0", "gui");
	charachter.layoutData = new AnchorLayoutData(NaN, NaN, NaN, padding);
	charachter.width = charachter.height = padding * 12;
	charachter.y = padding * 16;
	charachter.alpha = 0;
	addChild(charachter);
	
	Starling.juggler.tween(charachter, 0.5, {delay:0, y:padding * 16, alpha:1, transition:Transitions.EASE_OUT});
	Starling.juggler.tween(balloon, 0.5, {delay:0.2, y:padding * 1.0, alpha:1, transition:Transitions.EASE_OUT});
}

private function taskList_taskFinishHandler(event:Event):void 
{
	close();
}
}
}