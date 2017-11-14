package com.gerantech.towercraft.controls.overlays
{
	import com.gerantech.towercraft.controls.buttons.CustomButton;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.smartfoxserver.v2.core.SFSEvent;
	
	import flash.utils.setTimeout;
	
	import dragonBones.events.EventObject;
	import dragonBones.starling.StarlingArmatureDisplay;
	import dragonBones.starling.StarlingEvent;
	
	import feathers.layout.AnchorLayout;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.Event;

	public class WaitingOverlay extends BaseOverlay
	{
		public var ready:Boolean;
		
		private var tipDisplay:RTLLabel;
		private var cancelButton:CustomButton;
		private var waitDisplay:RTLLabel;
		private var armatureDisplay:StarlingArmatureDisplay ;
		
		public function WaitingOverlay()
		{
			super();
			BattleOutcomeOverlay.createFactionsFactory(assets_loadCompleted);
		}
		private function assets_loadCompleted():void
		{
			if( initializingStarted && stage != null )
				initialize();
		}
		
		override protected function initialize():void
		{
			closeOnStage = false;
			if( !initializingStarted )
				super.initialize();
			if( appModel.assets.isLoading )
				return;
			
			layout = new AnchorLayout();
			var padding:int = 36 * appModel.scale;
			
			if( data == "battle" )
			{
				cancelButton = new CustomButton();
				cancelButton.label = loc("cancel_button");
				cancelButton.alignPivot();
				cancelButton.style = "danger";
				cancelButton.width = 240 * appModel.scale;
				cancelButton.x = stage.stageWidth * 0.5 ;
				cancelButton.y = stage.stageHeight * 0.75;
				cancelButton.scale = 0;
				cancelButton.addEventListener(Event.TRIGGERED, cancelButton_triggeredHandler);
				addChild(cancelButton);
				Starling.juggler.tween(cancelButton, 0.5, {delay:1, scale:1, transition:Transitions.EASE_OUT_BACK});
			}
			
			waitDisplay = new RTLLabel(loc("tip_over"), 1, "center", null, false, null, 1.2);
			waitDisplay.x = padding;
			waitDisplay.y = stage.stageHeight * 0.55;
			waitDisplay.alpha = 0;
			waitDisplay.width = stage.stageWidth-padding*2;
			waitDisplay.touchable = false;
			addChild(waitDisplay);
			Starling.juggler.tween(waitDisplay, 0.5, {delay:2, alpha:1, y:stage.stageHeight*0.6, transition:Transitions.EASE_OUT_BACK});
			
			tipDisplay = new RTLLabel(loc("tip_"+Math.min(player.get_arena(0), 2)+"_"+Math.floor(Math.random()*10)), 1, "justify", null, true, "center", 0.9);
			tipDisplay.x = padding;
			tipDisplay.y = stage.stageHeight - padding*5;
			tipDisplay.width = stage.stageWidth-padding*2;
			tipDisplay.touchable = false;
			addChild(tipDisplay);
			
			armatureDisplay = BattleOutcomeOverlay.animFactory.buildArmatureDisplay("waiting");
			armatureDisplay.x = stage.stageWidth * 0.5;
			armatureDisplay.y = stage.stageHeight * 0.4;
			armatureDisplay.scale = appModel.scale;
			armatureDisplay.animation.gotoAndPlayByFrame("appear", 1, 1);
			armatureDisplay.addEventListener(EventObject.COMPLETE, armatureDisplay_completeHandler);
			addChild(armatureDisplay);
		}
		
		private function cancelButton_triggeredHandler():void
		{
			cancelButton.touchable = false;
			SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_canelResponseHandler);
			SFSConnection.instance.sendExtensionRequest(SFSCommands.CANCEL_BATTLE);
		}
		
		protected function sfs_canelResponseHandler(event:SFSEvent):void
		{
			if( event.params.cmd != SFSCommands.CANCEL_BATTLE )
				return;
			
			appModel.navigator.popToRootScreen();
			setTimeout(disappear, 400);
		}
		
		override protected function defaultOverlayFactory():DisplayObject
		{
			var overlay:DisplayObject = super.defaultOverlayFactory();
			overlay.alpha = 1;
			return overlay;
		}
		
		public function disappear():void
		{
			if( cancelButton != null )
			Starling.juggler.tween(cancelButton, 0.5, {delay:0.1, scale:0, transition:Transitions.EASE_IN_BACK});
			Starling.juggler.tween(waitDisplay, 0.4, {alpha:0, y:waitDisplay.y-height*0.1, transition:Transitions.EASE_IN_BACK});

			armatureDisplay.animation.gotoAndPlayByFrame("disappear", 1, 1);
			armatureDisplay.addEventListener(EventObject.COMPLETE, armatureDisplay_completeHandler);
		}
		
		protected function armatureDisplay_completeHandler(event:StarlingEvent):void
		{
			armatureDisplay.removeEventListener(EventObject.COMPLETE, armatureDisplay_completeHandler);
			if(event.eventObject.animationState.name == "appear")
			{
				ready = true;
				dispatchEventWith(Event.READY);
			}
			else if(event.eventObject.animationState.name == "disappear")
			{
				close(false);
			}
		}	
	}
}