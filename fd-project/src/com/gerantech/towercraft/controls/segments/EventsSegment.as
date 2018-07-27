package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.controls.items.EventsListItemRenderer;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import flash.events.Event;
public class EventsSegment extends Segment
{
	private var padding:Number;
	private var eventList;
public function EventsSegment(){super();}
override public function init():void
{
	if( initializeCompleted )
		return;
	super.init();
	layout = new AnchorLayout();
	padding = 48 * appModel.scale;
	
	var listLayout:VerticalLayout = new VerticalLayout();
	listLayout.padding = listLayout.gap = padding;
	listLayout.hasVariableItemDimensions = true;
	listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	listLayout.verticalAlign = VerticalAlign.MIDDLE;
	
	eventList = new List();
	eventList.layout = listLayout;
    eventList.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	eventList.itemRendererFactory = function ():IListItemRenderer { return new EventsListItemRenderer()};
	eventList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	eventList.addEventListener(Event.CHANGE, eventList_changeHandler);
	eventList.dataProvider = new ListCollection([0]);// manager.messages;
	addChild(eventList);

	
	var labelDisplay:ShadowLabel = new ShadowLabel(loc("button_under_construction", [loc("tab-4")]));
	labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
	addChild(labelDisplay);
}

private function eventList_changeHandler(event:Event):void 
{
	
}
}
}