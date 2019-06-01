package com.gerantech.towercraft.controls.segments.lobby
{
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import feathers.controls.AutoSizeMode;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;

public class LobbyChatItemMessageSegment extends LobbyChatItemSegment
{
private var senderDisplay:RTLLabel;
//private var roleDisplay:RTLLabel;
private var messageDisplay:RTLLabel;
private var dateDisplay:RTLLabel;

private var meSkin:ImageLoader;
private var otherSkin:ImageLoader;

private var inPadding:int;
private var senderLayout:AnchorLayoutData;
//private var roleLayout:AnchorLayoutData;
private var messageLayout:AnchorLayoutData;
private var dateLayout:AnchorLayoutData;

public function LobbyChatItemMessageSegment(owner:FastList) { super(owner); }
override public function init():void
{
	super.init();
	autoSizeMode = AutoSizeMode.CONTENT;
	
	inPadding = padding * 0.5;

	meSkin = new ImageLoader();
	meSkin.scale9Grid = new Rectangle(44, 34, 8, 8);
	meSkin.visible = false;
	meSkin.source = Assets.getTexture("theme/balloon-me", "gui");
	meSkin.layoutData = new AnchorLayoutData( padding * 0.1, padding * 0.1, padding * 0.1, otherPadding - padding * 0.9 );
	addChild(meSkin);
	
	otherSkin = new ImageLoader();
	otherSkin.scale9Grid = meSkin.scale9Grid
	otherSkin.visible = false;
	otherSkin.source = Assets.getTexture("theme/balloon-other", "gui");
	otherSkin.layoutData = new AnchorLayoutData( padding * 0.1, otherPadding - padding * 0.9, padding * 0.1, padding * 0.1 );
	addChild(otherSkin);
	
	senderDisplay = new RTLLabel("", MainTheme.PRIMARY_BACKGROUND_COLOR, null, null, false, null, 0.8);
	senderLayout = new AnchorLayoutData(30);
	senderDisplay.layoutData = senderLayout;
	addChild(senderDisplay);
	
	/*roleDisplay = new RTLLabel("", MainTheme.PRIMARY_BACKGROUND_COLOR, null, null, false, null, 0.7);
	roleLayout = new AnchorLayoutData( padding );
	roleDisplay.layoutData = roleLayout;
	addChild(roleDisplay);
	*/
	messageDisplay = new RTLLabel("", MainTheme.PRIMARY_BACKGROUND_COLOR, "justify", null, true, null, 0.6, "OpenEmoji");
	if( appModel.platform == AppModel.PLATFORM_ANDROID )
		messageDisplay.leading = -padding * 0.4;
	messageLayout = new AnchorLayoutData( padding * 2);
	messageDisplay.layoutData = messageLayout;
	addChild(messageDisplay);
	
	dateDisplay = new RTLLabel("", MainTheme.DESCRIPTION_TEXT_COLOR, null, null, false, null, 0.5);
	dateLayout = new AnchorLayoutData(NaN, NaN, 26);
	dateDisplay.layoutData = dateLayout;			
	addChild(dateDisplay);
}

override public function commitData(_data:ISFSObject, index:int):void
{
	if( owner.loadingState == 0 && owner.dataProvider.length - index > 10 )
	{
		height = 200;
		return;
	}
	
	super.commitData(_data, index);
	
	meSkin.visible = itsMe;
	otherSkin.visible = !itsMe;
	
	senderDisplay.text = data.getUtfString("s");
	senderLayout.right = ( itsMe ? padding : otherPadding ) + inPadding;
	
	//var user:ISFSObject = findUser(data.getInt("i"));
	//roleDisplay.text = user == null?"":(loc("lobby_role_" + user.getShort("permission")));
	//roleLayout.left = ( itsMe ? otherPadding : padding ) + inPadding;
	
	messageLayout.right = ( itsMe ? padding : otherPadding ) + inPadding;
	messageLayout.left = ( itsMe ? otherPadding : padding ) + inPadding;
	messageDisplay.text = data.getUtfString("t");
	messageDisplay.validate();
	
	dateDisplay.text = StrUtils.toElapsed(timeManager.now - data.getInt("u"));
	dateLayout.left = ( itsMe ? otherPadding : 14 ) + inPadding;
	
	height = messageDisplay.height + padding * 3;
}
}
}