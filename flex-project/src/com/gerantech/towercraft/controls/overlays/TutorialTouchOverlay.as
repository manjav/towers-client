package com.gerantech.towercraft.controls.overlays
{
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.models.tutorials.TutorialTask;
	import com.gt.towers.utils.lists.PlaceDataList;
	
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalAlign;
	
	import starling.core.Starling;
	import starling.display.Image;
	
	public class TutorialTouchOverlay extends TutorialOverlay
	{
		private var finger:Image;
		private var places:PlaceDataList;
		private var placeIndex:int;
		private var fadeTime:Number = 0.3;
		
		public function TutorialTouchOverlay(task:TutorialTask)
		{
			super(task);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();

			finger = new Image(Assets.getTexture("finger-down", "gui"));
			finger.alignPivot(HorizontalAlign.LEFT, VerticalAlign.TOP);
			finger.x = task.places.get(0).x * appModel.scale;
			finger.y = task.places.get(0).y * appModel.scale;
			finger.touchable = false;
			addChild(finger);
			
			
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
		protected override function transitionInCompleted():void
		{
			super.transitionInCompleted();
			blinkHere();
		}
		
		private function blinkHere():void
		{
			placeIndex ++;
			if(placeIndex == 2)
				placeIndex = 0;
			
			Starling.juggler.tween( finger, fadeTime, {delay : (placeIndex==0?1.5:0.5), alpha : (placeIndex==0?1:0), onComplete:blinkHere});
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