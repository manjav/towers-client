package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.segments.lobby.LobbyChatItemBattleSegment;
import com.gerantech.towercraft.controls.segments.lobby.LobbyChatItemCommentSegment;
import com.gerantech.towercraft.controls.segments.lobby.LobbyChatItemConfirmSegment;
import com.gerantech.towercraft.controls.segments.lobby.LobbyChatItemMessageSegment;
import com.gerantech.towercraft.controls.segments.lobby.LobbyChatItemSegment;
import com.gt.towers.constants.MessageTypes;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.events.Event;
import starling.events.Touch;

public class LobbyChatItemRenderer extends AbstractTouchableListItemRenderer
{
protected static const TYPE_MESSAGE:int = 0;
protected static const TYPE_COMMENT:int = 10;
protected static const TYPE_DONATE:int = 20;
protected static const TYPE_BATTLE:int = 30;
protected static const TYPE_CONFIRM:int = 40;
	
private var type:int;
private var messageSegment:LobbyChatItemMessageSegment;
private var commentSegment:LobbyChatItemCommentSegment;
private var confirmSegment:LobbyChatItemConfirmSegment;
private var battleSegment:LobbyChatItemBattleSegment;
private var segment:LobbyChatItemSegment;


public function getTouch():Touch
{
	return touch;
}
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	var fitLayoutData:AnchorLayoutData = new AnchorLayoutData(0,0,NaN,0);
	
	messageSegment = new LobbyChatItemMessageSegment();
	messageSegment.layoutData = fitLayoutData;
	
	commentSegment = new LobbyChatItemCommentSegment();
	commentSegment.layoutData = fitLayoutData;
	
	confirmSegment = new LobbyChatItemConfirmSegment();
	confirmSegment.addEventListener(Event.TRIGGERED, confirmSegment_triggeredHandler);
	confirmSegment.layoutData = fitLayoutData;

	battleSegment = new LobbyChatItemBattleSegment();
	battleSegment.layoutData = fitLayoutData;
	
	addEventListener(Event.TRIGGERED, item_triggeredHandler);

}

private function item_triggeredHandler(event:Event):void
{
	owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, this);
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null )
		return;
	
	if( segment )
	{
		segment.removeFromParent();
		segment = null;		
	}

	type = SFSObject(_data).getShort("m");
	if( MessageTypes.isComment(type) )
		type = TYPE_COMMENT;
	else if( MessageTypes.isConfirm(type) )
		type = TYPE_CONFIRM;
	
	switch(type)
	{
		case TYPE_MESSAGE:
			segment = messageSegment;
			break;
		case TYPE_COMMENT:
			segment = commentSegment;
			break;
		case TYPE_DONATE:
			break;
		case TYPE_CONFIRM:
			segment = confirmSegment;
			break;
		case TYPE_BATTLE:
			segment =  battleSegment;
			break;
	}
	
	segment.commitData(_data as SFSObject);//trace(index, type, segment.data.getDump())
	addChild(segment);
}
private function confirmSegment_triggeredHandler(event:Event):void
{
	
	segment.data.putShort( "pr", event.data.data as int);
	_owner.dispatchEventWith(Event.ROOT_CREATED, false, [this, segment.data]);
}
}
}