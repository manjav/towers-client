package com.gerantech.towercraft.views.decorators
{
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalAlign;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Image;
	
	public class ImprovablePanel extends Image
	{
		private var _enabled:Boolean = true;
		private var initialScale:Number = 0;
		public function ImprovablePanel()
		{
			super(Assets.getTexture("improvable"));
			alignPivot(HorizontalAlign.CENTER, VerticalAlign.BOTTOM);
			touchable = false;
		}
		
		public function set enabled(value:Boolean):void
		{
			if( _enabled == value )
				return;
			
			if( initialScale == 0 )
				initialScale = scale;
			
			_enabled = value;
			
			if(_enabled)
				visible = true;
			Starling.juggler.tween(this, _enabled?0.3:0.1, {scale:(_enabled?1:0.5)*initialScale, transition:_enabled?Transitions.EASE_OUT_BACK:Transitions.EASE_IN, onComplete:tweenCompleted});
			function tweenCompleted ():void
			{
				if(!_enabled)
					visible = false;
			}
		}
	}
}