package com.gerantech.towercraft.controls.buttons
{
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.constants.ResourceType;

	public class ExchangeButton extends CustomButton
	{
		public var currency:String = "";		
		private var _type:int;
		private var _count:int;

		public function ExchangeButton()
		{
			super();
		}
	
		public function set count(value:int):void
		{
			if(_count == value)
				return;
			_count = value;
			
			if(_count == -1)
				label = loc("open_label");
			else if(_count == 0)
				label = loc("free_label");
			else
				label = _count.toString() + " " + currency;
		}
		
		public function set type(value:int):void
		{
			if(_type == value)
				return;
			_type = value;
			
			var hasIcon:Boolean = _type > 0 && _type!= ResourceType.CURRENCY_REAL;
			if( hasIcon )
				icon = Assets.getTexture("res-"+_type, "gui");
		}
	}
}