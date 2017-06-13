package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.controls.overlays.BaseOverlay;
	import com.gerantech.towercraft.controls.overlays.TransitionData;
	
	import flash.geom.Rectangle;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.events.Event;
	
	public class BasePopUp extends BaseOverlay
	{
		public function BasePopUp()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			if(transitionIn == null)
			{
				transitionIn = new TransitionData();
				transitionIn.destinationBound = transitionIn.sourceBound = new Rectangle(0,0,stage.stageWidth, stage.stageHeight);
			}
			if(transitionOut== null)
			{
				transitionOut = new TransitionData();
				transitionOut.transition = Transitions.EASE_IN;
				transitionOut.destinationBound = transitionOut.sourceBound = new Rectangle(0,0,stage.stageWidth, stage.stageHeight);
			}
			
			// execute popup transition
			x = transitionIn.sourceBound.x;
			y = transitionIn.sourceBound.y;
			width = transitionIn.sourceBound.width;
			height = transitionIn.sourceBound.height;
			Starling.juggler.tween(this, transitionIn.time,
				{
					delay:transitionIn.delay,
					alpha:transitionIn.destinationAlpha,
					x:transitionIn.destinationBound.x, 
					y:transitionIn.destinationBound.y, 
					width:transitionIn.destinationBound.width, 
					height:transitionIn.destinationBound.height, 
					transition:transitionIn.transition,
					onStart:transitionInStated,
					onComplete:transitionInCompleted
				}
			);
		}
		
		
		public override function close(dispose:Boolean=true):void
		{
			super.close(dispose);

			Starling.juggler.tween(this, transitionOut.time,
				{
					delay:transitionOut.delay,
					alpha:transitionOut.destinationAlpha,
					x:transitionOut.destinationBound.x, 
					y:transitionOut.destinationBound.y, 
					width:transitionOut.destinationBound.width, 
					height:transitionOut.destinationBound.height, 
					transition:transitionOut.transition,
					onStart:transitionOutStated,
					onComplete:transitionOutCompleted,
					onCompleteArgs:[dispose]
				}
			);
		}
	}
}