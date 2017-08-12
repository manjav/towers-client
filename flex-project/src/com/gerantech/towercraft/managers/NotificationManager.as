package com.gerantech.towercraft.managers
{
	import com.gerantech.extensions.NativeAbilities;
	import com.gerantech.towercraft.managers.net.LoadingManager;
	import com.gerantech.towercraft.models.AppModel;
	import com.gt.towers.constants.ExchangeType;
	import com.gt.towers.exchanges.Exchanger;
	
	import mx.resources.ResourceManager;

	public class NotificationManager
	{
		public function NotificationManager(){}
		
		public function reset():void
		{
			if(AppModel.instance.loadingManager.state < LoadingManager.STATE_LOADED )
				return;
			
			clear();
			// notify exchanger items ...
			var date:Date = new Date();
			var secondsInDay:int = 24 * 3600000;
			var time:int = date.time/1000;
			var exchanger:Exchanger = AppModel.instance.game.exchanger;
			var numForgots:int = 0;
			var itemsKey:Vector.<int> = exchanger.items.keys();
			var i:int=0;
			while( i < itemsKey.length )
			{
				if( ExchangeType.getCategory(itemsKey[i]) == ExchangeType.S_30_CHEST )
				{
					if( exchanger.items.get(itemsKey[i]).expiredAt > time )
						notify("notify_chest_ready_"+itemsKey[i], (exchanger.items.get(itemsKey[i]).expiredAt+10)*1000);
					else 
						numForgots ++;
				}
				i++;
			}
			
			if( numForgots == 1 )
				notify("notify_chest_forgot_a_chest", date.time+5000);
			else if( numForgots > 1 )
				notify("notify_chest_forgot_chests", date.time+5000);
			
			// remember after a day, 3 days and a week ...
			notify("notify_remember_day", date.time+secondsInDay);
			notify("notify_remember_3days", date.time+secondsInDay*3);
			notify("notify_remember_week", date.time+secondsInDay*7);
		}
		
		private function notify(message:String, time:Number):void
		{
			var title:String = AppModel.instance.descriptor.name;
			NativeAbilities.instance.scheduleLocalNotification(title, title, loc(message), time);
		//	trace(title, message, time)
		}
		
		public function clear():void
		{
			NativeAbilities.instance.cancelLocalNotifications();
		}

		
		protected function loc(resourceName:String, parameters:Array=null, locale:String=null):String
		{
			return ResourceManager.getInstance().getString("loc", resourceName, parameters, locale);
		}	
	}
}