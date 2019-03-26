package com.gerantech.towercraft.controls.items.lobby
{
import com.gerantech.towercraft.controls.items.AbstractTouchableListItemRenderer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import feathers.controls.AutoSizeMode;
import feathers.controls.ImageLoader;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;
import flash.geom.Rectangle;
import starling.events.Event;
import starling.events.Touch;

public class InboxChatItemRenderer extends AbstractTouchableListItemRenderer
{
protected static const TYPE_MESSAGE:int = 0;
protected static const TYPE_COMMENT:int = 10;
protected static const TYPE_DONATE:int = 20;
protected static const TYPE_BATTLE:int = 30;
protected static const TYPE_CONFIRM:int = 40;
	
private var meId:int;
private var type:int;
private var meSkin:ImageLoader;
private var otherSkin:ImageLoader;
private var messageDisplay:RTLLabel;
private var dateDisplay:RTLLabel;
private var statusDisplay:ImageLoader;
private var messageLayout:AnchorLayoutData;
private var date:Date;
private var dateLayout:AnchorLayoutData;

public function InboxChatItemRenderer(meId:int){ this.meId = meId; }
public function getTouch():Touch
{
	return touch;
}
override protected function initialize():void
{
	super.initialize();
	
	date = new Date();
	
	autoSizeMode = AutoSizeMode.CONTENT;
	layout = new AnchorLayout();
	
	meSkin = new ImageLoader();
	meSkin.scale9Grid = new Rectangle(44, 34, 8, 8);
	meSkin.visible = false;
	meSkin.source = Assets.getTexture("theme/balloon-me", "gui");
	meSkin.layoutData = new AnchorLayoutData(2, 10, 2, 50);
	addChild(meSkin);
	
	otherSkin = new ImageLoader();
	otherSkin.scale9Grid = meSkin.scale9Grid
	otherSkin.visible = false;
	otherSkin.source = Assets.getTexture("theme/balloon-other", "gui");
	otherSkin.layoutData = new AnchorLayoutData(2, 50, 2, 10);
	addChild(otherSkin);
	
	statusDisplay = new ImageLoader();
	statusDisplay.height = 24;
	statusDisplay.layoutData = new AnchorLayoutData(NaN, NaN, 22, 76);
	addChild(statusDisplay);
	
	messageLayout = new AnchorLayoutData(40);
	messageDisplay = new RTLLabel("", MainTheme.PRIMARY_BACKGROUND_COLOR, "justify", null, true, null, 0.65, "OpenEmoji");
	if( appModel.platform == AppModel.PLATFORM_ANDROID )
		messageDisplay.leading = -16;
	messageDisplay.layoutData = messageLayout;
	addChild(messageDisplay);
	
	dateDisplay = new RTLLabel("", MainTheme.DESCRIPTION_TEXT_COLOR, null, null, false, null, 0.55, "OpenEmoji");
	dateLayout = new AnchorLayoutData(NaN, NaN, 20);
	dateDisplay.layoutData = dateLayout;			
	addChild(dateDisplay);
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
	
	var itsMe:Boolean = _data.getInt("senderId") == meId;
	
	meSkin.visible = itsMe;
	otherSkin.visible = !itsMe;
	dateLayout.right	= messageLayout.right	= itsMe ? 50 : 100;
	dateLayout.left		= messageLayout.left	= itsMe ? 100 : 50;
	
	if( itsMe )
		statusDisplay.source = Assets.getTexture("check-blue-" + _data.getInt("status"), "gui");
	statusDisplay.visible = itsMe;

	messageDisplay.text = _data.getUtfString("text");
	messageDisplay.validate();
	height = messageLayout.top + messageDisplay.height + 90;
	
	date.time = _data.getLong("timestamp");
	dateDisplay.text = StrUtils.getDateString(date, true);
}
}
}