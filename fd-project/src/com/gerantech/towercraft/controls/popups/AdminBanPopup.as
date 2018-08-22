package com.gerantech.towercraft.controls.popups 
{
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.switchers.Switcher;
import com.gerantech.towercraft.controls.texts.CustomTextInput;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gt.towers.constants.MessageTypes;
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
private var lenInput:CustomTextInput;
private var messageInput:CustomTextInput;
private var errorDisplay:RTLLabel;
private var banModeSwitcher:Switcher;
private var bannedsData:ISFSObject;
private var numBannedLabel:RTLLabel;

public function AdminBanPopup(userId:int)
{
	super(loc("popup_ban_button"), loc("popup_ban_button"), null);
	this.userId = userId;

	if( appModel.loadingManager.serverData.getInt("noticeVersion") >= 3500 )
	{
		var sfs:ISFSObject = new SFSObject();
		sfs.putInt("id", userId);
		SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_getBannedHander);
		SFSConnection.instance.sendExtensionRequest(SFSCommands.BAN_GET, sfs);
		return;
	}
	bannedsData = new SFSObject();
	bannedsData.putInt("time", 0);
}

protected function sfs_getBannedHander(e:SFSEvent):void 
{
	if( e.params.cmd != SFSCommands.BAN_GET )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_getBannedHander);
	bannedsData = e.params.params;
	if( transitionState >= TransitionData.STATE_IN_COMPLETED )
		insertData();
}

override protected function initialize():void
{
	super.initialize();
	transitionIn.destinationBound = transitionIn.sourceBound = new Rectangle(80, 520, stageWidth - 160, stageHeight - 960);
	transitionOut.destinationBound = transitionOut.sourceBound = new Rectangle(80, 500, stageWidth - 160, stageHeight -  1000);
	rejustLayoutByTransitionData();	
}

protected override function transitionInCompleted():void
{
	super.transitionInCompleted();
	if( bannedsData != null )
		insertData();
}

private function insertData():void 
{
	// line 1
	var l1:LayoutGroup = new LayoutGroup();
	l1.layout = new HorizontalLayout();
	l1.height = padding * 3;
	HorizontalLayout(l1.layout).gap = padding;
	container.addChild(l1);
	
	numBannedLabel = new RTLLabel("سوابق: " + bannedsData.getInt("time"));
	numBannedLabel.width = padding * 8;
	l1.addChild(numBannedLabel);
	
	idInput = new CustomTextInput(SoftKeyboardType.NUMBER, ReturnKeyLabel.DEFAULT);
	idInput.layoutData = new HorizontalLayoutData(100);
	idInput.text = userId.toString();
	l1.addChild(idInput);
	
	// line 2
	var l2:LayoutGroup = new LayoutGroup();
	l2.layout = new HorizontalLayout();
	HorizontalLayout(l2.layout).gap = padding;
	container.addChild(l2);

	lenInput = new CustomTextInput(SoftKeyboardType.NUMBER, ReturnKeyLabel.DEFAULT);
	lenInput.width = padding * 5;
	lenInput.text = "72";
	l2.addChild(lenInput);
	
	banModeSwitcher = new Switcher(1, 2, 3, 1);
	banModeSwitcher.labelStringFactory = function (value:int):String { return loc("popup_ban_mode_" + value); }
	banModeSwitcher.layoutData = new HorizontalLayoutData(100);
	l2.addChild( banModeSwitcher );

	
	messageInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.DEFAULT);
	messageInput.height = padding * 6;
	messageInput.text = "تعلیق به علت عدم رعایت قوانین بازی";
	container.addChild(messageInput);

	errorDisplay = new RTLLabel("", 0xFF0000, "center", null, true, null, 0.8);
	container.addChild(errorDisplay);
	
	acceptButton.style = "danger";
}

protected override function acceptButton_triggeredHandler(event:Event):void
{
	var sfs:ISFSObject = new SFSObject();
	sfs.putInt("id", int(idInput.text));
	sfs.putInt("len", int(lenInput.text));
	sfs.putInt("mode", banModeSwitcher.value);
	sfs.putUtfString("msg", messageInput.text);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_banResponseHander);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.BAN, sfs);
}

protected function sfs_banResponseHander(e:SFSEvent):void 
{
	if( e.params.cmd != SFSCommands.BAN )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_banResponseHander);
	errorDisplay.text = loc( "popup_ban_response_" + e.params.params.getInt("response"));
	if( e.params.params.getInt("response") == MessageTypes.RESPONSE_SUCCEED )
	{
		bannedsData.putInt("time", bannedsData.getInt("time") + 1 );
		numBannedLabel.text = "سوابق: " + bannedsData.getInt("time");
		dispatchEventWith(Event.UPDATE, false, bannedsData);
	}
}
}
}