package com.gerantech.towercraft.controls.segments.lobby
{
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gt.towers.constants.MessageTypes;
import com.smartfoxserver.v2.entities.data.ISFSObject;

import feathers.layout.AnchorLayoutData;

public class LobbyChatItemCommentSegment extends LobbyChatItemSegment
{

private var labelDisplay:ShadowLabel;
public function LobbyChatItemCommentSegment(){}
override public function init():void
{
	super.init();
	height = padding * 1.8;
	labelDisplay = new ShadowLabel("", 1, 0, "center", null, false, null, 0.8); 
	labelDisplay.layoutData = new AnchorLayoutData( NaN, padding, NaN, padding, NaN, 0);
	addChild(labelDisplay);
}
override public function commitData(_data:ISFSObject):void
{
	super.commitData(_data);
	
	var comment:String = "";
	switch(data.getShort("m"))
	{
		case MessageTypes.M10_COMMENT_JOINT:		comment = loc("lobby_comment_join",		[data.getUtfString("s")]);	break;
		case MessageTypes.M11_COMMENT_LEAVE:		comment = loc("lobby_comment_leave",	[data.getUtfString("s")]);	break;
		case MessageTypes.M15_COMMENT_EDIT:			comment = loc("lobby_comment_edit",		[data.getUtfString("s")]);	break;
		case MessageTypes.M16_COMMENT_JOIN_ACCEPT:	comment = loc("lobby_comment_jaccept",	[data.getUtfString("o"), data.getUtfString("s")]);	break;
		case MessageTypes.M17_COMMENT_JOIN_REJECT:	comment = loc("lobby_comment_jreject",	[data.getUtfString("o"), data.getUtfString("s")]);	break;
		case MessageTypes.M12_COMMENT_KICK:			comment = loc("lobby_comment_kick",		[data.getUtfString("o"), data.getUtfString("s")]);	break;
		case MessageTypes.M13_COMMENT_PROMOTE:		comment = loc("lobby_comment_promote",	[data.getUtfString("o"), data.getUtfString("s"), loc("lobby_role_"+data.getShort("p"))]);	break;
		case MessageTypes.M14_COMMENT_DEMOTE:		comment = loc("lobby_comment_demote",	[data.getUtfString("o"), data.getUtfString("s"), loc("lobby_role_"+data.getShort("p"))]);	break;
	}
	labelDisplay.text = comment;
}
}
}