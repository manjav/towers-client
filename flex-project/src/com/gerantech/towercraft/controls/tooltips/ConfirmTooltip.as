package com.gerantech.towercraft.controls.tooltips
{
	import com.gerantech.towercraft.controls.buttons.CustomButton;
	
	import flash.geom.Rectangle;
	
	import feathers.layout.AnchorLayoutData;
	
	import starling.events.Event;
	import starling.events.TouchEvent;

	public class ConfirmTooltip extends BaseTooltip
	{
		public function ConfirmTooltip(message:String, position:Rectangle, fontScale:Number=0.8, hSize:Number=0.5)
		{
			super(message, position, fontScale, hSize);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			var acceptButton:CustomButton = new CustomButton();
			acceptButton.label = loc("popup_accept_label");
			acceptButton.height = padding * 3;
			acceptButton.addEventListener(Event.TRIGGERED, acceptButton_triggeredHandler);
			acceptButton.layoutData = new AnchorLayoutData( labelDisplay.height + padding*5, padding);
			addChild(acceptButton);
			
			var declineButton:CustomButton = new CustomButton();
			declineButton.label = loc("popup_decline_label");
			declineButton.style = "danger";
			declineButton.height = padding * 3;
			declineButton.addEventListener(Event.TRIGGERED, acceptButton_triggeredHandler);
			declineButton.layoutData = new AnchorLayoutData( labelDisplay.height + padding*5, NaN, NaN, padding);
			addChild(declineButton);
			
			height = labelDisplay.height + acceptButton.height + padding * 7;
		}
		
		private function acceptButton_triggeredHandler(event:Event):void
		{
			dispatchEventWith(CustomButton(event.currentTarget).style=="danger" ? Event.CANCEL : Event.SELECT );
		}
		override protected function stage_touchHandler(event:TouchEvent):void
		{
		}		
		
	}
}