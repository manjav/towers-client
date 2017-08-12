package com.gerantech.towercraft.controls.overlays
{
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.models.tutorials.TutorialTask;
	import com.gt.towers.battle.fieldes.PlaceData;
	import com.gt.towers.utils.lists.PlaceDataList;
	
	import flash.geom.Point;
	
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Image;
	
	public class TutorialTouchOverlay extends TutorialOverlay
	{
		private var finger:Image;

		private var place:PlaceData;
		
		public function TutorialTouchOverlay(task:TutorialTask)
		{
			super(task);
			place = task.places.get(0);
			trace(place.index, "tutorIndex", place.tutorIndex);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();

			finger = new Image(Assets.getTexture("finger-down", "gui"));
			finger.scale = appModel.scale*3;
			finger.x = place.x * appModel.scale;
			finger.y = (place.y - 50) * appModel.scale;
			finger.touchable = false;
			
			if(transitionIn == null)
			{
				transitionIn = new TransitionData(0.2, task.startAfter / 1000);
				transitionIn.sourcePosition = new Point(0, 0);
				transitionIn.sourceAlpha = 0;
				transitionIn.destinationPosition = new Point(0, 0);
				
				if(transitionOut== null)
				{
					transitionOut = new TransitionData(0.1);
					transitionOut.destinationAlpha = 0;
					transitionOut.sourcePosition = new Point(0, 0);
					transitionOut.destinationPosition = transitionIn.sourcePosition;
				}
			}

			// execute overlay transition
			layoutData = new AnchorLayoutData(0,0,0,0);
			alpha = transitionIn.sourceAlpha;
			Starling.juggler.tween(this, transitionIn.time,
				{
					delay:transitionIn.delay,
					alpha:transitionIn.destinationAlpha,
					transition:transitionIn.transition,
					onStart:transitionInStarted,
					onComplete:transitionInCompleted
				}
			);
		}
		protected override function transitionInStarted():void
		{
			super.transitionInStarted();
			addChild(finger);
			touchFinger();
		}
				
		private function touchFinger(delay:Number=0):void
		{
			Starling.juggler.tween( finger, 0.15, {delay : delay,		scale : 0.85*appModel.scale*3});
			Starling.juggler.tween( finger, 0.50, {delay : delay+0.4,	scale : 1.00*appModel.scale*3, onComplete:touchFinger, onCompleteArgs:[2], transition:Transitions.EASE_OUT_BACK});
		}			
		
		public override function close(dispose:Boolean=true):void
		{
			super.close(dispose);
			Starling.juggler.tween(this, transitionOut.time,
			{
				delay:transitionOut.delay,
				alpha:transitionOut.destinationAlpha,
				transition:transitionOut.transition,
				onStart:transitionOutStarted,
				onComplete:transitionOutCompleted,
				onCompleteArgs:[dispose]
			}
			);
		}
	}
}