package com.gerantech.towercraft.managers
{
import flash.utils.clearInterval;
import flash.utils.setInterval;
import starling.events.Event;
import starling.events.EventDispatcher;

public class TimeManager extends EventDispatcher
{
private var _now:uint;
private var _millis:Number;
private var intervalId:uint;
private static var _instance:TimeManager;
public function TimeManager(now:uint)
{
	_instance = this;
	_now = now;
	_millis = now * 1000;
	intervalId = setInterval(timeCounterCallback, 10);
}

public function get now():uint
{
	return _now;
}
public function setNow(value:uint):void
{
	_now = value;
	_millis = value * 1000
}

public function get millis():Number
{
	return _millis;
}

private function timeCounterCallback():void
{
	_millis += 10;
	if( _millis > _now * 1000 + 991 )
	{
		_now ++;
		dispatchEventWith(Event.CHANGE, false, _now)		
	}
	dispatchEventWith(Event.UPDATE, false, _millis)		
}

public static function get instance():TimeManager
{
	return _instance;
}

public function dispose():void
{
	clearInterval(intervalId);
	_instance = null;
	
}
}
}