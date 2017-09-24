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
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFormat;

	public class Indicator extends SimpleLayoutButton
	{
		public var direction:String;
		public var resourceType:int;
		public var hasProgressbar:Boolean;
		public var hasIncreaseButton:Boolean;

		private var progressbar:ProgressBar;
		private var progressLabel:TextField;

		public var iconDisplay:ImageLoader;
		private var _value:Number = -0.1;
		
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
			this.isQuickHitAreaEnabled = false;
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
			
			progressLabel = new TextField(width-padding*(hasIncreaseButton?8:5), height, "", new TextFormat("SourceSans", appModel.theme.gameFontSize*appModel.scale*0.94, BaseMetalWorksMobileTheme.PRIMARY_TEXT_COLOR));
			progressLabel.x = padding*4;
			progressLabel.pixelSnapping = false;
			progressLabel.autoScale = true;
			addChild(progressLabel);
			
			iconDisplay = new ImageLoader();
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

			this.value = value;
		}
		
		override public function set currentState(value:String):void
		{
			if( value == super.currentState )
				return;
			if( hasEventListener(Event.TRIGGERED) )
			{
				scale = value == ButtonState.DOWN ? 1.1 : 1;
				if( value == ButtonState.DOWN && parent != null )
					parent.addChild(this);
			}
			super.currentState = value;
		}
		
		public function get value():Number
		{
			return _value;
		}
		
		public function set value(val:Number):void
		{
			if( _value == val )
				return;
			_value = val;
			if(progressLabel)
				progressLabel.text = _value.toString();
		}

		
		public function punch():void
		{
			value = player.resources.get(resourceType);
			var diff:int = 48 * appModel.scale;
			//iconDisplay.scale = 1.5;
			y -= diff;
			Starling.juggler.tween(this, 0.4, {y:y+diff, transition:Transitions.EASE_OUT_ELASTIC});
			//Starling.juggler.tween(iconDisplay, 0.2, {scale:1, transition:Transitions.EASE_OUT_BACK});

		}
	}
}