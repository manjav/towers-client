package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.controls.overlays.BaseOverlay;
	import com.gerantech.towercraft.controls.overlays.TransitionData;
	
	import flash.geom.Rectangle;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	
	public class BasePopup extends BaseOverlay
	{
		public function BasePopup()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			overlay.touchable = true;
			if(transitionIn == null)
			{
				transitionIn = new TransitionData();
				transitionIn.sourceAlpha = 0;
				transitionIn.destinationBound = transitionIn.sourceBound = new Rectangle(stage.stageWidth*0.15, stage.stageHeight*0.25, stage.stageWidth*0.7, stage.stageHeight*0.5);
			}
			if(transitionOut== null)
			{
				transitionOut = new TransitionData();
				transitionOut.destinationAlpha = 0;
				transitionOut.transition = Transitions.EASE_IN;
				transitionOut.destinationBound = transitionOut.sourceBound = new Rectangle(stage.stageWidth*0.15, stage.stageHeight*0.25, stage.stageWidth*0.7, stage.stageHeight*0.5);
			}
			
			// execute popup transition
			rejustLayoutByTransitionData();
		}
		
		protected function rejustLayoutByTransitionData():void
		{
			Starling.juggler.removeTweens(this);
			
			alpha = transitionIn.sourceAlpha;
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
					onStart:transitionInStarted,
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
					onStart:transitionOutStarted,
					onComplete:transitionOutCompleted,
					onCompleteArgs:[dispose]
				}
			);
		}
	}
}