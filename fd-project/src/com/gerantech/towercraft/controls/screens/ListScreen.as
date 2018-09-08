package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.FastList;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;
import flash.utils.setTimeout;
import starling.events.Event;

public class ListScreen extends BaseFomalScreen
{
protected var virtualHeader:Boolean;
protected var listLayout:VerticalLayout;
protected var list:FastList;
protected var startScrollBarIndicator:Number = 0;

public function ListScreen(){super();}
override protected function initialize():void
{
	super.initialize();

	listLayout = new VerticalLayout();
	listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	listLayout.padding = 24;	
	listLayout.paddingTop = headerSize+listLayout.padding;
	listLayout.useVirtualLayout = true;
	listLayout.typicalItemHeight = 164;
	listLayout.gap = 12;	
	
	list = new FastList();
	list.layout = listLayout;
	list.layoutData = new AnchorLayoutData(0, 0, headerSize, 0);
	list.addEventListener(Event.CHANGE, list_changeHandler);
	if( virtualHeader )
		setTimeout(list.addEventListener, 100, Event.SCROLL, list_scrollHandler);
	addChildAt(list, 0);
}

protected function list_changeHandler(event:Event):void{}
protected function list_scrollHandler(event:Event):void
{
	var scrollPos:Number = Math.max(0, list.verticalScrollPosition);
	var changes:Number = startScrollBarIndicator - scrollPos;
	header.y = Math.max( -headerSize, Math.min(0, header.y + changes));
	startScrollBarIndicator = scrollPos;
}
}
}