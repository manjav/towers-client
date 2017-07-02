package com.gerantech.towercraft.controls.overlays
{
	import dragonBones.events.EventObject;
	import dragonBones.starling.StarlingArmatureDisplay;
	import dragonBones.starling.StarlingEvent;
	import dragonBones.starling.StarlingFactory;
	
	import starling.events.Event;

	public class WaitingOverlay extends BaseOverlay
	{
		public var ready:Boolean;
		
		private var armatureDisplay:StarlingArmatureDisplay ;
		
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