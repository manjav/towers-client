package com.gerantech.towercraft.controls.overlays
{
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	
	import dragonBones.events.EventObject;
	import dragonBones.starling.StarlingArmatureDisplay;
	import dragonBones.starling.StarlingEvent;
	import dragonBones.starling.StarlingFactory;
	
	import feathers.layout.AnchorLayout;
	
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
			if(BattleOutcomeOverlay.factory == null)
			{
				BattleOutcomeOverlay.factory = new StarlingFactory();
				BattleOutcomeOverlay.dragonBonesData = BattleOutcomeOverlay.factory.parseDragonBonesData( JSON.parse(new BattleOutcomeOverlay.skeletonClass()) );
				BattleOutcomeOverlay.factory.parseTextureAtlasData( JSON.parse(new BattleOutcomeOverlay.atlasDataClass()), new BattleOutcomeOverlay.atlasImageClass() );
			}
		}
		override protected function initialize():void
		{
			super.initialize();
						
			layout = new AnchorLayout();
			var padding:int = 36 * appModel.scale;
			tipDisplay = new RTLLabel(loc("tip_"+Math.min(player.get_arena(0), 2)+"_"+Math.floor(Math.random()*10)), 1, "justify", null, true, "center", 0.9);
			tipDisplay.x = padding;
			tipDisplay.y = stage.stageHeight - padding*5;
			tipDisplay.width = stage.stageWidth-padding*2;
			tipDisplay.touchable = false;
			addChild(tipDisplay);
		}
		
		override protected function defaultOverlayFactory():DisplayObject
		{
			var overlay:DisplayObject = super.defaultOverlayFactory();
			overlay.alpha = 1;
			return overlay;
		}
		
		override protected function addedToStageHandler(event:Event):void
		{
			super.addedToStageHandler(event);
			closable = false;
			if(BattleOutcomeOverlay.dragonBonesData == null)
				return;
			
			armatureDisplay = BattleOutcomeOverlay.factory.buildArmatureDisplay("waiting");
			armatureDisplay.x = stage.stageWidth/2;
			armatureDisplay.y = stage.stageHeight / 2;
			armatureDisplay.scale = appModel.scale;
			armatureDisplay.animation.gotoAndPlayByFrame("appear", 1, 1);
			armatureDisplay.addEventListener(EventObject.COMPLETE, armatureDisplay_completeHandler);
			addChild(armatureDisplay);
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