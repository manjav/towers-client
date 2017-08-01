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
	
	import feathers.controls.ImageLoader;
	
	import starling.events.Event;

	public class BugReportPopup extends ConfirmPopup
	{
		private var emailInput:CustomTextInput;
		private var descriptionInput:CustomTextInput;
		private var errorDisplay:RTLLabel;
		
		public function BugReportPopup()
		{
			super(loc("popup_bugreport_title"), loc("popup_send_label"), null);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			transitionIn.destinationBound = transitionIn.sourceBound = new Rectangle(stage.stageWidth*0.10, stage.stageHeight*0.2, stage.stageWidth*0.8, stage.stageHeight*0.6);
			transitionOut.destinationBound = transitionOut.sourceBound = new Rectangle(stage.stageWidth*0.10, stage.stageHeight*0.2, stage.stageWidth*0.8, stage.stageHeight*0.6);
			
			emailInput = new CustomTextInput(SoftKeyboardType.EMAIL, ReturnKeyLabel.DEFAULT);
			emailInput.prompt = loc( "popup_bugreport_email_prompt" );
			container.addChild(emailInput);
			
			descriptionInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.DEFAULT, 0xFFFFFF, true);
			descriptionInput.prompt = loc( "popup_bugreport_description_prompt" );
			descriptionInput.height = 420 * appModel.scale;
			container.addChild(descriptionInput);
			
			errorDisplay = new RTLLabel("", 0xFF0000, null, null, true, null, 0.8);
			container.addChild(errorDisplay);
			
			var iconDisplay:ImageLoader = new ImageLoader();
			iconDisplay.source = Assets.getTexture("bug-icon", "gui");
			iconDisplay.height = 72*appModel.scale;
			acceptButton.defaultIcon = iconDisplay;
			
			rejustLayoutByTransitionData();
		}
		
		protected override function acceptButton_triggeredHandler(event:Event):void
		{
			
			if ( emailInput.text.length == 0)
			{
				errorDisplay.text = loc( "popup_bugreport_email_prompt" );
				return;
			}
			var emailExpression:RegExp = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/i;
			if ( !emailExpression.test(emailInput.text) )
			{
				errorDisplay.text = loc( "popup_bugreport_email_invalid" );
				return;
			}
			
			if ( descriptionInput.text.length <= 10)
			{
				errorDisplay.text = loc( "popup_bugreport_size" );
				return;
			}
			
			var sfs:SFSObject = SFSObject.newInstance();
			sfs.putText( "email", emailInput.text );
			sfs.putText( "description", descriptionInput.text );
			SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsCOnnection_extensionResponseHandler);
			SFSConnection.instance.sendExtensionRequest(SFSCommands.BUG_REPORT, sfs );
		}
		
		protected function sfsCOnnection_extensionResponseHandler(event:SFSEvent):void
		{
			if( event.params.cmd != SFSCommands.BUG_REPORT )
				return;
			
			SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsCOnnection_extensionResponseHandler);
			var result:SFSObject = event.params.params as SFSObject;
			if( !result.getBool("succeed") )
			{
				var error:String = result.getText("errorCode");
				errorDisplay.text = error=="popup_select_name_size" ? loc("popup_select_name_size", [6, 12]) : error;
				return;
			}
			dispatchEventWith( Event.COMPLETE );
			close();
		}
	}
}