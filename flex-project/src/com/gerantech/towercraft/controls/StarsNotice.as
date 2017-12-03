package com.gerantech.towercraft.controls
{
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.events.Event;

	public class StarsNotice extends TowersLayout
	{
		private var stars:Vector.<StarCheck>;
		public function StarsNotice()
		{
			super();
			touchable = false;
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			backgroundSkin = new Quad(1,1,0);
			backgroundSkin.alpha = 0.4;
		}
		
		private function addedToStageHandler(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			height = 180 * appModel.scale;

			stars = new Vector.<StarCheck>();
			for ( var i:int=1; i<=3; i++ )
			{
				var star:StarCheck = new StarCheck();
				star.width = star.height = height * 0.6;
				star.pivotX = star.width/2;
				star.pivotY = star.height/2;
				star.x = i * (stage.stageWidth-height*3)/4 + height*1.5 ;//- star.width/2;
				star.y = height * 0.5;
				addChild(star)
				stars.push(star);
			}
			stars.reverse();
		}

		public function pass(score:int):void
		{
			for ( var i:int=0; i<stars.length; i++ )
				stars[i].isEnabled = score >= i;

			stars[score==1?0:1].scale = 1.5;
			Starling.juggler.tween(stars[score==1?0:1], 0.3, {delay:i/10, scale:1, transition:Transitions.EASE_OUT_BACK});
		}
	}
}