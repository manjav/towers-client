package com.gerantech.towercraft.controls.tooltips
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.events.Event;
import starling.events.TouchEvent;

public class ConfirmTooltip extends BaseTooltip
{
public var hasDecline:Boolean;
public function ConfirmTooltip(message:String, position:Rectangle, fontScale:Number=0.8, hSize:Number=0.5, hasDecline:Boolean=true)
{
	super(message, position, fontScale, hSize);
	this.hasDecline = hasDecline;
}

override protected function initialize():void
{
	super.initialize();
	
	var acceptButton:CustomButton = new CustomButton();
	acceptButton.label = loc("popup_ok_label");
	acceptButton.height = padding * 4;
	acceptButton.addEventListener(Event.TRIGGERED, acceptButton_triggeredHandler);
	acceptButton.layoutData = new AnchorLayoutData(NaN, hasDecline ? padding : NaN, padding * 2, NaN, hasDecline ? NaN : 0);
	addChild(acceptButton);
	
	if( hasDecline )
	{
		var declineButton:CustomButton = new CustomButton();
		declineButton.label = loc("popup_decline_label");
		declineButton.style = "danger";
		declineButton.height = padding * 4;
		declineButton.addEventListener(Event.TRIGGERED, acceptButton_triggeredHandler);
		declineButton.layoutData = new AnchorLayoutData(NaN, NaN, padding * 2, NaN, 0);
		addChild(declineButton);
	}
}
override protected function transitionInStarted():void
{
	height = labelDisplay.height + padding * 8;
	super.transitionInStarted();
}

private function acceptButton_triggeredHandler(event:Event):void
{
	dispatchEventWith(CustomButton(event.currentTarget).style == "danger" ? Event.CANCEL : Event.SELECT );
}
override protected function stage_touchHandler(event:TouchEvent):void
{
}		

}
}