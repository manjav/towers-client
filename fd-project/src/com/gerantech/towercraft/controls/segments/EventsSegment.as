package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.items.challenges.ChallengeListItemRenderer;
import com.gt.towers.socials.Attendee;
import com.gt.towers.socials.Challenge;
import com.gt.towers.utils.maps.IntAttendeeMap;
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
	
	if( player.challenges == null )
	{
		player.challenges = new Array();
		var ch:Challenge = new Challenge();
		ch.startAt = timeManager.now + 10;
		ch.duration = 10;
		ch.attendees = new IntAttendeeMap();
		ch.attendees.set(10487, new Attendee(10487, "KOOT", 120));
		for (var i:int = 0; i < 49; i++)
			ch.attendees.set(12000 + i, new Attendee(12000 + i, "att" + i, 120 - i));
		player.challenges.push(ch);
		
	}
	
	eventsList = new List();
	eventsList.layout = listLayout;
	//eventsList.isQuickHitAreaEnabled = true;
    eventsList.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	eventsList.itemRendererFactory = function ():IListItemRenderer { return new ChallengeListItemRenderer()};
	eventsList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	eventsList.addEventListener(FeathersEventType.FOCUS_IN, eventsList_changeHandler);
	eventsList.dataProvider = new ListCollection(player.challenges);// manager.messages;
	addChild(eventsList);
}

protected function eventsList_changeHandler(event:Event) : void 
{
	var item:StackScreenNavigatorItem = appModel.navigator.getScreen( Main.CHALLENGE_SCREEN );
	item.properties.challenge = ChallengeListItemRenderer(event.data).challenge ;
	appModel.navigator.pushScreen( Main.CHALLENGE_SCREEN ) ;
}
}
}