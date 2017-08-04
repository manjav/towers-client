package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.Main;
	import com.gerantech.towercraft.controls.buttons.SimpleButton;
	import com.gerantech.towercraft.controls.overlays.BaseOverlay;
	import com.gerantech.towercraft.controls.popups.BasePopup;
	import com.gerantech.towercraft.controls.popups.BugReportPopup;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	
	import mx.resources.ResourceManager;
	
	import avmplus.getQualifiedClassName;
	
	import feathers.controls.LayoutGroup;
	import feathers.controls.StackScreenNavigator;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;

	public class StackNavigator extends StackScreenNavigator
	{
		public function StackNavigator()
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		private function addedToStageHandler(event:Event):void
		{
			popups = new Vector.<BasePopup>();
			popupsContainer = new LayoutGroup();
			parent.addChild(popupsContainer);
			
			overlays = new Vector.<BaseOverlay>();
			overlaysContainer = new LayoutGroup();
			parent.addChild(overlaysContainer);
			
			logs = new Vector.<GameLog>();
			GameLog.MOVING_DISTANCE = -120 * AppModel.instance.scale
			GameLog.GAP = 80 * AppModel.instance.scale;
			logsContainer = new LayoutGroup();
			parent.addChild(logsContainer);
		}		

		// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  POPUPS  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
		private var popups:Vector.<BasePopup>;
		private var popupsContainer:LayoutGroup;
		public function addPopup(popup:BasePopup) : void
		{
			for( var i:int=0; i<popups.length; i++)
			{
				if( getQualifiedClassName(popup) == getQualifiedClassName(popups[i]) )
					return;
			}
			
			popupsContainer.addChild(popup);
			popups.push(popup);
			popup.addEventListener(Event.CLOSE, popup_closeHandler); 
			function popup_closeHandler(event:Event):void {
				var p:BasePopup = event.currentTarget as BasePopup;
				p.removeEventListener(Event.CLOSE, popup_closeHandler);
				popups.removeAt(popups.indexOf(p));
			}
		}
	
		
		// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-  OVERLAYS  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
		private var overlays:Vector.<BaseOverlay>;
		private var overlaysContainer:LayoutGroup;
		public function addOverlay(overlay:BaseOverlay) : void
		{
			for( var i:int=0; i<overlays.length; i++)
			{
				if( getQualifiedClassName(overlay) == getQualifiedClassName(overlays[i]) )
					return;
			}
			
			overlaysContainer.addChild(overlay);
			overlays.push(overlay);
			overlay.addEventListener(Event.CLOSE, overlay_closeHandler); 
			function overlay_closeHandler(event:Event):void {
				var o:BaseOverlay = event.currentTarget as BaseOverlay;
				o.removeEventListener(Event.CLOSE, overlay_closeHandler);
				overlays.removeAt(overlays.indexOf(o));
			}

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
			if( busyLogger )
				return;
			
			busyLogger = true;
			log.y = logs.length * GameLog.GAP + stage.stageHeight/2;
			logsContainer.addChild(log);
			logs.push(log);
			Starling.juggler.tween(logsContainer, 0.3, {y : logsContainer.y - GameLog.GAP, transition:Transitions.EASE_OUT, onComplete:function():void{busyLogger=false;}});
		}
		
		
		
		public function showBugReportButton():void
		{
			if( !AppModel.instance.game.player.inTutorial() )
			{
				var bugReportButton:SimpleButton = new SimpleButton();
				bugReportButton.addChild(new Image(Assets.getTexture("bug-icon", "gui")));
				bugReportButton.addEventListener(Event.TRIGGERED, bugReportButton_triggeredHandler);
				bugReportButton.x = 12 * AppModel.instance.scale;
				bugReportButton.y = stage.stageHeight - 300 * AppModel.instance.scale;
				bugReportButton.width = 120*AppModel.instance.scale;
				bugReportButton.scaleY = bugReportButton.scaleX;
				addChild(bugReportButton);
				function bugReportButton_triggeredHandler(event:Event):void {
					var reportPopup:BugReportPopup = new BugReportPopup();
					reportPopup.addEventListener(Event.COMPLETE, reportPopup_completeHandler);
					addPopup(reportPopup);
					function reportPopup_completeHandler(event:Event):void {
						var reportPopup:BugReportPopup = new BugReportPopup();
						addLog(ResourceManager.getInstance().getString("loc", "popup_bugreport_fine"));
					}
				}
				addEventListener(Event.CHANGE, changeHandler);
				function changeHandler(event:Event):void {
					addChild(bugReportButton);
					bugReportButton.y = stage.stageHeight - (activeScreenID==Main.BATTLE_SCREEN?150:300) * AppModel.instance.scale;
				}
			}
		}
	}
}