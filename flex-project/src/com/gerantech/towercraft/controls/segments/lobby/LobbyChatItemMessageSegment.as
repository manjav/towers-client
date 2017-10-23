package com.gerantech.towercraft.controls.segments.lobby
{
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.smartfoxserver.v2.entities.data.ISFSObject;

import flash.geom.Rectangle;

import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;

public class LobbyChatItemMessageSegment extends LobbyChatItemSegment
{
private var senderDisplay:RTLLabel;
private var roleDisplay:RTLLabel;
private var messageDisplay:RTLLabel;
private var dateDisplay:RTLLabel;

private var meSkin:ImageLoader;
private var otherSkin:ImageLoader;

private var date:Date;
private var inPadding:int;
private var senderLayout:AnchorLayoutData;
private var roleLayout:AnchorLayoutData;
private var messageLayout:AnchorLayoutData;
private var dateLayout:AnchorLayoutData;


override public function init():void
{
	super.init();
	
	date = new Date();
	inPadding = padding * 0.5;

	meSkin = new ImageLoader();
	meSkin.scale9Grid = new Rectangle(22, 17, 4, 4);
	meSkin.visible = false;
	meSkin.source = Assets.getTexture("theme/balloon-me", "gui");
	meSkin.layoutData = new AnchorLayoutData( padding*0.1, padding*0.1, padding*0.1, otherPadding-padding*0.9 );
	addChild(meSkin);
	
	otherSkin = new ImageLoader();
	otherSkin.scale9Grid = new Rectangle(22, 17, 4, 4);
	otherSkin.visible = false;
	otherSkin.source = Assets.getTexture("theme/balloon-other", "gui");
	otherSkin.layoutData = new AnchorLayoutData( padding*0.1, otherPadding-padding*0.9, padding*0.1, padding*0.1 );
	addChild(otherSkin);
	
	senderDisplay = new RTLLabel("", BaseMetalWorksMobileTheme.PRIMARY_BACKGROUND_COLOR, null, null, false, null, 0.8);
	senderLayout = new AnchorLayoutData( padding );
	senderDisplay.layoutData = senderLayout;
	addChild(senderDisplay);
	
	roleDisplay = new RTLLabel("", BaseMetalWorksMobileTheme.PRIMARY_BACKGROUND_COLOR, null, null, false, null, 0.7);
	roleLayout = new AnchorLayoutData( padding );
	roleDisplay.layoutData = roleLayout;
	addChild(roleDisplay);
	
	messageDisplay = new RTLLabel("", BaseMetalWorksMobileTheme.PRIMARY_BACKGROUND_COLOR, "justify", null, true, null, 0.7, "OpenEmoji");
	if( appModel.platform == AppModel.PLATFORM_ANDROID )
		messageDisplay.leading = -padding;
	messageLayout = new AnchorLayoutData( padding * 2 , 0, padding, 0);
	messageDisplay.layoutData = messageLayout;
	addChild(messageDisplay);
	
	dateDisplay = new RTLLabel("", BaseMetalWorksMobileTheme.DESCRIPTION_TEXT_COLOR, null, null, false, null, 0.7);
	dateLayout = new AnchorLayoutData( NaN, appModel.isLTR?padding:NaN, padding, appModel.isLTR?NaN:padding );
	dateDisplay.layoutData = dateLayout;			
	addChild(dateDisplay);
}

override public function commitData(_data:ISFSObject, lobbyData:ISFSObject):void
{
	super.commitData(_data, lobbyData);
	
	meSkin.visible = itsMe;
	otherSkin.visible = !itsMe;
	
	senderDisplay.text = data.getText("s");
	senderLayout.right = ( itsMe ? padding : otherPadding ) + inPadding;
	
	var user:ISFSObject = findUser(data.getInt("i"));
	roleDisplay.text = user==null?"":(loc("lobby_role_" + user.getShort("permission")));
	roleLayout.left = ( itsMe ? otherPadding : padding ) + inPadding;
	
	messageDisplay.text = data.getUtfString("t")+"\n\n";
	messageLayout.right = ( itsMe ? padding : otherPadding ) + inPadding;
	messageLayout.left = ( itsMe ? otherPadding : padding ) + inPadding;
	
	date.time = data.getInt("u")*1000;
	dateDisplay.text = StrUtils.dateToTime(date);
	dateLayout.left = ( itsMe ? otherPadding : padding ) + inPadding;
	validate();
}
}
}