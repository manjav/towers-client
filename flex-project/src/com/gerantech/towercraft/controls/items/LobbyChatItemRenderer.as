package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.MessageTypes;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

import flash.geom.Rectangle;

import feathers.controls.AutoSizeMode;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

public class LobbyChatItemRenderer extends BaseCustomItemRenderer
{

private var senderDisplay:RTLLabel;
private var roleDisplay:RTLLabel;
private var messageDisplay:RTLLabel;
private var dateDisplay:RTLLabel;
private var commentDisplay:ShadowLabel;

private var meSkin:ImageLoader;
private var otherSkin:ImageLoader;

private var senderLayout:AnchorLayoutData;
private var roleLayout:AnchorLayoutData;
private var messageLayout:AnchorLayoutData;
private var dateLayout:AnchorLayoutData;

private var otherPadding:int;
private var padding:int;
private var date:Date;

public static const STYLE_MESSAGE:int = 0;
public static const STYLE_COMMENT:int = 1;
private var style:int = -1;

public function LobbyChatItemRenderer()
{
	super();
}

override protected function initialize():void
{
	super.initialize();
	autoSizeMode = AutoSizeMode.CONTENT;
	
	date = new Date();
	layout = new AnchorLayout();
	padding = 80 * appModel.scale;
	otherPadding = 180 * appModel.scale;
	
	meSkin = new ImageLoader();
	meSkin.scale9Grid = new Rectangle(22, 17, 4, 4);
	meSkin.visible = false;
	meSkin.source = Assets.getTexture("balloon-me", "skin");
	meSkin.layoutData = new AnchorLayoutData( padding*0.1, padding*0.1, padding*0.1, otherPadding-padding*0.9 );
	
	otherSkin = new ImageLoader();
	otherSkin.scale9Grid = new Rectangle(22, 17, 4, 4);
	otherSkin.visible = false;
	otherSkin.source = Assets.getTexture("balloon-other", "skin");
	otherSkin.layoutData = new AnchorLayoutData( padding*0.1, otherPadding-padding*0.9, padding*0.1, padding*0.1 );
	
	senderDisplay = new RTLLabel("", BaseMetalWorksMobileTheme.PRIMARY_BACKGROUND_COLOR, null, null, false, null, 0.8);
	senderLayout = new AnchorLayoutData( padding * 0.5 );
	senderDisplay.layoutData = senderLayout;
	
	roleDisplay = new RTLLabel("", BaseMetalWorksMobileTheme.PRIMARY_BACKGROUND_COLOR, null, null, false, null, 0.7);
	roleLayout = new AnchorLayoutData( padding * 0.5 );
	roleDisplay.layoutData = roleLayout;
	
	messageDisplay = new RTLLabel("", BaseMetalWorksMobileTheme.PRIMARY_BACKGROUND_COLOR, "justify", null, true, null, 0.8, "OpenEmoji");
	//messageDisplay.leading = -10*appModel.scale;
	messageLayout = new AnchorLayoutData( padding * 1.3 );
	messageDisplay.layoutData = messageLayout;
	
	dateDisplay = new RTLLabel("", BaseMetalWorksMobileTheme.DESCRIPTION_TEXT_COLOR, null, null, false, null, 0.7);
	dateLayout = new AnchorLayoutData( NaN, appModel.isLTR?padding:NaN, padding * 0.5, appModel.isLTR?NaN:padding );
	dateDisplay.layoutData = dateLayout;
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null )
		return;
	
	var msgPack:ISFSObject = _data as SFSObject;
	if( MessageTypes.isComment( msgPack.getShort("m") ) )
	{
		showComment(msgPack);
		return;
	}
	
	var user:ISFSObject = findUser(msgPack.getInt("i"));

	setStyle(STYLE_MESSAGE);
	
	var itsMe:Boolean = msgPack.getInt("i") == player.id;
	meSkin.visible = itsMe;
	otherSkin.visible = !itsMe;
	
	senderDisplay.text = msgPack.getText("s");
	senderLayout.right = itsMe ? padding : otherPadding;
	
	roleDisplay.text = user==null?"":(loc("lobby_role_" + user.getShort("pr")));
	roleLayout.left = itsMe ? otherPadding : padding;
	
	messageDisplay.text = msgPack.getUtfString("t")+"\n\n";
	messageLayout.right = itsMe ? padding : otherPadding;
	messageLayout.left = itsMe ? otherPadding : padding;

	date.time = msgPack.getInt("u")*1000;
	dateDisplay.text = StrUtils.dateToTime(date);
	dateLayout.left = itsMe ? otherPadding : padding;
	
	resetSize();
}

private function setStyle(style:int):void
{
	if ( this.style == style )
		return;
	
	this.style = style;
	if( this.style == STYLE_COMMENT )
	{
		meSkin.removeFromParent();
		otherSkin.removeFromParent();
		senderDisplay.removeFromParent();
		roleDisplay.removeFromParent();
		messageDisplay.removeFromParent();
		dateDisplay.removeFromParent();
		addChild(commentDisplay);
	} 
	else if ( this.style == STYLE_MESSAGE )
	{
		addChild(meSkin);
		addChild(otherSkin);
		addChild(senderDisplay);
		addChild(roleDisplay);
		addChild(messageDisplay);
		addChild(dateDisplay);
		if( commentDisplay != null )
			commentDisplay.removeFromParent();
	}
}

private function resetSize():void
{
	if( height != 0 || style==STYLE_COMMENT )
		height = style==STYLE_COMMENT ? padding*1.4 :(messageLayout.top + messageDisplay.height + padding);
}

private function showComment(msgPack:ISFSObject):void
{
	var comment:String = "";
	switch(msgPack.getShort("m"))
	{
		case MessageTypes.M10_COMMENT_JOINT:	comment = loc("lobby_comment_join",		[msgPack.getText("s")]);	break;
		case MessageTypes.M11_COMMENT_LEAVE:	comment = loc("lobby_comment_leave",	[msgPack.getText("s")]);	break;
		case MessageTypes.M12_COMMENT_KICK:		comment = loc("lobby_comment_kick",		[msgPack.getText("o"), msgPack.getText("s")]);	break;
		case MessageTypes.M13_COMMENT_PROMOTE:	comment = loc("lobby_comment_promote",	[msgPack.getText("o"), msgPack.getText("s"), loc("obby_role_1"+msgPack.getShort("p"))]);	break;
		case MessageTypes.M14_COMMENT_DEMOTE:	comment = loc("lobby_comment_demote",	[msgPack.getText("o"), msgPack.getText("s"), loc("obby_role_1"+msgPack.getShort("p"))]);	break;
	}

	if( commentDisplay == null )
	{
		commentDisplay = new ShadowLabel(comment, 1, 0, "center", null, false, null, 0.8); 
		commentDisplay.layoutData = new AnchorLayoutData( NaN, NaN, NaN, NaN, 0, 0);
	}
	else
	{
		commentDisplay.text = comment;
	}
	setStyle(STYLE_COMMENT);
	resetSize();
}

private function findUser(uid:int):ISFSObject
{
	if( SFSConnection.instance.myLobby == null )
		return null;
	var all:ISFSArray = SFSConnection.instance.myLobby.getVariable("all").getSFSArrayValue();
	var allSize:int = all.size();
	for( var i:int=0; i<allSize; i++ )
	{
		if( all.getSFSObject(i).getInt("id") == uid )
			return all.getSFSObject(i);
	}
	return null;
}		


}
}