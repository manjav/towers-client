package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.controls.texts.CustomTextInput;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.geom.Rectangle;
	import flash.text.ReturnKeyLabel;
	import flash.text.SoftKeyboardType;
	
	import feathers.events.FeathersEventType;
	
	import starling.events.Event;

	public class SelectNamePopup extends ConfirmPopup
	{
		private var errorDisplay:RTLLabel;

		private var textInput:CustomTextInput;
		public function SelectNamePopup()
		{
			super(loc("popup_select_name_title"), loc("popup_register_label"), null);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			closeOnOverlay = false;
			transitionOut.destinationBound = transitionIn.sourceBound = new Rectangle(stage.stageWidth*0.10, stage.stageHeight*0.35, stage.stageWidth*0.8, stage.stageHeight*0.25);
			transitionIn.destinationBound = transitionOut.sourceBound = new Rectangle(stage.stageWidth*0.10, stage.stageHeight*0.30, stage.stageWidth*0.8, stage.stageHeight*0.3);

			textInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.GO);
			textInput.maxChars = game.loginData.nameMaxLen ;
			textInput.prompt = loc( "popup_select_name_prompt" );
			textInput.addEventListener(Event.CHANGE, textInput_changeHandler);
			textInput.addEventListener(FeathersEventType.ENTER, acceptButton_triggeredHandler);
			container.addChild(textInput);
			
			errorDisplay = new RTLLabel("", 0xFF0000);
			container.addChild(errorDisplay);
			
			acceptButton.visible = false;
			declineButton.removeFromParent();
			rejustLayoutByTransitionData();
		}
		
		protected function textInput_changeHandler(event:Event):void
		{
			acceptButton.visible = textInput.text.length >= game.loginData.nameMinLen
		}
		
		protected override function acceptButton_triggeredHandler(event:Event):void
		{
			var selectedName:String = textInput.text;
			var nameLen:int = selectedName.length;
			if ( nameLen < game.loginData.nameMinLen || nameLen > game.loginData.nameMaxLen )
			{
				errorDisplay.text = loc( "text_size_warn", [loc("popup_select_name_prompt"), game.loginData.nameMinLen, game.loginData.nameMaxLen] );
				return;
			}
			
			if ( selectedName.substr(nameLen-2) == " " || selectedName.substr(0,1) == " " || selectedName.indexOf("  ") > -1 || selectedName=="root" || selectedName=="super-user" )
			{
				errorDisplay.text = loc("popup_select_name_invalid");
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
			var result:SFSObject = event.params.params as SFSObject;
			if( !result.getBool("succeed") )
			{
				var error:String = result.getText("errorCode");
				errorDisplay.text = error=="popup_select_name_size" ? loc("text_size_warn", [loc("popup_select_name_prompt"), 6, 12]) : error;
				return;
			}
			player.nickName = textInput.text;
			dispatchEventWith( Event.COMPLETE );
			close();
		}
	}
}