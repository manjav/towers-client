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
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	
	public class TutorialSwipeOverlay extends TutorialOverlay
	{
		private var finger:Image;
		private var places:PlaceDataList;
		private var placeIndex:int;
		private var swipeTime:Number = 1;
		
		public function TutorialSwipeOverlay(task:TutorialTask)
		{
			var array:Array = [];
			while(task.places.size() > 0)
				array.push(task.places._list.pop());
			array.sortOn("tutorIndex", Array.NUMERIC|Array.DESCENDING);
			
			this.places = new PlaceDataList();
			while(array.length > 0) 
				this.places.push(array.pop());
			
			super(task);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();

			finger = new Image(Assets.getTexture("finger-down", "gui"));
			finger.alignPivot(HorizontalAlign.LEFT, VerticalAlign.TOP);
			finger.x = places.get(0).x * appModel.scale;
			finger.y = places.get(0).y * appModel.scale;
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
			goToPlace();
		}
		
		private function goToPlace():void
		{
			placeIndex ++;
			if(placeIndex == places.size()+1)
				placeIndex = 0;
			
			if( placeIndex == 0 )
			{
				finger.x = places.get(0).x * appModel.scale;
				finger.y = places.get(0).y * appModel.scale;
			}
			
			var tween:Tween = new Tween(finger, swipeTime, Transitions.EASE_IN_OUT);
			tween.delay = placeIndex == 0 ? 1 : 0.2;
			tween.onComplete = goToPlace;
			tween.fadeTo(placeIndex == places.size() ? 0 : 1);
			if(placeIndex < places.size())
				tween.moveTo(places.get(placeIndex).x * appModel.scale, places.get(placeIndex).y * appModel.scale);
			Starling.juggler.add( tween );
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