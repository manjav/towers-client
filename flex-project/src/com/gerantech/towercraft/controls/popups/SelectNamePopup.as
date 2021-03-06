package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.screens.DashboardScreen;
import com.gerantech.towercraft.controls.segments.ExchangeSegment;
import com.gerantech.towercraft.controls.texts.CustomTextInput;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.Exchange;
import com.gt.towers.exchanges.ExchangeItem;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSObject;

import flash.geom.Rectangle;
import flash.text.ReturnKeyLabel;
import flash.text.SoftKeyboardType;
import flash.utils.setTimeout;

import feathers.events.FeathersEventType;

import starling.events.Event;

public class SelectNamePopup extends ConfirmPopup
{
private var errorDisplay:RTLLabel;

private var textInput:CustomTextInput;
public function SelectNamePopup()
{
	super(loc("popup_select_name_title"), player.nickName != "guest" ? "100" : loc("popup_register_label"), null);
}

override protected function initialize():void
{
	super.initialize();
	closeOnOverlay = player.nickName != "guest";
	transitionOut.destinationBound = transitionIn.sourceBound = new Rectangle(stage.stageWidth*0.10, stage.stageHeight*0.35, stage.stageWidth*0.8, stage.stageHeight*0.25);
	transitionIn.destinationBound = transitionOut.sourceBound = new Rectangle(stage.stageWidth*0.10, stage.stageHeight*0.30, stage.stageWidth*0.8, stage.stageHeight*0.3);

	textInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.GO);
	textInput.maxChars = game.loginData.nameMaxLen ;
	textInput.prompt = closeOnOverlay ? player.nickName : loc( "popup_select_name_prompt" );
	textInput.addEventListener(Event.CHANGE, textInput_changeHandler);
	textInput.addEventListener(FeathersEventType.ENTER, acceptButton_triggeredHandler);
	container.addChild(textInput);
	
	errorDisplay = new RTLLabel("", 0xFF0000);
	container.addChild(errorDisplay);
	
	acceptButton.isEnabled = false;
	if( closeOnOverlay )
	acceptButton.icon = Assets.getTexture("res-"+1003, "gui");
	declineButton.removeFromParent();
	rejustLayoutByTransitionData();
}

protected function textInput_changeHandler(event:Event):void
{
	acceptButton.isEnabled = textInput.text.length >= game.loginData.nameMinLen;
}

protected override function acceptButton_triggeredHandler(event:Event):void
{
	var selectedName:String = textInput.text;
	var nameLen:int = selectedName.length;
	if ( nameLen < game.loginData.nameMinLen || nameLen > game.loginData.nameMaxLen )
	{
		errorDisplay.text = loc("popup_select_name_1", [game.loginData.nameMinLen, game.loginData.nameMaxLen] );
		return;
	}
	
	if ( selectedName.substr(nameLen-2) == " " || selectedName.substr(0,1) == " " || selectedName.search("  ") > -1 || selectedName == "root" || selectedName == "super-user" || selectedName.search("bot") > -1 || selectedName.search("بات") > -1 )
	{
		errorDisplay.text = loc("popup_select_name_3");
		return;
	}
	var sfs:SFSObject = SFSObject.newInstance();
	sfs.putUtfString( "name", selectedName );
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsCOnnection_extensionResponseHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.SELECT_NAME, sfs );
}

protected function sfsCOnnection_extensionResponseHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.SELECT_NAME )
		return;
	
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsCOnnection_extensionResponseHandler);
	var result:SFSObject = event.params.params as SFSObject;trace(result.getDump())
	var response:int = result.getInt("response");
	
	if( response != 0 )
	{
		if( response == 2 )
		{
			DashboardScreen.tabIndex = 0;
			ExchangeSegment.focusedCategory = 3;
			appModel.navigator.addLog(loc("popup_select_name_2"));
			setTimeout(appModel.navigator.popScreen, 700);
			close();
			return;
		}
		errorDisplay.text = loc("popup_select_name_" + response, [game.loginData.nameMinLen, game.loginData.nameMaxLen] );
		return;
	}
	
	if( closeOnOverlay )
		exchanger.exchange(new ExchangeItem(-1, ResourceType.CURRENCY_HARD, 100), 0, 0);
	
	player.nickName = textInput.text;
	dispatchEventWith( Event.COMPLETE );
	close();
}
}
}