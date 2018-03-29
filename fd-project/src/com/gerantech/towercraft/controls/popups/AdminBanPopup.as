package com.gerantech.towercraft.controls.popups 
{
	import com.gerantech.towercraft.controls.texts.CustomTextInput;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	import feathers.controls.Radio;
	import feathers.controls.ToggleSwitch;
	import flash.geom.Rectangle;
	import flash.text.ReturnKeyLabel;
	import flash.text.SoftKeyboardType;
	import starling.events.Event;
/**
* ...
* @author MAnsour Djawadi
*/
public class AdminBanPopup extends ConfirmPopup 
{

private var userId:int;
private var idInput:CustomTextInput;
private var messageInput:CustomTextInput;
private var errorDisplay:RTLLabel;
private var warnMode:ToggleSwitch;
private var lenInput:com.gerantech.towercraft.controls.texts.CustomTextInput;

public function AdminBanPopup(userId:int)
{
	super(loc("popup_ban_button"), loc("popup_ban_button"), null);
	this.userId = userId;
}

override protected function initialize():void
{
	super.initialize();
	transitionIn.destinationBound = transitionIn.sourceBound = new Rectangle(stage.stageWidth * 0.10, stage.stageHeight * 0.2, stage.stageWidth * 0.8, stage.stageHeight * 0.6);
	transitionOut.destinationBound = transitionOut.sourceBound = new Rectangle(stage.stageWidth * 0.10, stage.stageHeight * 0.2, stage.stageWidth * 0.8, stage.stageHeight * 0.6);
	
	idInput = new CustomTextInput(SoftKeyboardType.NUMBER, ReturnKeyLabel.DEFAULT);
	idInput.text = userId.toString();
	container.addChild(idInput);
	
	messageInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.DEFAULT);
	messageInput.height = padding * 6;
	messageInput.text = "تعلیق به علت تخطی از قوانین بازی";
	container.addChild(messageInput);
	
	lenInput = new CustomTextInput(SoftKeyboardType.NUMBER, ReturnKeyLabel.DEFAULT);
	lenInput.text = "72";
	container.addChild(lenInput);
	
	warnMode = new ToggleSwitch();
	warnMode.onLabelProperties.text = "Warn";
	warnMode.offLabelProperties.text = "Ban";
	container.addChild( warnMode );

	errorDisplay = new RTLLabel("", 0xFF0000, "center", null, true, null, 0.8);
	container.addChild(errorDisplay);
	
	acceptButton.style = "danger";
	rejustLayoutByTransitionData();
}

protected override function acceptButton_triggeredHandler(event:Event):void
{
	var sfs:ISFSObject = new SFSObject();
	sfs.putInt("id", int(idInput.text));
	sfs.putInt("len", int(lenInput.text));
	sfs.putInt("mode", warnMode.isSelected ? 1 : 2);
	sfs.putUtfString("msg", messageInput.text);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseHander);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.BAN, sfs);
}

private function sfs_responseHander(e:SFSEvent):void 
{
	if( e.params.cmd != SFSCommands.BAN )
		return;
	errorDisplay.text = loc( "popup_ban_response_" + e.params.params.getInt("response"));
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseHander);
}
}
}