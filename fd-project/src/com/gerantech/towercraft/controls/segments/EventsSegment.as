package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.items.EventsListItemRenderer;
import com.gt.towers.socials.Challenge;
import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.StackScreenNavigatorItem;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import starling.events.Event;

public class EventsSegment extends Segment
{
private var eventsList:List;
public function EventsSegment(){ super(); }
override public function init():void
{
	if( initializeCompleted )
		return;
	initializeCompleted = true;
	super.init();
	layout = new AnchorLayout();
	
	var listLayout:VerticalLayout = new VerticalLayout();
	listLayout.padding = listLayout.gap = 24;
	listLayout.hasVariableItemDimensions = true;
	listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	listLayout.verticalAlign = VerticalAlign.MIDDLE;
	
	eventsList = new List();
	eventsList.layout = listLayout;
	//eventsList.isQuickHitAreaEnabled = true;
    eventsList.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	eventsList.itemRendererFactory = function ():IListItemRenderer { return new EventsListItemRenderer()};
	eventsList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	eventsList.addEventListener(FeathersEventType.FOCUS_IN, eventsList_changeHandler);
	eventsList.dataProvider = new ListCollection([new Challenge()]);// manager.messages;
	addChild(eventsList);

	/*var labelDisplay:ShadowLabel = new ShadowLabel(loc("button_under_construction", [loc("tab-4")]));
	labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
	addChild(labelDisplay);*/
}

protected function eventsList_changeHandler(event:Event) : void 
{
	var item:StackScreenNavigatorItem = appModel.navigator.getScreen( Main.CHALLENGE_SCREEN );
	item.properties.challenge = EventsListItemRenderer(event.data).challenge ;
	appModel.navigator.pushScreen( Main.CHALLENGE_SCREEN ) ;
}
}
}