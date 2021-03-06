package com.gerantech.towercraft.managers
{
import com.gerantech.extensions.NativeAbilities;
import com.gerantech.towercraft.managers.net.LoadingManager;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.utils.LoadAndSaver;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.exchanges.ExchangeItem;
import com.gt.towers.exchanges.Exchanger;

import flash.events.Event;
import flash.filesystem.File;

import mx.resources.ResourceManager;

public class NotificationManager
{
private var iconFile:File;
private var soundFile:File;

public function init():void
{
	soundFile = File.applicationStorageDirectory.resolvePath("sounds/chest-open.mp3");
	var soundLoader:LoadAndSaver = new LoadAndSaver(soundFile.nativePath, File.applicationDirectory.resolvePath("assets/sounds/chest-open.mp3").url);
	soundLoader.addEventListener(Event.COMPLETE, sound_completeHandler);
	function sound_completeHandler(event:Event):void
	{
		soundLoader.removeEventListener(Event.COMPLETE, sound_completeHandler);
		soundLoader.closeLoader(false);
	}

	iconFile = File.applicationStorageDirectory.resolvePath("images/icon/ic_notifications.png");
	var iconLoader:LoadAndSaver = new LoadAndSaver(iconFile.nativePath, File.applicationDirectory.resolvePath("assets/images/icon/ic_notifications.png").url);
	iconLoader.addEventListener(Event.COMPLETE, icon_completeHandler);
	function icon_completeHandler(event:Event):void
	{
		iconLoader.removeEventListener(Event.COMPLETE, icon_completeHandler);
		iconLoader.closeLoader(false);
	}
}

public function reset():void
{
	if( AppModel.instance.loadingManager.state < LoadingManager.STATE_LOADED )
		return;

	clear();
	if( !AppModel.instance.game.player.prefs.getAsBool(PrefsTypes.SETTINGS_3_NOTIFICATION) )
		return;
	var date:Date = new Date();
	var secondsInDay:int = 24 * 3600000;
	
	// remember after a day, 3 days and a week ...
	notify("notify_remember_day",	date.time+secondsInDay * 1);
	notify("notify_remember_3days", date.time+secondsInDay * 3);
	notify("notify_remember_week",	date.time+secondsInDay * 7);

	
	if( Math.random() > 0.4 )
		return;

	// notify exchanger items ...

	var time:int = date.time / 1000;
	var exchanger:Exchanger = AppModel.instance.game.exchanger;
	var numForgots:int = 0;
	var itemsKey:Vector.<int> = exchanger.items.keys();
	var i:int=0;
	while( i < itemsKey.length )
	{
		if( ExchangeType.getCategory(itemsKey[i]) == ExchangeType.CHEST_CATE_110_BATTLES )
		{
			if( exchanger.items.get(itemsKey[i]).getState(TimeManager.instance.now) == ExchangeItem.CHEST_STATE_BUSY )
				notify("notify_chest_ready_"+itemsKey[i], (exchanger.items.get(itemsKey[i]).expiredAt + 15 + Math.random()*10)*1000);
			else if( exchanger.items.get(itemsKey[i]).getState(TimeManager.instance.now) == ExchangeItem.CHEST_STATE_READY )
				numForgots ++;
		}
		i++;
	}
	
	var later:int  = 1000 + Math.random() * 10000;
	if( numForgots == 1 )
		notify("notify_chest_forgot_a_chest",	date.time + later);
	else if( numForgots > 1 )
		notify("notify_chest_forgot_chests",	date.time + later);
}

private function notify(message:String, time:Number):void
{
	var title:String = AppModel.instance.descriptor.name;
//	trace(title, iconFile.exists ,soundFile.exists  )
	NativeAbilities.instance.scheduleLocalNotification(title, title, loc(message), time, 0, "", "", iconFile.exists?iconFile.nativePath:"", soundFile.exists?soundFile.nativePath:"");
	//var d:Date = new Date();d.time=time;trace(title, message, d)
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