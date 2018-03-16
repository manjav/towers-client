package com.gerantech.towercraft.controls.overlays
{
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.models.tutorials.TutorialTask;
	import com.gt.towers.utils.lists.PlaceDataList;
	
	import feathers.controls.LayoutGroup;
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.text.BitmapFontTextFormat;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	
	public class TutorialSwipeOverlay extends TutorialOverlay
	{
		private var finger:LayoutGroup;
		private var places:PlaceDataList;
		private var tweenStep:int ;
		private var doubleSwipe:Boolean;
		private var doubleCount:int = 0;
		private var swipeNumText:BitmapFontTextRenderer;
		
		public function TutorialSwipeOverlay(task:TutorialTask)
		{
			var array:Array = [];
			while(task.places.size() > 0)
				array.push(task.places._list.pop());
			array.sortOn("tutorIndex", Array.NUMERIC|Array.DESCENDING);
			
			this.places = new PlaceDataList();
			while(array.length > 0) 
				this.places.push(array.pop());
			
			//for each(var p:PlaceData in this.places._list)
				//trace(p.tutorIndex);
			super(task);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			finger = new LayoutGroup();
			finger.backgroundSkin = new Image(Assets.getTexture("finger-down", "gui"));
			//finger.width = finger.backgroundSkin.width * appModel.scale;
			//finger.height = finger.backgroundSkin.height * appModel.scale;
			finger.touchable = false;
		}
		
		protected override function transitionInCompleted():void
		{
			super.transitionInCompleted();
			doubleSwipe = this.places.get(0).tutorIndex >= 10;
			addChild(finger);
			
			swipeNumText = new BitmapFontTextRenderer();
			swipeNumText.textFormat = new BitmapFontTextFormat(Assets.getFont(), 36, 0xAAFFDD, "center")
			swipeNumText.pixelSnapping = false;
			swipeNumText.y = -50;
			swipeNumText.touchable = false;
			swipeNumText.text = "  ";
			swipeNumText.visible = false;
			finger.addChild(swipeNumText);
			swipeNumText.pivotX = swipeNumText.width * 0.5;
			swipeNumText.pivotY = swipeNumText.height * 0.5;
			
			tweenCompleteCallback("stepLast")
		}
		
		private function swipe(from:int, to:int, fromAlpha:Number=1, toAlpha:Number=1, fromScale:Number=1, toScale:Number=1, time:Number=1.5, doubleA:Boolean=true, swipeIndex:int=-1):void
		{
				animate( "stepMid",
					places.get(from).x * appModel.scale, 
					(places.get(from).y - 100) * appModel.scale, 
					places.get(to).x * appModel.scale, 
					(places.get(to).y - 100) * appModel.scale,
					fromAlpha, toAlpha, fromScale, toScale, time, 0, swipeIndex
				);
		}
		
		private function animate(name:String, startX:Number, startY:Number, endX:Number, endY:Number, startAlpha:Number=1, endAlpha:Number=1, startScale:Number=1, endScale:Number=1, time:Number=1.5, delayTime:Number=0, swipeIndex:int=-1):void
		{
			finger.x = startX;
			finger.y = startY;
			finger.alpha = startAlpha;
			finger.scale = startScale;
			
			var tween:Tween = new Tween(finger, time, Transitions.EASE_IN_OUT);
			tween.moveTo(endX, endY);
			tween.delay = delayTime;
			tween.scaleTo(endScale);
			tween.fadeTo(endAlpha);
			tween.onComplete = tweenCompleteCallback;
			tween.onCompleteArgs = [name];
			Starling.juggler.add( tween );
			
			if( swipeIndex > -1 )
			{
				swipeNumText.text = String(swipeIndex+1);
				swipeNumText.scale = 1.3;
				Starling.juggler.tween(swipeNumText, 0.3, {scale:1, transition:Transitions.EASE_OUT});
			}
			else
			{
				swipeNumText.text = "";
			}
			swipeNumText.visible = swipeIndex > -1;
		}		
		
		private function tweenCompleteCallback(swipeName:String):void
		{
			if(!isOpen)
				return;
			switch(swipeName)
			{
				case "stepFirst":
				case "stepMid":
					if( swipeName == "stepMid" )
						tweenStep ++;
					
					if( tweenStep == places.size()-1 )
					{
						if ( doubleSwipe && doubleCount == 0 )
						{
							doubleCount ++;
							animate( "doubleOut",
								(places.get(tweenStep).x) * appModel.scale, 
								(places.get(tweenStep).y-100) * appModel.scale, 
								(places.get(tweenStep).x) * appModel.scale, 
								(places.get(tweenStep).y-100) * appModel.scale,
								1, 0, 1, 1, 0.2);
						}
						else
						{
							animate( "stepLast",
								(places.get(tweenStep).x) * appModel.scale, 
								(places.get(tweenStep).y-100) * appModel.scale, 
								(places.get(tweenStep).x) * appModel.scale, 
								(places.get(tweenStep).y-200) * appModel.scale,
                                1, 0, 1, 1.2, 0.7);
						}
					}
					else
					{
                        swipe(tweenStep, tweenStep+1, 1, 1, 1, 1, 1, true, places.size()>2?tweenStep:-1);
					}
					break;
				case "stepLast":
					tweenStep = 0;
					doubleCount = 0;
					animate( "stepFirst",
						(places.get(0).x) * appModel.scale, 
						(places.get(0).y) * appModel.scale, 
						(places.get(0).x) * appModel.scale, 
						(places.get(0).y-100) * appModel.scale,
						0, 1, 1.2, 1, 0.7, 0);	
					break;
				case "doubleOut":
					tweenStep = 0;
					finger.alpha = 1;
					tweenCompleteCallback("stepFirst");
					break;

			}
			//trace("tweenStep:", tweenStep, places.get(tweenStep).tutorIndex);
		}
	}
}