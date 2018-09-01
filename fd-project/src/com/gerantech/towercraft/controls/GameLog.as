package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.models.AppModel;
	
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.events.Event;

	public class GameLog extends TowersLayout
	{
		public static var MOVING_DISTANCE:int;
		public static var GAP:int;
		
		public var text:String;
		
		public function GameLog(text:String)
		{
			this.text = text;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			touchable = false;
			
			var labelDisplay:RTLLabel = new RTLLabel(text, 1, "center", null, true, "center", 1.0, null, "bold");
			labelDisplay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
			labelDisplay.pixelSnapping = false;
			addChild(labelDisplay);
			
			var shadowDisplay:RTLLabel = new RTLLabel(text, 0, "center", null, true, "center", 1.0, null, "bold");
			shadowDisplay.layoutData = new AnchorLayoutData(NaN, 0, NaN, 0);
			shadowDisplay.y = labelDisplay.y + 4;
			shadowDisplay.pixelSnapping = false;
			addChildAt(shadowDisplay, 0);
			
			var shadowDisplay2:RTLLabel = new RTLLabel(text, 0, "center", null, true, "center", 1.0, null, "bold");
			shadowDisplay2.layoutData = new AnchorLayoutData(NaN, 0, NaN, 0);
			shadowDisplay2.y = labelDisplay.y - 3;
			shadowDisplay2.pixelSnapping = false;
			addChildAt(shadowDisplay2, 0);
			
			width = stage.width - 120;  
			x = ( stage.stageWidth-width ) / 2;
			scaleY = 0.5;
			alpha = 0;
			Starling.juggler.tween(this, 0.3, {alpha:1, scaleY:1, transition:Transitions.EASE_OUT_BACK});
			Starling.juggler.tween(this, 4, {delay:0.0, y:y + MOVING_DISTANCE, transition:Transitions.LINEAR});
			Starling.juggler.tween(this, 1, {delay:3.5, alpha:0, onComplete:animation_onCompleteCallback});
			//filter = new starling.filters.GlowFilter(0, 1, 0.3);
		}
		
		private function animation_onCompleteCallback ():void
		{
			dispatchEventWith(Event.COMPLETE);
			removeFromParent(true);
		}
	}
}