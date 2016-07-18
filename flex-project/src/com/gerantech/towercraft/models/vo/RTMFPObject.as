package com.gerantech.towercraft.models.vo
{
	public class RTMFPObject
	{
		public var from:uint;
		public var to:uint;
		
		public function RTMFPObject(from:uint, to:uint)
		{
			update(from, to);
		}
		
		public function update(from:uint, to:uint):void
		{
			this.from = from;
			this.to = to;
		}
		
		public function toString():Object
		{
			// TODO Auto Generated method stub
			return "from : " + from + " ,  to " + to;
		}
	}
}