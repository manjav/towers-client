package com.gerantech.towercraft.controls.items 
{
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.events.GameEvent;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.models.tutorials.TutorialData;
	import com.gt.towers.battle.fieldes.PlaceData;
	import com.smartfoxserver.v2.core.SFSEvent;
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import flash.utils.setTimeout;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.events.Event;
/**
* ...
* @author Mansour Djawadi
*/
public class TaskListItemRenderer extends AbstractListItemRenderer
{
private var place:PlaceData;
private var checkBoxDisplay:ImageLoader;
private var messageDisplay:RTLLabel;

public function TaskListItemRenderer() {}
override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	var padding:int = 36 * appModel.scale;
	
	checkBoxDisplay = new ImageLoader();
	checkBoxDisplay.width = padding * 3;
	checkBoxDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR ? NaN : 0, NaN, appModel.isLTR ? 0 : NaN, NaN, -padding * 0.1);
	checkBoxDisplay.pixelSnapping = false;
	addChild(checkBoxDisplay);
	
	messageDisplay = new RTLLabel("", 0, null, null, false, null, 0.8);
	messageDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR ? NaN : padding * 3.5, NaN, appModel.isLTR ? padding * 3 : NaN, NaN, 0);
	addChild(messageDisplay);
	
	tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_STARTED, tutorials_tasksStartHandler);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseHandler);
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null || _owner == null )
		return;
	place = _data as PlaceData;
	messageDisplay.text = loc("tutor_battle_" + place.type + "_task_" + place.index);
	checkBoxDisplay.source = Assets.getTexture("checkbox-off", "gui");
}

private function sfs_responseHandler(event:SFSEvent):void 
{
	if( event.params.cmd != SFSCommands.END_BATTLE )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseHandler);
	if( index == 1 )
	{
		punch();
		setTimeout(owner.dispatchEventWith, 1000, GameEvent.TUTORIAL_TASKS_FINISH);
	}
}
private function tutorials_tasksStartHandler(event:Event) : void 
{
	var tutorialData:TutorialData = event.data as TutorialData;
	if( index == 0 && tutorialData.name == "occupy_1_1" )
	{
		punch();
	}
}
private function punch() : void 
{
	checkBoxDisplay.source = Assets.getTexture("checkbox-on", "gui");
	checkBoxDisplay.scale = 2;
	Starling.juggler.tween(checkBoxDisplay, 0.5, {scale:1, transition:Transitions.EASE_OUT});
}
public override function dispose() : void
{
	tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_STARTED, tutorials_tasksStartHandler);
	super.dispose();
}
}
}