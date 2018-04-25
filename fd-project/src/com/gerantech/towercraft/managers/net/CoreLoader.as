/**
 * Created by gilaas on 4/27/2017.
 */
package com.gerantech.towercraft.managers.net
{
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.utils.LoadAndSaver;
import com.gt.towers.Game;
import com.gt.towers.InitData;
import com.gt.towers.arenas.Arena;
import com.gt.towers.battle.fieldes.FieldData;
import com.gt.towers.battle.fieldes.ImageData;
import com.gt.towers.battle.fieldes.PlaceData;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.events.CoreEvent;
import com.gt.towers.exchanges.Exchange;
import com.gt.towers.exchanges.ExchangeItem;
import com.gt.towers.utils.lists.IntList;
import com.gt.towers.utils.lists.PlaceDataList;
import com.gt.towers.utils.maps.IntArenaMap;
import com.gt.towers.utils.maps.IntIntMap;
import com.gt.towers.utils.maps.StringFieldMap;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.filesystem.File;

[Event(name="complete", type="flash.events.Event")]
[Event(name="error", type="flash.events.ErrorEvent")]
public class CoreLoader extends EventDispatcher
{
private var version:String;
private var serverData:SFSObject;
private var initData:InitData;

public function CoreLoader(sfsObj:SFSObject)
{
	this.serverData = sfsObj;
	this.version = serverData.getText("coreVersion");
	var coreFileName:String = "core-"+version+ ".swf";
	var nativePath:String = File.applicationStorageDirectory.resolvePath("cores/"+coreFileName).nativePath;
	var url:String = "http://"+SFSConnection.instance.currentIp+":8080/swfcores/"+coreFileName;
	
	initServerData(serverData);

	var ls:LoadAndSaver = new LoadAndSaver(nativePath, url, null, true, serverData.getInt("coreSize"));
	ls.addEventListener(Event.COMPLETE, loaderInfo_completeHandler);
	ls.addEventListener(IOErrorEvent.IO_ERROR, loaderInfo_ioErrorHandler);
}

protected function loaderInfo_ioErrorHandler(event:IOErrorEvent):void
{
	var loader:LoadAndSaver = event.currentTarget as LoadAndSaver;
	loader.removeEventListener(Event.COMPLETE, loaderInfo_completeHandler);
	loader.removeEventListener(IOErrorEvent.IO_ERROR, loaderInfo_ioErrorHandler);
	dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
}

private function loaderInfo_completeHandler(event:Event):void
{
	var loader:LoadAndSaver = event.currentTarget as LoadAndSaver;
	loader.removeEventListener(Event.COMPLETE, loaderInfo_completeHandler);
	loader.removeEventListener(IOErrorEvent.IO_ERROR, loaderInfo_ioErrorHandler);
	var gameClass:Class = loader.fileLoader.contentLoaderInfo.applicationDomain.getDefinition("com.gt.towers.Game") as Class;
	var initClass:Class = loader.fileLoader.contentLoaderInfo.applicationDomain.getDefinition("com.gt.towers.InitData") as Class;
	
	AppModel.instance.game = new Game();
	//AppModel.instance.game.eventDispatcher.addEventListener(CoreEvent.CHANGE, dsasd);
	AppModel.instance.game.init(initData);
	AppModel.instance.game.sessionsCount = serverData.getInt("sessionsCount");
	AppModel.instance.game.player.hasQuests = !serverData.containsKey("hasQuests") || serverData.getBool("hasQuests");
	AppModel.instance.game.player.tutorialMode = serverData.getInt("tutorialMode");
	AppModel.instance.game.player.invitationCode = serverData.getText("invitationCode");
	if( SFSConnection.instance.currentIp != "185.216.125.7" )
		AppModel.instance.game.player.admin = true;
	
	var exchange:ISFSObject;
	//trace(serverData.getSFSArray("exchanges").getDump())
	for( var i:int = 0; i < serverData.getSFSArray("exchanges").size(); i++ )
	{
		exchange = serverData.getSFSArray("exchanges").getSFSObject(i);
		var out:int = exchange.containsKey("outcome") ? exchange.getInt("outcome") : 0;
		if( exchange.containsKey("outKey") )
			out = exchange.getInt("outKey");
			trace(exchange.getInt("type"))
		AppModel.instance.game.exchanger.items.set( exchange.getInt("type"), new ExchangeItem(exchange.getInt("type"), exchange.getInt("reqKey"), exchange.getInt("reqValue"), out, exchange.getInt("outValue"), exchange.containsKey("num_exchanges")?exchange.getInt("num_exchanges"):0, exchange.containsKey("expired_at")?exchange.getInt("expired_at"):0));
	}
	
	var swfInitData:* = new initClass();
	swfInitData.nickName = serverData.getText("name");
	swfInitData.id = serverData.getInt("id");
	swfInitData.appVersion = AppModel.instance.descriptor.versionCode;
	swfInitData.market = AppModel.instance.descriptor.market;
	var swfCore:* = new gameClass();
	swfCore.init(swfInitData);
	initCoreData(swfCore);

	trace("server version :	" + version+"\nswf core version :	" + +swfCore.loginData.coreVersion+"\nswc core version :	"+AppModel.instance.game.loginData.coreVersion + "\nswf server size :	"+serverData.getInt("coreSize") + "\nplayerId :		" + initData.id);
	dispatchEvent(new Event(Event.COMPLETE));
}

protected function dsasd(event:CoreEvent):void
{
	trace(event.key, event.from, event.to)
}

private function initCoreData(game:*):void
{
	// put arena data
	AppModel.instance.game.arenas = new IntArenaMap();
	var arenaKeys:Vector.<int> = game.arenas.keys();
	for ( var i:int=0; i<arenaKeys.length; i++ )
	{
		var arenaSource:* = game.arenas.get(arenaKeys[i]);
		AppModel.instance.game.arenas.set( arenaKeys[i], new Arena( arenaSource.index, arenaSource.min, arenaSource.max, arenaSource.minWinStreak, arenaSource.cardsStr ) );
	}
	
	// put exchanger items
	var extSource:*;
	var extDest:ExchangeItem;
	var exItemsKeys:Vector.<int> = game.exchanger.items.keys();
	for ( i=0; i<exItemsKeys.length; i++ )
	{
		extSource = game.exchanger.items.get(exItemsKeys[i]);
		if ( ExchangeType.getCategory( extSource.type ) == ExchangeType.C0_HARD || ExchangeType.getCategory( extSource.type ) == ExchangeType.C10_SOFT )
		{
			extDest = new ExchangeItem(extSource.type, -1, -1, -1, -1, extSource.numExchanges, extSource.expiredAt);
			var reqs:IntIntMap = new IntIntMap();
			extDest.requirements = new IntIntMap();
			var rKeys:Vector.<int> = extSource.requirements.keys();
			for(var r:int=0; r<rKeys.length; r++ )
				extDest.requirements.set( rKeys[r], extSource.requirements.get(rKeys[r]) );
			rKeys = extSource.outcomes.keys();
			for(r=0; r<rKeys.length; r++ )
				extDest.outcomes.set( rKeys[r], extSource.outcomes.get(rKeys[r]) );
			
			AppModel.instance.game.exchanger.items.set( exItemsKeys[i], extDest );
		}
	}

	// put fields items
	AppModel.instance.game.fieldProvider.quests = new StringFieldMap();
	var fieldDest:FieldData;
	var fItemsKeys:Vector.<String> = game.fieldProvider.quests.keys();
	for ( i=0; i<fItemsKeys.length; i++ )
		AppModel.instance.game.fieldProvider.quests.set( fItemsKeys[i] , convertField( game.fieldProvider.quests.get(fItemsKeys[i]) ));
	
	AppModel.instance.game.fieldProvider.battles = new StringFieldMap();
	fItemsKeys = game.fieldProvider.battles.keys();
	for ( i=0; i<fItemsKeys.length; i++ )
		AppModel.instance.game.fieldProvider.battles.set( fItemsKeys[i] , convertField( game.fieldProvider.battles.get(fItemsKeys[i]) ));
}		

private function convertField(fieldSource:*):FieldData
{
	var ret:FieldData = new FieldData(fieldSource.index, fieldSource.name, fieldSource.times._list.join(','), fieldSource.introNum._list.join(','), fieldSource.startNum._list.join(','), fieldSource.endNum._list.join(','));
	ret.places = new PlaceDataList();
	for ( var p:int=0; p<fieldSource.places.size(); p++ )
	{
		var pd:* = fieldSource.places.get(p);
		ret.places.push( new PlaceData( pd.index,	pd.x, pd.y, pd.type, pd.troopType, pd.links._list.join(','), pd.enabled, pd.tutorIndex) );
	}
	for ( var g:int=0; g<fieldSource.images.size(); g++ )
	{
		var id:* = fieldSource.images.get(g);
		ret.images.push( new ImageData( id.name, id.tx, id.ty, id.a, id.b, id.c, id.d, id.px, id.py ) );
	}
	return ret;
}		

private function initServerData(sfsObj:SFSObject):void
{
	// create init data 
	initData = new InitData();
	initData.nickName = sfsObj.getText("name");
	initData.id = sfsObj.getInt("id");
	initData.appVersion = AppModel.instance.descriptor.versionCode;
	initData.market = AppModel.instance.descriptor.market;

	var elements:ISFSArray = sfsObj.getSFSArray("resources");
	var element:ISFSObject;
	for( var i:int=0; i<elements.size(); i++ )
	{
		element = elements.getSFSObject(i);
		initData.resources.set(element.getInt("type"), element.getInt("count"));
		if( element.getInt("type") < 1000 )
			initData.buildingsLevel.set(element.getInt("type"), element.getInt("level"));
	}
	
	elements = sfsObj.getSFSArray("quests");
	for( i=0; i<elements.size(); i++ )
	{
		element = elements.getSFSObject(i);
		initData.quests.set(element.getInt("index"), element.getInt("score"));
	}
	
	/*elements = sfsObj.getSFSArray("exchanges");
	for( i=0; i<elements.size(); i++ )
	{
		element = elements.getSFSObject(i);
		initData.exchanges.set( element.getInt("type"), new Exchange( element.getInt("type"), element.getInt("num_exchanges"), element.getLong("expired_at"), element.getInt("outcome")));
	}*/
}
}
}