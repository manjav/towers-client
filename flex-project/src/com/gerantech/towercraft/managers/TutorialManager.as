package com.gerantech.towercraft.managers
{
	import com.gerantech.towercraft.controls.overlays.TutorialMessageOverlay;
	import com.gerantech.towercraft.controls.overlays.TutorialSwipeOverlay;
	import com.gerantech.towercraft.controls.overlays.TutorialTouchOverlay;
	import com.gerantech.towercraft.controls.screens.BaseCustomScreen;
	import com.gerantech.towercraft.events.GameEvent;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.tutorials.TutorialData;
	import com.gerantech.towercraft.models.tutorials.TutorialTask;
	import com.gt.towers.Game;
	import com.gt.towers.Player;
	
	import mx.resources.ResourceManager;
	
	import feathers.controls.LayoutGroup;
	
	import starling.events.Event;
	import starling.events.EventDispatcher;

	public class TutorialManager extends EventDispatcher
	{
		private static var _instance:TutorialManager;
		private var tutorialData:TutorialData;
		private var containaer:LayoutGroup;
		
		public function show(containaer:LayoutGroup, data:TutorialData):void
		{
			this.containaer = containaer;
			tutorialData = data;
			processTasks();
		}
		
		private function processTasks():void
		{
			var task:TutorialTask = tutorialData.tasks.shift();
			if(task == null)
			{
				dispatchEventWith(GameEvent.TUTORIAL_TASKS_FINISH, false, tutorialData);
				return;
			}
			
			switch(task.type)
			{
				case TutorialTask.TYPE_MESSAGE:
					var messageoverlay:TutorialMessageOverlay = new TutorialMessageOverlay(task);
					messageoverlay.addEventListener(Event.CLOSE, overlay_closeHandler);
					containaer.addChild(messageoverlay);					
					break;
				
				case TutorialTask.TYPE_SWIPE:
					var swipeoverlay:TutorialSwipeOverlay = new TutorialSwipeOverlay(task);
					swipeoverlay.addEventListener(Event.CLOSE, overlay_closeHandler);
					containaer.addChild(swipeoverlay);					
					break;
				
				case TutorialTask.TYPE_TOUCH:
					var touchoverlay:TutorialTouchOverlay = new TutorialTouchOverlay(task);
					touchoverlay.addEventListener(Event.CLOSE, overlay_closeHandler);
					containaer.addChild(touchoverlay);					
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
		
		
		protected function loc(resourceName:String, parameters:Array=null, locale:String=null):String
		{
			return ResourceManager.getInstance().getString("loc", resourceName, parameters, locale);
		}
		protected function get appModel():		AppModel		{	return AppModel.instance;		}
		protected function get core():			Game			{	return Game.get_instance();		}
		protected function get player():		Player			{	return core.get_player();		}
	}
}