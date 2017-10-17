package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.controls.Switcher;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.buttons.ExchangeButton;
import com.gerantech.towercraft.controls.texts.CustomTextInput;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSObject;

import flash.text.ReturnKeyLabel;
import flash.text.SoftKeyboardType;

import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.events.Event;

public class LobbyCreateSegment extends Segment
{
private var padding:int;
private var controlWidth:int;

private var nameInput:CustomTextInput;
private var bioInput:CustomTextInput;
private var maxSwitcher:Switcher;
private var minSwitcher:Switcher;
private var errorDisplay:RTLLabel;

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	
	padding = 36 * appModel.scale;
	controlWidth = 240 * appModel.scale;
	var controlH:int = 96 * appModel.scale;
	
	var tilteDisplay:RTLLabel = new RTLLabel(loc("lobby_create_message"), 1, "center" );
	tilteDisplay.layoutData = new AnchorLayoutData( padding, padding, NaN, padding );
	addChild(tilteDisplay);

	nameInput = addInput("name", controlH*1.4, controlH*1.2);
	bioInput = addInput("bio", controlH*3, controlH*3);
	maxSwitcher = addSwitcher("max", controlH*6.5, controlH, 10, 30, 50, 20);
	minSwitcher = addSwitcher("min", controlH*8, controlH, 0, 200, 3000, 200);
	
	errorDisplay = new RTLLabel( "", 0xFF0000, "center", null, false, null, 0.9 );
	errorDisplay.layoutData = new AnchorLayoutData( controlH*11, padding, controlH*2, padding );
	addChild(errorDisplay);
	
	var createMessage:RTLLabel = new RTLLabel(loc("lobby_create_button"), 0, null, null, false, null, 0.8);
	createMessage.layoutData = new AnchorLayoutData(NaN, NaN, controlH*2, NaN, 0);
	addChild(createMessage);

	var createButton:ExchangeButton = new ExchangeButton();
	createButton.width = controlH * 4;
	createButton.isEnabled = game.lobby.creatable();
	createButton.count = game.lobby.get_createRequirements().values()[0];
	createButton.type = game.lobby.get_createRequirements().keys()[0];
	createButton.layoutData = new AnchorLayoutData(NaN, NaN, controlH*0.5, NaN, 0);
	createButton.addEventListener(Event.TRIGGERED,  createButton_triggeredHandler);
	addChild(createButton);
}

private function createButton_triggeredHandler(event:Event):void
{
	if( nameInput.text.length < 4 || nameInput.text.length > 16 )
	{
		errorDisplay.text = loc("text_size_warn", [loc("lobby_name"), 4, 16]);
		return;
	}
	if( bioInput.text.length < 10 || bioInput.text.length > 128 )
	{
		errorDisplay.text = loc("text_size_warn", [loc("lobby_bio"), 10, 128]);
		return;
	}
		
	var params:SFSObject = new SFSObject();
	params.putUtfString("name", nameInput.text);
	params.putUtfString("bio", bioInput.text);
	params.putInt("max", maxSwitcher.value);
	params.putInt("min", minSwitcher.value);
	params.putInt("pic", 10);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnectionroomCreateRresponseHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_CREATE, params);
}		

private function addInput(controlName:String, positionY:int, controlHeight:int):CustomTextInput
{
	var inputControl:CustomTextInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.DEFAULT);
	inputControl.promptProperties.fontSize = inputControl.textEditorProperties.fontSize = 0.8*appModel.theme.gameFontSize*appModel.scale;
	//nameInput.maxChars = game.loginData.nameMaxLen ;
	inputControl.prompt = loc("lobby_"+controlName);
	inputControl.layoutData = new AnchorLayoutData( positionY, padding, NaN, padding );
	inputControl.height = controlHeight;
	addChild(inputControl);
	return inputControl;
}
private function addSwitcher(controlName:String, positionY:int, controlHeight:int, min:int, value:int, max:int, stepInterval:int):Switcher
{
	var labelDisplay:RTLLabel = new RTLLabel( loc("lobby_"+controlName), 0, null, null, false, null, 0.8 );
	labelDisplay.width = controlWidth;
	labelDisplay.layoutData = new AnchorLayoutData( positionY+controlHeight/4, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN );
	addChild(labelDisplay);
	
	var switcher:Switcher = new Switcher(min, value, max, stepInterval);
	switcher.width = controlWidth * 2;
	switcher.layoutData = new AnchorLayoutData( positionY, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding);
	//switcher.layoutData = new AnchorLayoutData( positionY, appModel.isLTR?padding:controlWidth+padding*2, NaN, appModel.isLTR?controlWidth+padding*2:padding );
	switcher.height = controlHeight;
	addChild(switcher);
	return switcher;
}
protected function sfsConnectionroomCreateRresponseHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.LOBBY_CREATE )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnectionroomCreateRresponseHandler);
	var data:SFSObject = event.params.params as SFSObject;
	if( data.getInt("response") >= 0 )
	{
		game.lobby.create();
		dispatchEventWith(Event.UPDATE, true);
		return;
	}
	if( data.getInt("response") == -1 )
		appModel.navigator.addLog(loc("lobby_create_exits_message"));
	else 
		appModel.navigator.addLog(loc("lobby_create_error_message"));
}
}
}