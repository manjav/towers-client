package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.controls.texts.CustomTextInput;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	
	import flash.geom.Rectangle;
	import flash.text.ReturnKeyLabel;
	import flash.text.SoftKeyboardType;
	
	import mx.resources.ResourceManager;
	
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayoutData;
	
	import starling.core.Starling;
	import starling.events.Event;

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
			textInput.prompt = ResourceManager.getInstance().getString("loc", "selec_name");
			textInput.layoutData = new AnchorLayoutData(padding + messageDisplay.height, padding, NaN, padding);
			//textInput.addEventListener(Event.CHANGE, textInput_changeHandler);
			textInput.addEventListener(FeathersEventType.ENTER, textInput_enterHandler);
			container.addChild(textInput);
			
			errorDisplay = new RTLLabel(message, 0xFF0000, "justify");
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
		}
	}
}