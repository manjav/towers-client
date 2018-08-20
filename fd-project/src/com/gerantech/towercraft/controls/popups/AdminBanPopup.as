package com.gerantech.towercraft.controls.popups 
{
import com.gerantech.towercraft.controls.switchers.Switcher;
import com.gerantech.towercraft.controls.texts.CustomTextInput;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.controls.LayoutGroup;
import feathers.controls.ToggleSwitch;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
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
private var banModeSwtcher:Switcher;
private var lenInput:com.gerantech.towercraft.controls.texts.CustomTextInput;

public function AdminBanPopup(userId:int)
{
	super(loc("popup_ban_button"), loc("popup_ban_button"), null);
	this.userId = userId;
}

override protected function initialize():void
{
	super.initialize();
	transitionIn.destinationBound = transitionIn.sourceBound = new Rectangle(80, 520, stage.stageWidth - 160, stage.stageHeight - 960);
	transitionOut.destinationBound = transitionOut.sourceBound = new Rectangle(80, 500, stage.stageWidth - 160, stage.stageHeight -  1000);
	
	idInput = new CustomTextInput(SoftKeyboardType.NUMBER, ReturnKeyLabel.DEFAULT);
	idInput.height = padding * 3;
	idInput.text = userId.toString();
	container.addChild(idInput);
	
	var c:LayoutGroup = new LayoutGroup();
	c.layout = new HorizontalLayout();
	HorizontalLayout(c.layout).gap = padding;
	container.addChild(c);

	lenInput = new CustomTextInput(SoftKeyboardType.NUMBER, ReturnKeyLabel.DEFAULT);
	lenInput.width = padding * 5;
	lenInput.text = "72";
	c.addChild(lenInput);
	
	banModeSwtcher = new Switcher(1, 2, 3, 1);
	banModeSwtcher.labelStringFactory = function (value:int):String { return loc("popup_ban_mode_" + value); }
	banModeSwtcher.layoutData = new HorizontalLayoutData(100);
	c.addChild( banModeSwtcher );
	
	messageInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.DEFAULT);
	messageInput.height = padding * 6;
	messageInput.text = "تعلیق به علت تخطی از قوانین بازی";
	container.addChild(messageInput);

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
	sfs.putInt("mode", banModeSwtcher.value);
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