package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.MessageTypes;

import flash.geom.Rectangle;

import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class InboxItemRenderer extends BaseCustomItemRenderer
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
private var acceptButton:CustomButton;
private var declineButton:CustomButton;


override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	height = 140 * appModel.scale;
	padding = 36 * appModel.scale;
	offsetY = -8*AppModel.instance.scale
	date = new Date();
	
	mySkin = new Image(appModel.theme.itemRendererDisabledSkinTexture);
	mySkin.scale9Grid = BaseMetalWorksMobileTheme.ITEM_RENDERER_SCALE9_GRID;
	backgroundSkin = mySkin;
	
	senderLayout = new AnchorLayoutData( NaN, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN , NaN, offsetY);
	senderDisplay = new RTLLabel("", 1, null, null, false, null, 0.8);
	senderDisplay.width = padding * 6.4;
	senderDisplay.layoutData = senderLayout;
	addChild(senderDisplay);

	messageLayout = new AnchorLayoutData( NaN, padding*(appModel.isLTR?5:8), NaN, padding*(appModel.isLTR?8:5) , NaN, offsetY);
	messageDisplay = new RTLLabel("", 0xDDEEEE, "justify", null, true, null, 0.7);
	messageDisplay.wordWrap = false;
	messageDisplay.layoutData = messageLayout;
	addChild(messageDisplay);
	
	dateLayout = new AnchorLayoutData( NaN, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding, NaN, 0 );
	dateDisplay = new RTLLabel("", READ_TEXT_COLOR, null, null, false, null, 0.6);
	dateDisplay.alpha = 0.8;
	dateDisplay.layoutData = dateLayout;
	addChild(dateDisplay);
	
	acceptButton = new CustomButton();
	acceptButton.alpha = 0;
	acceptButton.height = 100 * appModel.scale;
	acceptButton.label = loc("popup_accept_label");
	acceptButton.layoutData = new AnchorLayoutData( NaN, NaN, padding, padding);
	acceptButton.addEventListener(Event.TRIGGERED, buttons_eventHandler);
	
	declineButton = new CustomButton();
	declineButton.alpha = 0;
	declineButton.height = 100 * appModel.scale;
	declineButton.style = "danger";
	declineButton.label = loc("popup_cancel_label");
	declineButton.layoutData = new AnchorLayoutData( NaN, NaN, padding, padding*9);
	declineButton.addEventListener(Event.TRIGGERED, buttons_eventHandler);
}

override protected function commitData():void
{
	super.commitData();
	if(_data == null || _owner == null)
		return;

	date.time = _data.utc * 1000;
	senderDisplay.text = _data.sender;
	messageDisplay.text = _data.text.substr(0,2)=="__"?loc(_data.text.substr(2), [_data.sender]):_data.text;
	dateDisplay.text = StrUtils.getDateString(date);
	acceptButton.label = loc(_data.type == MessageTypes.M50_URL ? "go_label" : "popup_accept_label");
	updateSkin();
}

private function updateSkin():void
{
	if( isSelected )
		mySkin.texture = appModel.theme.itemRendererUpSkinTexture;
	else
		mySkin.texture = _data.read==0 ? appModel.theme.itemRendererSelectedSkinTexture : appModel.theme.itemRendererDisabledSkinTexture;
	senderDisplay.alpha = _data.read==0 || isSelected ? 1 : 0.8;
	messageDisplay.alpha = _data.read==0 || isSelected ? 0.92 : 0.8;
}

override public function set isSelected(value:Boolean):void
{
	var needSchange:Boolean = super.isSelected != value
	super.isSelected = value;
	if( !needSchange )
		return;
	updateSkin();
	
	if( value && _data.read == 0 )
	{
		_owner.dispatchEventWith(Event.OPEN, false, _data);
		_data.read = 1;
	}
	
	senderLayout.top = value ? padding*0.8 : NaN;
	senderDisplay.width = padding*(value?12:6.4);
	senderLayout.verticalCenter = value ? NaN : offsetY;
	
	messageDisplay.height = NaN;
	messageLayout.top = value ? padding*2.4 : NaN;
	messageLayout.verticalCenter = value ? NaN : offsetY;
	messageLayout.right = padding*(value?1:(appModel.isLTR?5:8));
	messageLayout.left = padding*(value?1:(appModel.isLTR?8:5));
	
	messageDisplay.wordWrap = value;
	messageDisplay.validate();
	
	dateLayout.top = value ? padding*0.6 : NaN;
	dateLayout.right = value ? (appModel.isLTR?padding*0.7:NaN) : (appModel.isLTR?padding:NaN);
	dateLayout.left = value ? (appModel.isLTR?NaN:padding*0.7) : (appModel.isLTR?NaN:padding);
	dateLayout.verticalCenter = value ? NaN : offsetY;
	dateDisplay.text = StrUtils.getDateString(date, value);

	if( !value )
	{
		acceptButton.removeFromParent();
		declineButton.removeFromParent();
	}
	
	var hasButton:Boolean = _data.type == MessageTypes.M40_CONFIRM || _data.type == MessageTypes.M50_URL;
	var _h:Number = value?(messageDisplay.height+padding*(4/messageDisplay.numLines)+padding+(hasButton?declineButton.height:0) ):(140*appModel.scale);
	Starling.juggler.tween(this, TWEEN_TIME, {height:_h, transition:Transitions.EASE_IN_OUT, onComplete:tweenCompleted, onCompleteArgs:[value]});
	function tweenCompleted(_selected:Boolean):void
	{
		if( !value )
			return;
		
		if( hasButton )
		{
			appear(acceptButton)
			if( _data.type == MessageTypes.M40_CONFIRM )
				appear(declineButton)
		}
	}
}

private function appear(button:CustomButton):void
{
	button.alpha = 0;
	addChild(button);
	Starling.juggler.tween(button, TWEEN_TIME, {alpha:1});
}

private function buttons_eventHandler(event:Event):void
{
	if( event.currentTarget == acceptButton )
		_owner.dispatchEventWith(Event.SELECT, false, _data);
	else
		_owner.dispatchEventWith(Event.CANCEL, false, _data);
}

override public function dispose():void
{
	Starling.juggler.removeTweens(this);
	Starling.juggler.removeTweens(acceptButton);
	Starling.juggler.removeTweens(declineButton);
	super.dispose();
}
}
}