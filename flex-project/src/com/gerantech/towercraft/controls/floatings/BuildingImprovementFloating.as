package com.gerantech.towercraft.controls.floatings
{
	import com.gerantech.towercraft.controls.buttons.ImproveButton;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.views.PlaceView;
	
	import feathers.controls.Button;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;

	public class BuildingImprovementFloating extends BaseFloating
	{
		public var placeDecorator:PlaceView;
		
		private var upgradeButton:Button;
		private var buttons:Vector.<ImproveButton>;
		
		override protected function initialize():void
		{
			super.initialize();
			transitionOut.destinationAlpha = 0;
			overlay.visible = false;
			var raduis:int = 160 * appModel.scale;

			var circle:Image = new Image(Assets.getTexture("damage-range"));
			circle.alignPivot();
			circle.width = circle.height = raduis;
			Starling.juggler.tween(circle, 0.2, {width:raduis*2, height:raduis*2, transition:Transitions.EASE_OUT});
			addChild(circle);
				
			buttons = new Vector.<ImproveButton>();
			var numButtons:int = placeDecorator.place.building.get_options().size();
			for (var i:int=0; i < numButtons; i++) 
			{
				var impoveType:int = placeDecorator.place.building.get_options().get(i);
				
				buttons[i] = new ImproveButton(placeDecorator.place.building, impoveType);
				buttons[i].renable();
				
				var angle:Number = Math.PI * 2/numButtons*i;
				var _x:Number = Math.sin(angle) * raduis;
				var _y:Number = Math.cos(angle) * raduis;
				buttons[i].x = _x * 0.7;
				buttons[i].y = _y * 0.7;
				buttons[i].alpha = 0;
				//trace(i, angle, Math.sin(angle), Math.cos(angle))
				Starling.juggler.tween(buttons[i], 0.2, {delay:i*0.03+0.03, alpha:1, x:_x, y:_y, transition:Transitions.EASE_OUT_BACK});

				buttons[i].addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
				addChild(buttons[i]);
			}
			placeDecorator.addEventListener(Event.UPDATE, placeDecorator_updateHandler);
		}
		
		private function placeDecorator_updateHandler(event:Event):void
		{
			for (var i:int=0; i < buttons.length; i++) 
				buttons[i].renable();
		}
		
		private function buttons_triggeredHandler(event:Event):void
		{
			dispatchEventWith(Event.SELECT, false, {index:placeDecorator.place.index, type:ImproveButton(event.currentTarget).type});
			close();
		}
		
		override public function close(dispose:Boolean=true):void
		{
			placeDecorator.removeEventListener(Event.UPDATE, placeDecorator_updateHandler);
			super.close(dispose);
		}
	}
}