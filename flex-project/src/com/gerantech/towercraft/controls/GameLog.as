package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.models.AppModel;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.filters.GlowFilter;

	public class GameLog extends RTLLabel
	{
		private var positionY:Number;
		public function GameLog(text:String, positionY:Number = -1)
		{
			this.positionY = positionY;
			touchable = touchGroup = false;
			super(text, 1, "center", null, true, "center", 54*AppModel.instance.scale, null, "bold");
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			if( positionY == -1 )
				positionY = (stage.height-height) / 2;

			width = stage.width - 120 * AppModel.instance.scale;  
			x = ( stage.stageWidth-width ) / 2;
			y = positionY;
			scaleY = 0;
			Starling.juggler.tween(this, 0.3, {y:positionY-30, scaleY:1, transition:Transitions.EASE_OUT});
			Starling.juggler.tween(this, 4, {delay:0.3, y:positionY-40, transition:Transitions.LINEAR});
			Starling.juggler.tween(this, 1, {delay:4.3, alpha:0, onComplete:animation_onCompleteCallback});
			filter = new starling.filters.GlowFilter(0, 2, 0.5);
//			nativeFilters = [new GlowFilter()]
			pixelSnapping = false;
		}
		
		private function animation_onCompleteCallback ():void
		{
			removeFromParent(true);
		}
	}
}