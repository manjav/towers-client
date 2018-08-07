package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.items.challenges.ChallengeListItemRenderer;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gt.towers.socials.Attendee;
import com.gt.towers.socials.Challenge;
import com.gt.towers.utils.maps.IntChallengeMap;
import com.gt.towers.utils.maps.IntIntMap;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
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
    eventsList.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	eventsList.itemRendererFactory = function ():IListItemRenderer { return new ChallengeListItemRenderer()};
	eventsList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	eventsList.addEventListener(FeathersEventType.FOCUS_IN, eventsList_changeHandler);
	addChild(eventsList);
	
	if( player.challenges == null )
	{
		SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseHandler);
		SFSConnection.instance.sendExtensionRequest(SFSCommands.CHALLENGE_GET_ALL);
		player.challenges = new IntChallengeMap();
	}
	else
	{
		showChallenges();
	}
}

private function sfs_responseHandler(e:SFSEvent):void 
{
	if( e.params.cmd != SFSCommands.CHALLENGE_GET_ALL )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseHandler);
	var params:ISFSObject = e.params.params as SFSObject;
	trace(params.getDump());
	for ( var i:int = 0; i < params.getSFSArray("challenges").size(); i++ )
	{
		var c:ISFSObject = params.getSFSArray("challenges").getSFSObject(i);
		var ch:Challenge = new Challenge();
		ch.id = c.getInt("id");
		ch.type = c.getInt("type");
		ch.startAt = c.getInt("start_at");
		ch.duration = c.getInt("duration");
		ch.capacity = c.getInt("capacity");
		ch.requirements = new IntIntMap();
		for (var r:int = 0; r < c.getSFSArray("requirements").size(); r++)
			ch.requirements.set(c.getSFSArray("requirements").getSFSObject(r).getInt("key"), c.getSFSArray("requirements").getSFSObject(r).getInt("value"));
		ch.attendees = new Array();
		for (var a:int = 0; a < c.getSFSArray("attendees").size(); a++)
		{
			var att:ISFSObject = c.getSFSArray("attendees").getSFSObject(a);
			ch.attendees.push(new Attendee(att.getInt("id"), att.getText("name"), att.getInt("point"), att.getInt("lastUpdate")));
		}
		player.challenges.set(ch.type, ch);
	}
	showChallenges();
}

private function showChallenges():void 
{
	if ( !player.challenges.exists(0) )
	{
		var d:Date = new Date();
		d.setHours(Challenge.START_HOUR);
		d.setMinutes(0);
		d.setSeconds(0);
		d.setMilliseconds(0);
		
		var ch:Challenge = new Challenge();
		ch.id = -1;
		ch.type = 0;
		ch.capacity = Challenge.getCapacity(ch.type);
		ch.duration = Challenge.getDuration(ch.type);
		ch.requirements = Challenge.getRequiements(ch.type);
		ch.startAt = int(d.getTime() / 1000);
		ch.attendees = new Array();
		player.challenges.set(ch.type, ch);
	}
	
	eventsList.dataProvider = new ListCollection(player.challenges.values());
}

protected function eventsList_changeHandler(event:Event) : void 
{
	var item:StackScreenNavigatorItem = appModel.navigator.getScreen( Main.CHALLENGE_SCREEN );
	var ch:Challenge = ChallengeListItemRenderer(event.data).challenge;
	if( ch.getState(timeManager.now) >= Challenge.STATE_STARTED && ch.indexOfAttendees(player.id) <= -1 )
	{
		appModel.navigator.addLog(loc("challenge_error_illigeal"));
		return;
	}
	item.properties.challenge = ch ;
	appModel.navigator.pushScreen( Main.CHALLENGE_SCREEN ) ;
}
}
}