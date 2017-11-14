package com.gerantech.towercraft.controls.overlays
{
	import com.gerantech.towercraft.controls.TowersLayout;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Image;
	
	public class TutorialArrow extends TowersLayout
	{
		private var isUp:Boolean;

		private var arrow:Image;

		private var _height:Number;
		
		public function TutorialArrow(isUp:Boolean=true)
		{
			scale = appModel.scale * 2;
			this.isUp = isUp;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			arrow = new Image(isUp ? appModel.theme.buttonForwardUpSkinTexture : appModel.theme.buttonBackUpSkinTexture);
			arrow.pivotY = isUp ? 0 : arrow.height;
			addChild(arrow);
			_height = arrow.height;
			animation_1();
		}
		
		private function animation_1():void
		{
			;
			Starling.juggler.tween(arrow, 0.5, {delay:0.4, y:_height * (isUp?0.1:-0.1), height:_height*1.2, transition:Transitions.EASE_IN, onStart:function():void{arrow.y = _height * (isUp?0.2:-0.2)}, onComplete:animation_2});
		}
		
		private function animation_2():void
		{
			Starling.juggler.tween(arrow, 0.5, {y:0, height:_height, transition:Transitions.EASE_OUT_BACK, onComplete:animation_1});
		}
	}
}