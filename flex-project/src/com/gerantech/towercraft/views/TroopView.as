package com.gerantech.towercraft.views
{
	import starling.display.Image;
	
	public class TroopView extends Image
	{
		public static const TYPE_GREY:uint = 0xe2e2e2;
		public static const TYPE_BLUE:uint = 0x0000FF;
		public static const TYPE_RED:uint = 0xFF0000;
	
		public function TroopView()//troop:Troop
		{
			super(null);
			
			/*var txt:String = "troop";
			if(type == TYPE_BLUE)
				txt += "-b";
			else if(type == TroopView.TYPE_RED)
				txt += "-r";
			
			super(Assets.getTexture(txt));
			alignPivot();
			
			this.type = type;
			touchable = false;
			this.path = new Vector.<PlaceDecorator>();
			for (var p:uint=0; p<path.length; p++)
				this.path.push(path[p]);
*/
		}
		
		/*public function rush():Boolean
		{
			var destination:PlaceDecorator = path.shift();
			if(destination == null)
			{
				removeFromParent(true);
				//trace("fine", type);
				return false;
			}
			
			setTimeout(onTroopArrived, RUSH_TIME, destination);
			Starling.juggler.tween(this, RUSH_TIME/1000, {x:destination.x, y:destination.y});//, onComplete:onTroopArrived, onCompleteArgs:[destination]});
			return true;
		}
		private function onTroopArrived(destination:PlaceDecorator):void
		{
			destination.tower.pushTroops(1, type);
			setTimeout(destination.rush, RUSH_GAP, this, 0);
		}*/
	}
}