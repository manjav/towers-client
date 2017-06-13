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
			closable = false;
			setTimeout(function():void{closable = true}, task.skipableAfter);
		}
		
		public override function get closable():Boolean
		{
			return stage.touchable;
		}
		public override function set closable(value:Boolean):void
		{
			stage.touchable = value;
		}
	}
	
}