package com.gerantech.towercraft.controls.buttons
{
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.ButtonState;
	import feathers.controls.ImageLoader;
	import feathers.controls.ProgressBar;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.skins.ImageSkin;
	
	import starling.text.TextField;
	import starling.text.TextFormat;

	public class Indicator extends SimpleLayoutButton
	{
		private var direction:String;
		private var resourceType:int;
		private var hasProgressbar:Boolean;
		private var hasIncreaseButton:Boolean;

		private var progressbar:ProgressBar;
		private var progressLabel:TextField;
		
		public function Indicator(direction:String = "ltr", resourceType:int = 0, hasProgressbar:Boolean = false, hasIncreaseButton:Boolean=true)
		{
			this.direction = direction;
			this.resourceType = resourceType;
			this.hasProgressbar = hasProgressbar;
			this.hasIncreaseButton = hasIncreaseButton;
			height = 64 * appModel.scale;
			width = 200 * appModel.scale;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			layout = new AnchorLayout();
			var skin:ImageSkin = new ImageSkin(Assets.getTexture("indicator-background", "skin"));
			skin.scale9Grid = new Rectangle(4, 6, 2, 2);
			backgroundSkin = skin;
			

			var padding:int = 12 * appModel.scale;
			
			if(hasProgressbar)
			{
				progressbar = new ProgressBar();
				progressbar.layoutData = new AnchorLayoutData(padding, padding, padding, padding);
				addChild(progressbar);
			}
			
			progressLabel = new TextField(width-padding*(hasIncreaseButton?8:4), height, "", new TextFormat("SourceSans", appModel.theme.gameFontSize*appModel.scale*0.94, BaseMetalWorksMobileTheme.PRIMARY_TEXT_COLOR));
			progressLabel.x = padding*4;
			progressLabel.autoScale = true;
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
			if( value == super.currentState )
				return;
			if( hasIncreaseButton )
				scale = value == ButtonState.DOWN ? 0.9 : 1;
			super.currentState = value;
		}
		
		
		
	}
}