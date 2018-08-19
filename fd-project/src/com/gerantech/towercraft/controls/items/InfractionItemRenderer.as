package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.MessageTypes;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;


public class InfractionItemRenderer extends AbstractTouchableListItemRenderer
{
private static const READ_TEXT_COLOR:uint = 0xEEFFFF;
private static const TWEEN_TIME:Number = 0.3;

private var offsetY:Number;
private var padding:int;
private var senderLayout:AnchorLayoutData;
private var messageLayout:AnchorLayoutData;
private var dateLayout:AnchorLayoutData;
private var mySkin:Image;
private var senderDisplay:RTLLabel;
private var messageDisplay:RTLLabel;
private var dateDisplay:RTLLabel;
private var date:Date;
private var message:SFSObject;
private var banButton:CustomButton;
private var deleteButton:CustomButton;
private var offenderButton:CustomButton;
private var reporterButton:CustomButton;

public function InfractionItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	height = 280;
	padding = 16;
	date = new Date();
	
	mySkin = new Image(appModel.theme.itemRendererDisabledSkinTexture);
	mySkin.scale9Grid = BaseMetalWorksMobileTheme.ITEM_RENDERER_SCALE9_GRID;
	backgroundSkin = mySkin;
	
	senderDisplay = new RTLLabel("", 1, null, null, false, null, 0.72);
	senderDisplay.width = padding * 12;
	senderDisplay.layoutData = new AnchorLayoutData( padding, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN);
	addChild(senderDisplay);

	messageDisplay = new RTLLabel("", 0xDDEEEE, "justify", null, true, null, 0.6);
	messageDisplay.wordWrap = false;
	messageDisplay.touchable = false;
	messageDisplay.layoutData = new AnchorLayoutData( padding, padding, NaN, padding );
	addChild(messageDisplay);
	
	dateDisplay = new RTLLabel("", READ_TEXT_COLOR, null, null, false, null, 0.6);
	dateDisplay.touchable = false;
	dateDisplay.alpha = 0.8;
	dateDisplay.layoutData = new AnchorLayoutData( padding, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding );
	addChild(dateDisplay);
	
	offenderButton = new CustomButton();
	offenderButton.height = 70;
	offenderButton.width = 420;
	offenderButton.layoutData = new AnchorLayoutData( NaN, padding, padding );
	offenderButton.addEventListener(Event.TRIGGERED, buttons_eventHandler);
	addChild(offenderButton);
	
	reporterButton = new CustomButton();
	reporterButton.style = CustomButton.STYLE_NEUTRAL;
	reporterButton.height = 70;
	reporterButton.width = 280;
	reporterButton.layoutData = new AnchorLayoutData( NaN, padding + 432, padding );
	reporterButton.addEventListener(Event.TRIGGERED, buttons_eventHandler);
	addChild(reporterButton);
	
	banButton = new CustomButton();
	banButton.width = banButton.height = 100;
	banButton.style = CustomButton.STYLE_DANGER;
	banButton.icon = Assets.getTexture("settings-5", "gui");
	banButton.layoutData = new AnchorLayoutData( NaN, NaN, padding, padding );
	banButton.addEventListener(Event.TRIGGERED, buttons_eventHandler);
	addChild(banButton);
	
	deleteButton = new CustomButton();
	deleteButton.width = deleteButton.height = 100;
	deleteButton.icon = Assets.getTexture("improve-1", "gui");
	deleteButton.layoutData = new AnchorLayoutData( NaN, NaN, padding, 96 + padding * 2 );
	deleteButton.addEventListener(Event.TRIGGERED, buttons_eventHandler);
	addChild(deleteButton);
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null || _owner == null )
		return;

	message = _data as SFSObject;
	date.time = message.getLong("offend_at");
	dateDisplay.text = StrUtils.getDateString(date, true);
	messageDisplay.text = message.getUtfString("content");
	offenderButton.label = message.getText("name") + "   " + message.getInt("offender").toString();
	reporterButton.label = message.getInt("reporter").toString();
}

private function buttons_eventHandler(event:Event):void
{
	if( event.currentTarget == banButton )
		_owner.dispatchEventWith(Event.SELECT, false, message);
	else if( event.currentTarget == deleteButton )
		_owner.dispatchEventWith(Event.CANCEL, false, message);
	else if( event.currentTarget == offenderButton )
		_owner.dispatchEventWith(Event.READY, false, message);
	else if( event.currentTarget == reporterButton )
		_owner.dispatchEventWith(Event.OPEN, false, message);
}
}
}