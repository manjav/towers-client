package com.gerantech.towercraft.controls.buttons
{
	import com.gerantech.towercraft.controls.RTLLabel;
	import com.gerantech.towercraft.models.Assets;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.ButtonState;
	import feathers.controls.ImageLoader;
	import feathers.controls.ProgressBar;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.skins.ImageSkin;

	public class Indicator extends SimpleLayoutButton
	{
		private var direction:String;
		private var resourceType:int;
		private var hasProgressbar:Boolean;
		private var hasIncreaseButton:Boolean;

		private var progressbar:ProgressBar;
		private var progressLabel:RTLLabel;
		
		public function Indicator(direction:String = "ltr", resourceType:int = 0, hasProgressbar:Boolean = false, hasIncreaseButton:Boolean=true)
		{
			this.direction = direction;
			this.resourceType = resourceType;
			this.hasProgressbar = hasProgressbar;
			this.hasIncreaseButton = hasIncreaseButton;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			layout = new AnchorLayout();
			var skin:ImageSkin = new ImageSkin(Assets.getTexture("indicator-background", "skin"));
			skin.scale9Grid = new Rectangle(4, 6, 2, 2);
			backgroundSkin = skin;
			
			height = 74 * appModel.scale;
			width = 220 * appModel.scale;
			var padding:int = 12 * appModel.scale;
			
			if(hasProgressbar)
			{
				progressbar = new ProgressBar();
				progressbar.layoutData = new AnchorLayoutData(padding, padding, padding, padding);
				addChild(progressbar);
			}
			
			progressLabel = new RTLLabel("", 1, "cenetr", null, false, null, 0, null, "bold");
			progressLabel.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
			addChild(progressLabel);
			
			var iconDisplay:ImageLoader = new ImageLoader();
			iconDisplay.source = Assets.getTexture("res-"+resourceType, "gui");
			iconDisplay.width = iconDisplay.height = height + padding*2;
			iconDisplay.layoutData = new AnchorLayoutData(NaN, direction=="ltr"?NaN:-height/2, NaN, direction=="ltr"?-height/2:NaN, NaN, 0);
			addChild(iconDisplay);
			
			if(hasIncreaseButton)
			{
				var addDisplay:ImageLoader = new ImageLoader();
				addDisplay.source = Assets.getTexture("indicator-add", "skin");
				addDisplay.width = addDisplay.height = height + padding;
				addDisplay.layoutData = new AnchorLayoutData(NaN, direction=="ltr"?-height/2:NaN, NaN, direction=="ltr"?NaN:-height/2, NaN, 0);
				addChild(addDisplay);
			}
		}
		
		public function setData(minimum:Number, value:Number, maximum:Number):void
		{
			if(hasProgressbar)
			{
				progressbar.minimum = minimum;
				progressbar.maximum = maximum;
				progressbar.value = Math.max(minimum, Math.min( maximum, value ) );
			}
			
			progressLabel.text = value.toString();
		}
		
		override public function set currentState(value:String):void
		{
			if(hasIncreaseButton)
				scale = value == ButtonState.DOWN ? 0.9 : 1;
			super.currentState = value;
		}
		
		
		
	}
}