package com.gerantech.towercraft.utils
{
import com.gerantech.towercraft.models.AppModel;
import com.gt.towers.constants.PrefsTypes;
import flash.system.Capabilities;
import flash.utils.Dictionary;
import mx.resources.ResourceManager;

public class StrUtils
{
public static function generateRandomString(strlen:int):String
{
	var chars:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_@()%-";
	var num_chars:Number = chars.length - 1;
	var randomChar:String = "";
	
	for (var i:Number = 0; i < strlen; i++){
		randomChar += chars.charAt(Math.floor(Math.random() * num_chars));
	}
	return randomChar;
}

public static function getPostFixNums(num:int) : String
{
	switch( num )
	{
		case 1:		return num + "st";
		case 2:		return num + "nd";
		case 3:		return num + "rd";
		default:	return num + "th";
	}
}

public static function getLatinNumber(input:Object):String
{
	var _str:String = input.toString();
	_str = _str.split('۰').join('0')
	_str = _str.split('٠').join('0')
	_str = _str.split('۱').join('1')
	_str = _str.split('١').join('1')
	_str = _str.split('۲').join('2')
	_str = _str.split('٢').join('2')
	_str = _str.split('۳').join('3')
	_str = _str.split('٣').join('3')
	_str = _str.split('۴').join('4')
	_str = _str.split('٤').join('4')
	_str = _str.split('۵').join('5')
	_str = _str.split('٥').join('5')
	_str = _str.split('۶').join('6')
	_str = _str.split('٦').join('6')
	_str = _str.split('۷').join('7')
	_str = _str.split('٧').join('7')
	_str = _str.split('۸').join('8')
	_str = _str.split('٨').join('8')
	_str = _str.split('۹').join('9');
	_str = _str.split('٩').join('9');
	return(_str)
}
public static function getArabicNumber(input:Object):String
{
	var _str:String = input.toString();
	_str = _str.split('0').join('٠')
	_str = _str.split('1').join('١')
	_str = _str.split('2').join('٢')
	_str = _str.split('3').join('٣')
	_str = _str.split('4').join('٤')
	_str = _str.split('5').join('٥')
	_str = _str.split('6').join('٦')
	_str = _str.split('7').join('٧')
	_str = _str.split('8').join('٨')
	_str = _str.split('9').join('٩');
	return(_str)
}
public static function getPersianNumber(input:Object):String
{
	var _str:String = input+"";
	_str = _str.split('0').join('۰');
	_str = _str.split('1').join('۱');
	_str = _str.split('2').join('۲');
	_str = _str.split('3').join('۳');
	_str = _str.split('4').join('۴');
	_str = _str.split('5').join('۵');
	_str = _str.split('6').join('۶');
	_str = _str.split('7').join('۷');
	_str = _str.split('8').join('۸');
	_str = _str.split('9').join('۹');
	return(_str)
}
public static function getNumber(input:Object):String
{
/*			if(UserModel.instance.locale.value=="ar_SA")
		return getArabicNumber(input);
	else if(UserModel.instance.locale.dir=="rtl")*/
		return getPersianNumber(input);
/*			else
		return input.toString();*/
}
public static function getNumberFromLocale(str:Object, dir:String=""):String
{
	if(str==null)
		return '';
	
	var direction:String = dir=="" ? AppModel.instance.direction : dir;
	if(direction=='ltr')
		return str.toString();
	else
		return getArabicNumber(str.toString());
}

public static function join(_str:String, lines:Array, _patt:String):String
{
	if(lines==null || lines.length==0)
	{
		return(_str);
	}
	var srtList:Array = new Array ;
	while(lines.length > 14 && _patt == '\n')
	{
		lines.pop();
	}
	for (var i:uint=0; i<lines.length+1; i++)
	{
		srtList[i] = _str.substring(i ? lines[i - 1]:0, i<lines.length?lines[i]:_str.length);
	}
	return(srtList.join(_patt));
}

public static function getZeroNum(_val:String, _len:uint=3):String
{
	var zeroStr:String = '';
	_len = _len<_val.length ? _val.length : _len;
	for(var i:uint=0; i<_len-_val.length; i++)
	{
		zeroStr += '0';
	}
	return zeroStr+_val;
}

public static function getSplitsNum(_str:String, _patt:String):Array
{
	var ret:Array = new Array;
	var list:Array = _str.split(_patt);
	if(list.length>1)
	{
		list.pop();
		for (var b:uint=0; b<list.length; b++)
		{
			list[b] = list[b].length;
			if (b>0)
			{
				list[b] += list[b - 1];
			}
		}
		ret = list;
	}
	return (ret);
}

public static function getRepTranslate (str:String, ayaByAya:Boolean=true):String
{
	if(str=="~")
		str = str.split("~").join(ayaByAya?"تفسیر این آیه، در آیه یا آیات قبلی بصورت یکجا آمده است.":"");
	else
		str = str.split("$").join(ayaByAya?"\n":". ");
	return str;
}

public static function  getSimpleString (str:String, loc:String="ar", toLower:Boolean=false):String
{
	if(loc=="ar")
	{
		var signs:Array = "َُِّْٰۭٓۢۚۖۗۦًٌٍۙۘۜۥ".split("");
		for(var i:uint=0; i<signs.length; i++)
			str = str.split(signs[i]).join("");
		
		var alefs:Array = "إأٱآ".split("");
		for(i=0; i<alefs.length; i++)
			str = str.split(alefs[i]).join("ا");
		
		str = str.split("ة").join("ه");
		str = str.split("ؤ").join("و");
		str = str.split("ي").join("ی");
		str = str.split("ى").join("ی");
		//str = str.split("ی").join("ي");
		
		str = str.split("ك").join("ک");
	}
	if( toLower )
		str = str.toLowerCase();
	return str;
}

public static function  getFullPath (path:String, sura:uint, aya:uint, post:String="dat"):String
{
	return (path+"/"+getZeroNum(sura.toString())+"/"+getZeroNum(sura.toString())+getZeroNum(aya.toString())+"."+post);
}
public static function  getFullURL (path:String, sura:uint, aya:uint, post:String="mp3"):String
{
	return (path + "/" + getZeroNum(sura.toString()) + getZeroNum(aya.toString()) + "." + post);
}

public static function getLocaleByMarket(market:String = null) : String
{
	switch( market )
	{
		case "google":
		case "appstore":
			return getLocal("en");
	}
	return getLocal("fa");
}

public static function getLocalesByMarket(market:String = null) : Array
{
	switch( market )
	{
		case "google":
		case "appstore":
			return ["en_US"];
	}
	return ["fa_IR", "en_US"];
}

public static function getLocal(local:String = null) : String
{
	var ret:String = "en_US";
	//if( local == null )
	//	local = Capabilities.languages[0].split("-")[0];
	
	switch( local )
	{
		//case "ar":	return "ar_SA";
		case "en":	return "en_US";
		//case "es":	return "es_ES";
		case "fa":	return "fa_IR";
		//case "fr":	return "fr_FR";
		//case "id":	return "id_ID";
		//case "ru":	return "ru_RU";
		//case "tr":	return "tr_TR";
		//case "ur":	return "ur_PK";
	}
	return ret;
}

public static function getDir(local:String = null) : String
{		
	if( local == null )
		local = Capabilities.languages[0].split("-")[0];
	
	switch( local )
	{
		case "ar":
		case "ar_SA":
		case "fa":
		case "fa_IR":
		case "ur":
		case "ur_PK":
			return "rtl";
	}
	return "ltr";
}

public static function loc(resourceName:String, parameters:Array = null) : String
{
	var ret:String = ResourceManager.getInstance().getString("loc", resourceName, parameters, AppModel.instance.game != null ? AppModel.instance.game.player.prefs.get(PrefsTypes.SETTINGS_4_LOCALE) : AppModel.instance.locale);
	return ret == null || ret == "undefined" ? resourceName : ret;
}

//  UINT TO TIME _________________________________________________________________________
public static function dateToTime(date:Date, _mode:String='Second', separator:String=":"):String
{
	var time:uint = date.hours*3600+date.minutes*60+date.seconds;
	if (_mode == 'Milisecond')
	{
		time *= 1000;
		time += date.milliseconds;
	}
	return uintToTime(time, _mode, separator); 
}

//  UINT TO TIME _________________________________________________________________________
public static function uintToTime(_time:uint, _mode:String='Second', separator:String=":"):String
{
	var ret:String;
	var mili:uint;
	if (_mode == 'Milisecond')
	{
		mili = _time % 1000;
		_time = Math.floor(_time / 1000);
		//trace(_time);
	}
	
	var sec:uint = _time % 60;
	var min:uint;
	var hrs:uint;
	var secStr:String = sec < 10 ? '0' + sec:'' + sec;
	var minStr:String;
	var hrsStr:String;
	if (_time < 3600)
	{
		min = Math.floor(_time / 60);
		minStr = min < 10 ? '0' + min:'' + min;
		ret = _mode == 'Second' ? minStr + separator + secStr   :   minStr + separator + secStr + separator + mili.toFixed(2);
	}
	else
	{
		min = Math.floor(uint(_time % 3600) / 60);
		hrs = Math.floor(_time / 3600);
		minStr = min < 10 ? '0' + min:'' + min;
		hrsStr = hrs < 10 ? '0' + hrs:'' + hrs;
		ret = _mode == 'Second' ? hrsStr + separator + minStr + separator + secStr:hrsStr + separator + minStr + separator + secStr + separator + mili;
	}
	return ret;
}

public static function toTimeFormat(seconds:int):String
{
	var minutes:int = Math.floor( seconds / 60 );
	seconds -= minutes * 60;
	
	var hours:int = Math.floor( minutes / 60 );
	minutes -= hours * 60;
	
	var days:int = Math.floor( hours / 24 );
	hours -= days * 24;
	
	if (days > 0)
	{
		if (hours <= 0)
			return days + "d";
		return days + "d " + hours + "h";
	}
	else if (hours > 0)
	{
		if (minutes <= 0)
			return hours + "h";
		
		return hours + "h " + minutes + "m";
	}
	else if (minutes > 0)
	{
		if (seconds <= 0)
			return minutes + "m";
		
		return minutes+ "m " + seconds + "s";
	}
	else
	{
		return seconds + "s";
	}
}

public static function toElapsed(seconds:int):String
{
	if( seconds < 300 )
		return loc("ago_moments");

	var minutes:int = Math.round( seconds / 60 );
	if( minutes < 60 )
		return loc("ago_minutes", [minutes]);

	var hours:int = Math.floor( minutes / 60 );
	if( hours < 24 )
		return loc("ago_hours", [hours]);
	
	var days:int = Math.floor( hours / 24 );
	if( days < 31 )
		return loc("ago_days", [days]);
	
	var months:int = Math.floor( days / 30 );
	if( months < 13 )
		return loc("ago_months", [months]);

	return loc("ago_years", [Math.floor( months / 12 )]);
}

public static function getDateString(_date:Date, isTime:Boolean=false):String
{
	var ret:String = _date.fullYear+'-'+uint(_date.month+1)+'-'+_date.date ;
	if( isTime )
		ret = getNumberString(_date.hours, 2)+":"+getNumberString(_date.minutes, 2)+":"+getNumberString(_date.seconds, 2) + "  " + ret;
	return ret;
}
public static function getNumberString(_num:Number, _len:uint):String
{
	var ret:String;
	var num:String = _num.toString();
	for(var i:int=0; i<_len-num.length; i++)
	{
		num = '0'+num;
	}
	return(num);
}
public static function getCharByUint(_num:uint):String
{
	const charList:Array = new Array('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z');
	return charList[_num].toString();
}
public static function getAlphabetByUint(_num:uint):String
{
	const alphabetList:Array = new Array('I','II','III','IV','V','VI','VII','VIII','IX','X','XI','XII','XIII');
	return alphabetList[_num];
}
public static function getColorNumber(_str:String):uint
{
	return uint('0x'+_str.substr(1));
}		
//  SUMMERY TEXT   _________________________________________________________________________
public static function truncateText(str:String, len:uint, truncatePost:String = " ..."):String
{
	return ( str.length > len ? str.substr(0, len-truncatePost.length) + truncatePost : str );
}

public static function getParams(queryString:String):Dictionary
{
	var ret:Dictionary = new Dictionary();
	var cmds:Array = queryString.split("&");
	for each( var condition:String in cmds )
	{
		var sides:Array = condition.split("=");
		ret[sides[0]] = sides[1];
	}
	return ret;
}

static public function getCurrencyFormat(count:int):String 
{
	var ret:String = count.toString();
	if( count < 1000 )
		return ret;
	else if ( count < 1000000 )
	{
		return ret.substr(0, ret.length - 3) + "," + ret.substr(ret.length - 3);
	}
	return ret
}
}
}