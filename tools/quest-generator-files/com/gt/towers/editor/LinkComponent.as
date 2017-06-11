package com.gt.towers.editor
{
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class LinkComponent extends Sprite
	{
		public var places:Point;
		public function LinkComponent(source:int, destination:int)
		{
			super();
			places = new Point(source, destination);
		}
	}
}