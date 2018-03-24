package com.gerantech.towercraft.controls.overlays
{
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.models.tutorials.TutorialTask;
	import com.gt.towers.battle.fieldes.PlaceData;
	
	import feathers.layout.AnchorLayout;
	
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
	//		finger.scale = appModel.scale;
			finger.x = place.x * appModel.scale;
			finger.y = (place.y - 50) * appModel.scale;
			finger.touchable = false;
		}
		protected override function transitionInStarted():void
		{
			super.transitionInStarted();
			addChild(finger);
			touchFinger();
		}
		private function touchFinger(delay:Number=0):void
		{
			Starling.juggler.tween( finger, 0.15, {delay : delay,		scale : 0.85});
			Starling.juggler.tween( finger, 0.50, {delay : delay+0.4,	scale : 1.00, onComplete:touchFinger, onCompleteArgs:[2], transition:Transitions.EASE_OUT_BACK});
		}			
	}
}