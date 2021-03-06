package com.gerantech.towercraft.controls.toasts
{
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.popups.AbstractPopup;

import flash.geom.Rectangle;

import feathers.controls.LayoutGroup;

import starling.animation.Transitions;
import starling.display.DisplayObject;

public class BaseToast extends AbstractPopup
{
protected var toastHeight:int = 220;
override protected function initialize():void
{
	if(transitionIn == null)
	{
		transitionIn = new TransitionData();
		transitionIn.transition = Transitions.EASE_OUT_BACK;
		transitionIn.sourceBound = new Rectangle(0, -toastHeight*appModel.scale, stage.stageWidth, toastHeight*appModel.scale);
		transitionIn.destinationBound = new Rectangle(0, 0, stage.stageWidth, toastHeight*appModel.scale);
	}
	if(transitionOut == null)
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
}

override protected function defaultOverlayFactory():DisplayObject
{
	var overlay:LayoutGroup = new LayoutGroup();
	overlay.touchable = false;
	return overlay;
}
}
}