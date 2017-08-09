package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.controls.buttons.CustomButton;
	import com.gerantech.towercraft.controls.overlays.TransitionData;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.LayoutGroup;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalAlign;
	import feathers.layout.VerticalLayout;
	import feathers.skins.ImageSkin;
	
	import starling.animation.Transitions;
	import starling.events.Event;

	public class ConfirmPopup extends BasePopup
	{
		public var message:String;
		public var acceptStyle:String = "normal";
		public var declineStyle:String = "normal";
		public var acceptLabel:String;
		public var declineLabel:String;
		public var messageDisplay:RTLLabel;
		
		protected var declineButton:CustomButton;
		protected var acceptButton:CustomButton;

		protected var padding:int;
		protected var container:LayoutGroup;
		
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
			
			padding = 36 * appModel.scale;
			layout = new AnchorLayout();
			
			var containerLayout:VerticalLayout = new VerticalLayout();
			containerLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
			containerLayout.gap = padding;
			
			container = new LayoutGroup();
			container.layoutData = new AnchorLayoutData (padding, padding, NaN, padding);
			container.layout = containerLayout;
			addChild(container);
			
			messageDisplay = new RTLLabel(message, 1, "center", null, true, "center", 45*appModel.scale);
			//messageDisplay.layoutData = new AnchorLayoutData (NaN, padding, NaN, padding, NaN, -appModel.theme.controlSize);
			container.addChild(messageDisplay);
			
			var buttonLayout:HorizontalLayout = new HorizontalLayout();
			buttonLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
			buttonLayout.verticalAlign = VerticalAlign.JUSTIFY;
			buttonLayout.gap = padding;
			var buttonContainer:LayoutGroup = new LayoutGroup();
			buttonContainer.layoutData = new AnchorLayoutData (NaN, NaN, padding, NaN, 0);
			buttonContainer.height = 120 * appModel.scale;
			buttonContainer.layout = buttonLayout;
			addChild(buttonContainer);
			
			declineButton = new CustomButton();
			declineButton.style = declineStyle;
			declineButton.label = declineLabel;
			declineButton.addEventListener(Event.TRIGGERED, decline_triggeredHandler);
			buttonContainer.addChild(declineButton);
			
			acceptButton = new CustomButton();
			acceptButton.style = acceptStyle;
			acceptButton.label = acceptLabel;
			acceptButton.addEventListener(Event.TRIGGERED, acceptButton_triggeredHandler);
			buttonContainer.addChild(acceptButton);
		}
		
		protected function decline_triggeredHandler(event:Event):void
		{
			dispatchEventWith(Event.CANCEL);
			close();
		}
		
		protected function acceptButton_triggeredHandler(event:Event):void
		{
			dispatchEventWith(Event.SELECT);
			close();
		}
		
	}
}