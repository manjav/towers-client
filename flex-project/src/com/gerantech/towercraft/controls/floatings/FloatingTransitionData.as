package com.gerantech.towercraft.controls.floatings
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	

	public class FloatingTransitionData
	{
		public var time:Number;
		public var delay:Number;
		public var sourceAlpha:Number = 0;
		public var destinationAlpha:Number = 1;
		public var transition:String = "easeOut";
		public var sourcePosition:Point;
		public var destinationPosition:Point;

		private var _sourceBound:Rectangle;
		private var _destinationBound:Rectangle;
		
		public function FloatingTransitionData(time:Number = 0.2, delay:Number = 0)
		{
			this.time = time;
			this.delay = delay;
		}

		/**
		 * Source boundary
		 
		public function get sourceBound():Rectangle
		{
			return _sourceBound;
		}
		public function set sourceBound(value:Rectangle):void
		{
			_sourceBound = value;
			
			if(sourceConstrain == null || _sourceBound == null)
				return;
			if(!sourceConstrain.containsRect(_sourceBound) && sourceConstrain.width >= _sourceBound.width && sourceConstrain.height >= _sourceBound.height)
			{
				if(_sourceBound.x < sourceConstrain.x)
					_sourceBound.x = sourceConstrain.x;
				if(_sourceBound.y < sourceConstrain.y)
					_sourceBound.y = sourceConstrain.y;
				if(_sourceBound.right > sourceConstrain.right)
					_sourceBound.x = sourceConstrain.right - _sourceBound.width;
				if(_sourceBound.bottom > sourceConstrain.bottom)
					_sourceBound.y = sourceConstrain.bottom - _sourceBound.height;
			}
		}*/

		/**
		 * Destination boundary
		 
		public function get destinationBound():Rectangle
		{
			return _destinationBound;
		}
		public function set destinationBound(value:Rectangle):void
		{
			_destinationBound = value;
			
			if(destinationConstrain == null || _destinationBound == null)
				return;
			if(!destinationConstrain.containsRect(_destinationBound) && destinationConstrain.width >= _destinationBound.width && destinationConstrain.height >= _destinationBound.height)
			{
				if(_destinationBound.x < destinationConstrain.x)
					_destinationBound.x = destinationConstrain.x;
				if(_destinationBound.y < destinationConstrain.y)
					_destinationBound.y = destinationConstrain.y;
				if(_destinationBound.right > destinationConstrain.right)
					_destinationBound.x = destinationConstrain.right -_destinationBound.width;
				if(_destinationBound.bottom > destinationConstrain.bottom)
					_destinationBound.y = destinationConstrain.bottom - _destinationBound.height;
			}
		}*/

	}
}