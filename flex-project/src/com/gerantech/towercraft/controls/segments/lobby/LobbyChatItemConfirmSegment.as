package com.gerantech.towercraft.controls.segments.lobby
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
import com.smartfoxserver.v2.entities.data.ISFSObject;

import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;

import starling.events.Event;

public class LobbyChatItemConfirmSegment extends LobbyChatItemSegment
{
	
private var messageDisplay:RTLLabel;
private var acceptButton:CustomButton;
private var declineButton:CustomButton;

override public function init():void
{
	super.init();
	height = 220*appModel.scale;
	
	var background:ImageLoader = new ImageLoader();
	background.source = appModel.theme.popupBackgroundSkinTexture;
	background.layoutData = new AnchorLayoutData( 0, padding*0.5, 0, padding*0.5);
	background.scale9Grid = BaseMetalWorksMobileTheme.POPUP_SCALE9_GRID;
	addChild(background);
	
	acceptButton = new CustomButton();
	acceptButton.width = 280 * appModel.scale;
	acceptButton.height = 100 * appModel.scale;
	acceptButton.label = loc("popup_accept_label");
	acceptButton.layoutData = new AnchorLayoutData(NaN, padding*4, padding*0.5);
	acceptButton.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
	addChild(acceptButton);
	
	declineButton = new CustomButton();
	declineButton.width = 280 * appModel.scale;
	declineButton.height = 100 * appModel.scale;
	declineButton.label = loc("popup_cancel_label");
	declineButton.style = "danger";
	declineButton.layoutData = new AnchorLayoutData(NaN, NaN, padding*0.5, padding*4);
	declineButton.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
	addChild(declineButton);
}

private function buttons_triggeredHandler(event:Event):void
{
	dispatchEventWith( Event.TRIGGERED, false, event.currentTarget == acceptButton );
}

override public function commitData(_data:ISFSObject):void
{
	super.commitData(_data);
	createMessageDisplay();
}

private function createMessageDisplay():void
{
	if( messageDisplay != null )
	{
		messageDisplay.text = loc("lobby_join_request", [data.getUtfString("on")]);
		return;
	}
	messageDisplay = new RTLLabel(loc("lobby_join_request", [data.getUtfString("on")]), 1, "center", null, false, null, 0.8);
	messageDisplay.layoutData = new AnchorLayoutData( padding*0.5, padding, NaN, padding);;
	addChild(messageDisplay);
}
}
}