package com.gerantech.towercraft.controls.overlays
{
	import com.gerantech.towercraft.models.tutorials.TutorialTask;
	
	import flash.utils.setTimeout;
	
	import starling.events.Event;

	public class TutorialOverlay extends BaseOverlay
	{
		protected var task:TutorialTask;
		
		public function TutorialOverlay(task:TutorialTask)
		{
			super();
			this.task = task;
		}
		
		protected override function addedToStageHandler(event:Event):void
		{
			super.addedToStageHandler(event);
			closeOnStage = false;
			setTimeout(function():void{closeOnStage = true}, task.skipableAfter);
		}
		
		public override function get closeOnStage():Boolean
		{
			return stage.touchable;
		}
		public override function set closeOnStage(value:Boolean):void
		{
			if(stage)
				stage.touchable = value;
		}
	}
	
}