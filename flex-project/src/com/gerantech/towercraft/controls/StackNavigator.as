package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.models.AppModel;
	
	import feathers.controls.LayoutGroup;
	import feathers.controls.StackScreenNavigator;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.events.Event;

	public class StackNavigator extends StackScreenNavigator
	{
		public function StackNavigator()
		{
		}
		
		// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  LOGS  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
		private var logs:Vector.<GameLog>;
		private var logsContainer:LayoutGroup;
		private var busyLogger:Boolean;
		public function addLog(text:String) : void
		{
			addLogGame( new GameLog(text) );
		}
		public function addLogGame(log:GameLog) : void
		{
			if( logs == null )
			{
				logs = new Vector.<GameLog>();
				GameLog.MOVING_DISTANCE = -120 * AppModel.instance.scale
				GameLog.GAP = 80 * AppModel.instance.scale;
				logsContainer = new LayoutGroup();
				addChild(logsContainer);
			}
			if( busyLogger )
				return;
			
			busyLogger = true;
			log.y = logs.length * GameLog.GAP + stage.stageHeight/2;
			logsContainer.addChild(log);
			logs.push(log);
			Starling.juggler.tween(logsContainer, 0.3, {y : logsContainer.y - GameLog.GAP, transition:Transitions.EASE_OUT, onComplete:function():void{busyLogger=false;}});
			
			/*log.addEventListener(Event.COMPLETE, log_completeHandler);
			function log_completeHandler( event:Event ) : void
			{
				var l:GameLog = event.currentTarget as GameLog;
				loggs.removeAt(loggs.indexOf( l ));
			}*/
		}

	}
}