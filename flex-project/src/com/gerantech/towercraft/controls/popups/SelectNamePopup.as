package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.controls.texts.CustomTextInput;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.smartfoxserver.v2.SmartFox;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.geom.Rectangle;
	import flash.text.ReturnKeyLabel;
	import flash.text.SoftKeyboardType;
	
	import mx.resources.ResourceManager;
	
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayoutData;
	
	import starling.core.Starling;
	import starling.events.Event;
	import starling.events.EventDispatcher;

	public class SelectNamePopup extends ConfirmPopup
	{
		private var errorDisplay:RTLLabel;
		public function SelectNamePopup(message:String, acceptLabel:String=null, declineLabel:String=null)
		{
			super(message, acceptLabel, declineLabel);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			transitionIn.destinationBound = transitionIn.sourceBound = new Rectangle(stage.stageWidth*0.10, stage.stageHeight*0.35, stage.stageWidth*0.8, stage.stageHeight*0.3);
			transitionOut.destinationBound = transitionOut.sourceBound = new Rectangle(stage.stageWidth*0.10, stage.stageHeight*0.35, stage.stageWidth*0.8, stage.stageHeight*0.3);

			var textInput:CustomTextInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.GO);
			textInput.prompt = loc( "popup_select_name_prompt" );
			textInput.layoutData = new AnchorLayoutData(padding + messageDisplay.height, padding, NaN, padding);
			//textInput.addEventListener(Event.CHANGE, textInput_changeHandler);
			textInput.addEventListener(FeathersEventType.ENTER, textInput_enterHandler);
			container.addChild(textInput);
			
			errorDisplay = new RTLLabel("", 0xFF0000);
			//messageDisplay.layoutData = new AnchorLayoutData (NaN, padding, NaN, padding, NaN, -appModel.theme.controlSize);
			container.addChild(errorDisplay);
			
			
			declineButton.removeFromParent();
			rejustLayoutByTransitionData();
		}
		
		protected function textInput_enterHandler(event:Event):void
		{
			//Starling.current.nativeStage.focus = null;
		}
		
		protected override function acceptButton_triggeredHandler(event:Event):void
		{
			var textInput:CustomTextInput = event.currentTarget as CustomTextInput;
			var selectedName:String = textInput.text;
			if ( selectedName.length < game.loginData.nameMinLen || selectedName.length > game.loginData.nameMaxLen )
			{
				errorDisplay.text = loc( "popup_select_name_size", [game.loginData.nameMinLen, game.loginData.nameMaxLen] );
				return;
			}
			
			var sfs:SFSObject = SFSObject.newInstance();
			sfs.putText( "name", selectedName );
			SFSConnection.instance.sendExtensionRequest(SFSCommands.SELECT_NAME, sfs );
			SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsCOnnection_extensionResponseHandler);
		}
		
		protected function sfsCOnnection_extensionResponseHandler(event:SFSEvent):void
		{
			if( event.params.command != SFSCommands.SELECT_NAME )
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
		}
	}
}