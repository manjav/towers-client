package com.gerantech.towercraft.managers
{
	import com.gerantech.towercraft.controls.overlays.TutorialMessageOverlay;
	import com.gerantech.towercraft.controls.overlays.TutorialOverlay;
	import com.gerantech.towercraft.controls.overlays.TutorialSwipeOverlay;
	import com.gerantech.towercraft.controls.overlays.TutorialTouchOverlay;
	import com.gerantech.towercraft.events.GameEvent;
	import com.gerantech.towercraft.models.tutorials.TutorialData;
	import com.gerantech.towercraft.models.tutorials.TutorialTask;
	
	import starling.events.Event;

	public class TutorialManager extends BaseManager
	{
		private static var _instance:TutorialManager;
		private var tutorialData:TutorialData;
		
		public function show(data:TutorialData):void
		{
			tutorialData = data;
			processTasks();
		}
		
		private function processTasks():void
		{
			var task:TutorialTask = tutorialData.shiftTask();
			if(task == null)
			{
				dispatchEventWith(GameEvent.TUTORIAL_TASKS_FINISH, false, tutorialData);
				return;
			}
			dispatchEventWith(GameEvent.SHOW_TUTORIAL, false, task);
		
			switch(task.type)
			{
				case TutorialTask.TYPE_MESSAGE:
					var messageoverlay:TutorialMessageOverlay = new TutorialMessageOverlay(task);
					messageoverlay.addEventListener(Event.CLOSE, overlay_closeHandler);
					appModel.navigator.addOverlay(messageoverlay);					
					break;
				
				case TutorialTask.TYPE_SWIPE:
					var swipeoverlay:TutorialSwipeOverlay = new TutorialSwipeOverlay(task);
					swipeoverlay.addEventListener(Event.CLOSE, overlay_closeHandler);
					appModel.navigator.addOverlay(swipeoverlay);					
					break;
				
				case TutorialTask.TYPE_TOUCH:
					var touchoverlay:TutorialTouchOverlay = new TutorialTouchOverlay(task);
					touchoverlay.addEventListener(Event.CLOSE, overlay_closeHandler);
					appModel.navigator.addOverlay(touchoverlay);					
					break;
			}

		}		
		
		private function overlay_closeHandler(event:Event):void
		{
			processTasks();
		}
		
		
		public static function get instance():TutorialManager
		{
			if(_instance == null)
				_instance = new TutorialManager();
			return _instance;
		}
		
		public function removeAll():void
		{
			while( tutorialData.numTasks > 0 )
				tutorialData.shiftTask();
			
			for(var i:uint=0; i<appModel.navigator.overlays.length; i++)
			{
				if( appModel.navigator.overlays[i] is TutorialOverlay )
				{
					trace(appModel.navigator.overlays[i])
					appModel.navigator.overlays[i].removeEventListeners(Event.CLOSE);
					appModel.navigator.overlays[i].removeFromParent(true);
					appModel.navigator.overlays.removeAt(i);
				}
			}
		}
	}
}