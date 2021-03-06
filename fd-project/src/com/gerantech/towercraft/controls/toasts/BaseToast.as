package com.gerantech.towercraft.controls.toasts
{
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.popups.AbstractPopup;
import feathers.controls.LayoutGroup;
import flash.geom.Rectangle;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.display.DisplayObject;

public class BaseToast extends AbstractPopup
{
public var closeAfter:int = -1;
protected var toastHeight:int = 220;
public function BaseToast(){}
override protected function initialize():void
{
	if( transitionIn == null )
	{
		transitionIn = new TransitionData();
		transitionIn.transition = Transitions.EASE_OUT_BACK;
		transitionIn.sourceBound = new Rectangle(0, -toastHeight, stage.stageWidth, toastHeight);
		transitionIn.destinationBound = new Rectangle(0, 0, stage.stageWidth, toastHeight);
	}
	if( transitionOut == null )
	{
		transitionOut = new TransitionData();
		transitionOut.sourceAlpha = 1;
		transitionOut.destinationAlpha = 0;
		transitionOut.transition = Transitions.EASE_IN;
		transitionOut.sourceBound = transitionIn.destinationBound;
		transitionOut.destinationBound = transitionIn.sourceBound;
	}
	
	// execute popup transition
	rejustLayoutByTransitionData();
	
	if( closeAfter > -1 )
		setTimeout(close, closeAfter, true);
}

override protected function defaultOverlayFactory(color:uint = 0, alpha:Number = 0.4):DisplayObject
{
	var overlay:LayoutGroup = new LayoutGroup();
	overlay.touchable = false;
	return overlay;
}
}
}