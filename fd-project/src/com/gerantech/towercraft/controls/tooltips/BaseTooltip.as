package com.gerantech.towercraft.controls.tooltips
{
	import com.gerantech.towercraft.controls.CloasableObject;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.models.Assets;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Image;
	
	public class BaseTooltip extends CloasableObject
	{
		protected var labelDisplay:RTLLabel;
		protected var padding:int;

		private var message:String;
		private var position:Point;
		private var fontScale:Number;
		private var hSize:Number;

		public function BaseTooltip(message:String, position:Rectangle, fontScale:Number=0.8, hSize:Number=0.5)
		{
			super();
			visible = false;
			this.message = message;
			this.fontScale = fontScale;
			this.hSize = hSize;
			this.position = new Point(position.x + position.width * 0.5, position.y + position.height * 0.5);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			//touchable = false;
			width = maxWidth = stage.stageWidth * hSize;
			padding = 36 * appModel.scale;
			
			var halign:String = position.x < stage.stageWidth * 0.5 ? "left" : "right";
			var valign:String = position.y < stage.stageHeight * 0.5 ? "top" : "bot";
			var skin:Image = new Image(Assets.getTexture("tooltip-bg-"+valign+"-"+halign, "gui"));
			skin.scale9Grid = new Rectangle(halign=="left"?19:7, valign=="top"?18:7, 1, 1);
			backgroundSkin = skin;
			layout = new AnchorLayout();
			
			labelDisplay = new RTLLabel(message, 0, "justify", null, true, null, fontScale);
			labelDisplay.touchable = false;
			labelDisplay.pixelSnapping = false;
			labelDisplay.layoutData = new AnchorLayoutData(padding*(valign == "top"?1.6:0.6), padding, padding*(valign=="top"?1:2), padding);
			labelDisplay.validate();
			addChild(labelDisplay);
			
			x = position.x;
			y = position.y;
			pivotX = (halign=="left" ? 0 : maxWidth)
			pivotY = (valign=="top" ? 0 : (labelDisplay.height + padding * 6))

			Starling.juggler.tween(this, 0.2, {delay:0.1, scale:1, transition:Transitions.EASE_OUT_BACK, onStart:transitionInStarted, onComplete:transitionInCompleted});
		}
		
		override protected function transitionInStarted():void
		{
			scale = 0;
			visible = true;
			super.transitionInStarted();
		}
	}
}