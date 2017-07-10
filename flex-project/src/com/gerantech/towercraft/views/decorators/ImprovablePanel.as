package com.gerantech.towercraft.views.decorators
{
	import com.gerantech.towercraft.models.Assets;
	
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalAlign;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Image;
	
	public class ImprovablePanel extends Image
	{
		private var _enabled:Boolean;
		public function ImprovablePanel()
		{
			super(Assets.getTexture("improvable"));
			alignPivot(HorizontalAlign.CENTER, VerticalAlign.BOTTOM);
			touchable = false;
			visible = false;
		}
		
		
		public function set enabled(value:Boolean):void
		{
			if( _enabled == value )
				return;
			parent.addChild(this);
			_enabled = value;
			if(_enabled)
				visible = true;
			Starling.juggler.tween(this, _enabled?0.3:0.1, {scale:_enabled?1:0.5, transition:_enabled?Transitions.EASE_OUT_BACK:Transitions.EASE_IN, onComplete:tweenCompleted});
			function tweenCompleted ():void
			{
				if(!_enabled)
					visible = false;
			}
		}
		
	}
}