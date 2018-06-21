package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
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
	layout = new AnchorLayout();
	var labelDisplay:ShadowLabel = new ShadowLabel(loc("button_under_construction", [loc("tab-4")]));
	labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
	addChild(labelDisplay);
}
}
}