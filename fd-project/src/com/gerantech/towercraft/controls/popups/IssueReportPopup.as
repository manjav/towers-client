package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.texts.CustomTextInput;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSObject;
import flash.geom.Rectangle;
import flash.text.ReturnKeyLabel;
import flash.text.SoftKeyboardType;
import mx.resources.ResourceManager;
import starling.events.Event;

public class IssueReportPopup extends ConfirmPopup
{
private var emailInput:CustomTextInput;
private var descriptionInput:CustomTextInput;
private var errorDisplay:RTLLabel;

public function IssueReportPopup()
{
	super(loc("popup_bugreport_title"), loc("popup_send_label"), null);
}

override protected function initialize():void
{
	super.initialize();
	transitionOut.destinationBound = transitionIn.sourceBound = new Rectangle(stage.stageWidth*0.10, stage.stageHeight*0.30, stage.stageWidth*0.8, stage.stageHeight*0.4);
	transitionIn.destinationBound = transitionOut.sourceBound = new Rectangle(stage.stageWidth*0.10, stage.stageHeight*0.25, stage.stageWidth*0.8, stage.stageHeight*0.5);
	
	/*emailInput = new CustomTextInput(SoftKeyboardType.EMAIL, ReturnKeyLabel.DEFAULT);
	emailInput.prompt = loc( "popup_bugreport_email_prompt" );
	container.addChild(emailInput);*/
	
	descriptionInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.DEFAULT, 0, true);
	descriptionInput.prompt = loc( "popup_bugreport_description_prompt" );
	descriptionInput.height = 420;
	container.addChild(descriptionInput);
	
	errorDisplay = new RTLLabel("", 0xFF0000, null, null, true, null, 0.8);
	container.addChild(errorDisplay);
	
	acceptButton.icon = Assets.getTexture("settings-"+21, "gui");;
	
	rejustLayoutByTransitionData();
}

protected override function acceptButton_triggeredHandler(event:Event):void
{
	if( descriptionInput.text.length <= 10 )
	{
		errorDisplay.text = loc( "popup_bugreport_size" );
		return;
	}
	acceptButton.isEnabled = false;
	var sfs:SFSObject = SFSObject.newInstance();
	sfs.putText( "email", "");//emailInput.text );
	sfs.putUtfString("description", descriptionInput.text );
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsCOnnection_extensionResponseHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.ISSUE_REPORT, sfs );
}

protected function sfsCOnnection_extensionResponseHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.ISSUE_REPORT )
		return;
	
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsCOnnection_extensionResponseHandler);
	var result:SFSObject = event.params.params as SFSObject;
	if( !result.getBool("succeed") )
	{
		var error:String = result.getText("errorCode");
		errorDisplay.text = error=="popup_select_name_size" ? loc("text_size_warn", [loc( "popup_bugreport_description_prompt" ), 6, 12]) : error;
		return;
	}
	dispatchEventWith( Event.COMPLETE );
	appModel.navigator.addLog(ResourceManager.getInstance().getString("loc", "popup_bugreport_fine"));
	close();
}
}
}