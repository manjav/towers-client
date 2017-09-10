package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.controls.overlays.BaseOverlay;
	import com.gerantech.towercraft.controls.overlays.TransitionData;
	
	import flash.geom.Rectangle;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	
	public class AbstractPopup extends BaseOverlay
	{
		
		override protected function initialize():void
		{
			super.initialize();
			closeOnStage = false;
			closeOnOverlay = true;
			
			if( transitionIn == null )
			{
				transitionIn = new TransitionData();
				transitionIn.transition = Transitions.EASE_OUT_BACK;
				transitionIn.sourceBound = new Rectangle(stage.stageWidth*0.15, stage.stageHeight*0.45, stage.stageWidth*0.7, stage.stageHeight*0.1);
				transitionIn.destinationBound = new Rectangle(stage.stageWidth*0.15, stage.stageHeight*0.4, stage.stageWidth*0.7, stage.stageHeight*0.2);
			}
			if( transitionOut== null )
			{
				transitionOut = new TransitionData();
				transitionOut.sourceAlpha = 1;
				transitionOut.destinationAlpha = 0;
				transitionOut.transition = Transitions.EASE_IN;
				transitionOut.sourceBound = transitionIn.destinationBound
				transitionOut.destinationBound = transitionIn.sourceBound
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
			appModel.sounds.addAndPlaySound("whoosh");

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