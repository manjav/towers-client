package com.gerantech.towercraft.controls.overlays
{
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.models.tutorials.TutorialTask;
	import com.gt.towers.utils.lists.PlaceDataList;
	
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.FlowLayout;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalAlign;
	import feathers.media.TimeLabel;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	
	public class TutorialSwipeOverlay extends TutorialOverlay
	{
		private var finger:Image;
		private var places:PlaceDataList;
		private var tweenStep:int ;
		private var swipeTime:Number = 1;
		private var isDoubleAttack:Boolean = true;
		private var flag:Boolean = false;
		
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
			if(isDoubleAttack)
				flag = true;
			super.transitionInCompleted();
			tweenCompleteCallback("stepLast")
		}
		
		private function swipe(from:int, to:int, fromAlpha:Number=1, toAlpha:Number=1, time:Number=1, doubleA:Boolean=true):void
		{
				animate( "stepMid",
					places.get(from).x * appModel.scale, 
					(places.get(from).y - 200) * appModel.scale, 
					places.get(to).x * appModel.scale, 
					(places.get(to).y - 200) * appModel.scale,
					fromAlpha, toAlpha, time
				);
		}
		
		private function animate(name:String, startX:Number, startY:Number, endX:Number, endY:Number, startAlpha:Number=1, endAlpha:Number=1, time:Number=1, delayTime:Number =3):void
		{
			finger.x = startX;
			finger.y = startY;
			finger.alpha = startAlpha;
			
			var tween:Tween = new Tween(finger, swipeTime, Transitions.EASE_IN_OUT);
			tween.moveTo(endX, endY);
			tween.delay = 0.5;
			tween.fadeTo(endAlpha);
			tween.onComplete = tweenCompleteCallback;
			tween.onCompleteArgs = [name];
			Starling.juggler.add( tween );
		}		
		
		private function tweenCompleteCallback(swipeName:String):void
		{
			switch(swipeName)
			{
				case "stepFirst":
				case "stepMid":
					if(swipeName == "stepMid")
						tweenStep ++;
					
					if(tweenStep == places.size()-1)
					{
/*						if(true)
							animate( "stepLast",
								(places.get(tweenStep).x) * appModel.scale, 
								(places.get(tweenStep).y-200) * appModel.scale, 
								(places.get(tweenStep-1).x) * appModel.scale, 
								(places.get(tweenStep-1).y-400) * appModel.scale,
								1, 0);
						else*/
							animate( "stepLast",
								(places.get(tweenStep).x) * appModel.scale, 
								(places.get(tweenStep).y-200) * appModel.scale, 
								(places.get(tweenStep).x) * appModel.scale, 
								(places.get(tweenStep).y-250) * appModel.scale,
								1, 0);
							if(flag == true)
							{
								tweenStep -= 1;
								swipe(tweenStep, tweenStep+1);
								flag = false;
							}
					}
					else
					{
						swipe(tweenStep, tweenStep+1);
					}
					break;
				case "stepLast":
					tweenStep = 0;
					animate( "stepFirst",
						(places.get(0).x) * appModel.scale, 
						(places.get(0).y-150) * appModel.scale, 
						(places.get(0).x) * appModel.scale, 
						(places.get(0).y-200) * appModel.scale,
						0, 1);	
					trace("stepFirst animated.")
					break;

			}
			trace("tweenStep:", tweenStep);
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