package com.gerantech.towercraft.controls.overlays
{
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	
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
		
		private var armatureDisplay:StarlingArmatureDisplay ;
		private var tipDisplay:RTLLabel;
		
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
			
			var waitDisplay:RTLLabel = new RTLLabel(loc("tip_over"), 1, "center", null, false, null, 1.2);
			waitDisplay.x = padding;
			waitDisplay.y = stage.stageHeight * 0.6;
			waitDisplay.alpha = 0;
			waitDisplay.width = stage.stageWidth-padding*2;
			waitDisplay.touchable = false;
			addChild(waitDisplay);
			Starling.juggler.tween(waitDisplay, 0.5, {delay:2, alpha:1, y:stage.stageHeight*0.7, transition:Transitions.EASE_OUT_BACK});
			
			tipDisplay = new RTLLabel(loc("tip_"+Math.min(player.get_arena(0), 2)+"_"+Math.floor(Math.random()*10)), 1, "justify", null, true, "center", 0.9);
			tipDisplay.x = padding;
			tipDisplay.y = stage.stageHeight - padding*5;
			tipDisplay.width = stage.stageWidth-padding*2;
			tipDisplay.touchable = false;
			addChild(tipDisplay);
			
			armatureDisplay = BattleOutcomeOverlay.animFactory.buildArmatureDisplay("waiting");
			armatureDisplay.x = stage.stageWidth/2;
			armatureDisplay.y = stage.stageHeight / 2;
			armatureDisplay.scale = appModel.scale;
			armatureDisplay.animation.gotoAndPlayByFrame("appear", 1, 1);
			armatureDisplay.addEventListener(EventObject.COMPLETE, armatureDisplay_completeHandler);
			addChild(armatureDisplay);
		}
		
		override protected function defaultOverlayFactory():DisplayObject
		{
			var overlay:DisplayObject = super.defaultOverlayFactory();
			overlay.alpha = 1;
			return overlay;
		}
		
		public function disappear():void
		{
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