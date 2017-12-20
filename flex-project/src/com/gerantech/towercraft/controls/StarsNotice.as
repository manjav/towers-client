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
			for ( var i:int=0; i<3; i++ )
			{
				var star:StarCheck = new StarCheck();
				star.width = star.height = height * 0.7;
				star.pivotX = star.width * 0.5;
				star.pivotY = star.height * 0.5;
//				star.x = (Math.ceil(i/4) * ( i==1 ? 1 : -1 )) * padding * 5 + 540 * appModel.scale;
				star.x = Math.ceil(i/4) * ( i==1 ? 1 : -1 ) * (stage.stageWidth-height*3)/4 + height * 3 ;//- star.width/2;
				star.y = height * 0.5;
				addChild(star)
				stars.push(star);
			}
			//stars.reverse();
		}

		public function pass(score:int):void
		{
			trace(score);
			//score = 2 - score;
			for ( var i:int=0; i<stars.length; i++ )
				stars[i].isEnabled = score >= i;

			stars[score+1].scale = 1.5;
			Starling.juggler.tween(stars[score+1], 0.3, {delay:i*0.1, scale:1, transition:Transitions.EASE_OUT_BACK});
		}
	}
}