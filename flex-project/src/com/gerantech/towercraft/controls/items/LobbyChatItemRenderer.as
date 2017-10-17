package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.segments.lobby.LobbyChatItemBattleSegment;
import com.gerantech.towercraft.controls.segments.lobby.LobbyChatItemCommentSegment;
import com.gerantech.towercraft.controls.segments.lobby.LobbyChatItemMessageSegment;
import com.gerantech.towercraft.controls.segments.lobby.LobbyChatItemSegment;
import com.gt.towers.constants.MessageTypes;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

public class LobbyChatItemRenderer extends BaseCustomItemRenderer
{
protected static const TYPE_MESSAGE:int = 0;
protected static const TYPE_COMMENT:int = 10;
protected static const TYPE_DONATE:int = 20;
protected static const TYPE_BATTLE:int = 30;
	
private var type:int;
private var messageSegment:LobbyChatItemMessageSegment;
private var commentSegment:LobbyChatItemCommentSegment;
private var battleSegment:LobbyChatItemBattleSegment;
private var segment:LobbyChatItemSegment;
private var lobbyData:ISFSObject;

public function LobbyChatItemRenderer(lobbyData:ISFSObject)
{
	this.lobbyData = lobbyData;
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
	
	battleSegment = new LobbyChatItemBattleSegment();
	battleSegment.layoutData = fitLayoutData;
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
		type = 10;
	
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
		case TYPE_BATTLE:
			segment =  battleSegment;
			break;
	}
	
	segment.commitData(_data as SFSObject, lobbyData);//trace(index, type, segment.data.getDump())
	addChild(segment);
	resetSize();
}

private function resetSize():void
{
	if( height != 0 || type==TYPE_COMMENT )
		height = type==TYPE_COMMENT ? segment.padding*1.4 :(segment.height + segment.padding);
}
}
}