package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.controls.headers.CloseFooter;
import com.gerantech.towercraft.controls.headers.ScreenHeader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;
import flash.utils.setTimeout;
import starling.events.Event;

public class ListScreen extends BaseCustomScreen
{
public var title:String = "";

protected var listLayout:VerticalLayout;
protected var list:FastList;
protected var header:ScreenHeader;
protected var footer:CloseFooter;
protected var headerSize:int = 0;
protected var startScrollBarIndicator:Number = 0;

public function ListScreen(){super();}
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	
	headerSize = 150 * appModel.scale;
	
	listLayout = new VerticalLayout();
	listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	listLayout.padding = 24 * appModel.scale;	
	listLayout.paddingTop = headerSize+listLayout.padding;
	listLayout.useVirtualLayout = true;
	listLayout.typicalItemHeight = 164 * appModel.scale;;
	listLayout.gap = 12 * appModel.scale;	
	
	list = new FastList();
	list.layout = listLayout;
	list.layoutData = new AnchorLayoutData(0, 0, headerSize, 0);
	list.addEventListener(Event.CHANGE, list_changeHandler);
	setTimeout(list.addEventListener, 100, Event.SCROLL, list_scrollHandler);
	addChild(list);
	
	header = new ScreenHeader(title);
	header.height = headerSize;
	header.layoutData = new AnchorLayoutData(NaN, 0, NaN, 0);
	addChild(header);
	
	footer = new CloseFooter();
	footer.layoutData = new AnchorLayoutData(NaN, 0,  0, 0);
	footer.addEventListener(Event.CLOSE, backButtonHandler);
	addChild(footer);
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