package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.controls.RTLLabel;
	import com.gerantech.towercraft.controls.overlays.TransitionData;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.Button;
	import feathers.controls.LayoutGroup;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalAlign;
	import feathers.skins.ImageSkin;
	
	import starling.animation.Transitions;
	import starling.events.Event;

	public class ConfirmPopup extends BasePopup
	{
		protected var message:String;
		protected var acceptLabel:String;
		protected var declineLabel:String;
		protected var messageDisplay:RTLLabel;
		protected var declineButton:Button;
		protected var acceptButton:Button;
		
		public function ConfirmPopup(message:String, acceptLabel:String=null, declineLabel:String=null)
		{
			super();
			this.message = message;
			this.acceptLabel = acceptLabel==null ? loc("popup_accept_label") : acceptLabel;
			this.declineLabel = declineLabel==null ? loc("popup_decline_label") : declineLabel;
		}
		
		override protected function initialize():void
		{
			closable = false;

			transitionIn = new TransitionData();
			transitionIn.sourceAlpha = 0;
			transitionIn.destinationBound = transitionIn.sourceBound = new Rectangle(stage.stageWidth*0.15, stage.stageHeight*0.375, stage.stageWidth*0.7, stage.stageHeight*0.25);
			
			transitionOut = new TransitionData();
			transitionOut.destinationAlpha = 0;
			transitionOut.transition = Transitions.EASE_IN;
			transitionOut.destinationBound = transitionOut.sourceBound = new Rectangle(stage.stageWidth*0.15, stage.stageHeight*0.375, stage.stageWidth*0.7, stage.stageHeight*0.25);

			super.initialize();
			
			//overlay.alpha = 0.8;
			layout = new AnchorLayout();
			
			var skin:ImageSkin = new ImageSkin(appModel.theme.itemRendererUpSkinTexture);
			skin.scale9Grid = BaseMetalWorksMobileTheme.ITEM_RENDERER_SCALE9_GRID;
			backgroundSkin = skin;
			
			var padding:int = 36 * appModel.scale;
			layout = new AnchorLayout();
			
			messageDisplay = new RTLLabel(message, 1, "center", null, true, "center", 45*appModel.scale);
			messageDisplay.layoutData = new AnchorLayoutData (NaN, padding, NaN, padding, NaN, -appModel.theme.controlSize);
			addChild(messageDisplay);
			
			var buttonLayout:HorizontalLayout = new HorizontalLayout();
			buttonLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
			buttonLayout.verticalAlign = VerticalAlign.JUSTIFY;
			buttonLayout.gap = padding;
			var buttonContainer:LayoutGroup = new LayoutGroup();
			buttonContainer.layoutData = new AnchorLayoutData (NaN, NaN, padding, NaN, 0);
			buttonContainer.layout = buttonLayout;
			addChild(buttonContainer);
			
			declineButton = new Button();
			declineButton.label = declineLabel;
			declineButton.addEventListener(Event.TRIGGERED, decline_triggeredHandler);
			buttonContainer.addChild(declineButton);
			
			acceptButton = new Button();
			acceptButton.label = acceptLabel;
			acceptButton.addEventListener(Event.TRIGGERED, acceptButton_triggeredHandler);
			buttonContainer.addChild(acceptButton);
		}
		
		protected function decline_triggeredHandler():void
		{
			dispatchEventWith(Event.CANCEL);
			close();
		}
		
		protected function acceptButton_triggeredHandler():void
		{
			dispatchEventWith(Event.SELECT);
			close();
		}
		
	}
}