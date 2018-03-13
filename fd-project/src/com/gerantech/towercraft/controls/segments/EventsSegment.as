package com.gerantech.towercraft.controls.segments
{
public class EventsSegment extends Segment
{
public function EventsSegment()
{
	super();
}
override public function init():void
{
	if( initializeCompleted )
		return;
	super.init();
	
	//if( player.inTutorial() )
	//{
		appModel.navigator.addLog(loc("button_not_availabled", [loc("tab-4")]));
	//	return;
	//}
}
}
}