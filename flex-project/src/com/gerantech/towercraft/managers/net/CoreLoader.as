/**
 * Created by gilaas on 4/27/2017.
 */
package com.gerantech.towercraft.managers.net
{
	import com.gerantech.towercraft.managers.TimeManager;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.AppModel;
	import com.gt.towers.Game;
	import com.gt.towers.InitData;
	import com.gt.towers.battle.fieldes.FieldData;
	import com.gt.towers.battle.fieldes.ImageData;
	import com.gt.towers.battle.fieldes.PlaceData;
	import com.gt.towers.constants.ExchangeType;
	import com.gt.towers.exchanges.Exchange;
	import com.gt.towers.exchanges.ExchangeItem;
	import com.gt.towers.utils.lists.IntList;
	import com.gt.towers.utils.lists.PlaceDataList;
	import com.gt.towers.utils.maps.IntIntMap;
	import com.gt.towers.utils.maps.StringFieldMap;
	import com.smartfoxserver.v2.entities.data.ISFSArray;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	public class CoreLoader extends EventDispatcher
	{
		private var version:String;
		private var sfsObj:SFSObject;
		private var initData:InitData;
		
		public function CoreLoader(version:String, sfsObj:SFSObject)
		{
			this.version = version;
			initServerData(sfsObj);
			
			var coreFileName:String = "core-"+version+ ".swf";
			var nativePath:String = File.applicationStorageDirectory.resolvePath("cores/"+coreFileName).nativePath;
			var url:String = "http://"+(SFSConnection.instance.currentIp=="185.141.192.33"?"env-3589663.j.scaleforce.gr":SFSConnection.instance.currentIp)+"/cores/"+coreFileName;
			//trace(coreFileName, "loaded.");
			/*var ls:LoadAndSaver = new LoadAndSaver(nativePath, url, null, true);
			ls.addEventListener(Event.COMPLETE, loaderInfo_completeHandler);*/
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderInfo_completeHandler);
			loader.load(new URLRequest(url), new LoaderContext(false, ApplicationDomain.currentDomain));
		}

		
		private function loaderInfo_completeHandler(e:Event):void
		{
			e.currentTarget.removeEventListener(Event.COMPLETE, loaderInfo_completeHandler);
			var gameClass:Class = e.currentTarget.applicationDomain.getDefinition("com.gt.towers.Game") as Class;
			var initClass:Class = e.currentTarget.applicationDomain.getDefinition("com.gt.towers.InitData") as Class;
			var exchangeClass:Class = e.currentTarget.applicationDomain.getDefinition("com.gt.towers.exchanges.Exchange") as Class;
			
			AppModel.instance.game = new Game(initData);
			var swfCore:* = new gameClass(new initClass())
			initCoreData(swfCore);

			//trace("request version :	" + version+"\nserver core version :	" + +swfCore.loginData.coreVersion+"\nswc core version :	"+AppModel.instance.game.loginData.coreVersion + "\nplayerId :		" + initData.id);

			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function initCoreData(game:*):void
		{
			// put exchanger items
			var extSource:*;
			var extDest:ExchangeItem;
			var exItemsKeys:Vector.<int> = game.exchanger.items.keys();
			for ( var i:int=0; i<exItemsKeys.length; i++ )
			{
				extSource = game.exchanger.items.get(exItemsKeys[i]);
				if ( ExchangeType.getCategory( extSource.type ) == ExchangeType.S_0_HARD || ExchangeType.getCategory( extSource.type ) == ExchangeType.S_10_SOFT )
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
			AppModel.instance.game.fieldProvider.fields = new StringFieldMap();
			var fieldSource:*;
			var fieldDest:FieldData;
			var fItemsKeys:Vector.<String> = game.fieldProvider.fields.keys();
			for ( i=0; i<fItemsKeys.length; i++ )
			{
				fieldSource = game.fieldProvider.fields.get(fItemsKeys[i]);
				fieldDest = new FieldData(fieldSource.index, fieldSource.name, fieldSource.hasIntro, fieldSource.hasFinal, fieldSource.times._list.join(','));
				fieldDest.places = new PlaceDataList();
				for ( var p:int=0; p<fieldSource.places.size(); p++ )
				{
					var pd:* = fieldSource.places.get(p);
					fieldDest.places.push( new PlaceData( pd.index,	pd.x, pd.y, pd.type, pd.troopType, pd.links._list.join(','), pd.enabled, pd.tutorIndex) );
				}
				for ( var g:int=0; g<fieldSource.images.size(); g++ )
				{
					var id:* = fieldSource.images.get(g);
					fieldDest.images.push( new ImageData( id.name, id.tx, id.ty, id.a, id.b, id.c, id.d, id.px, id.py ) );
				}
				AppModel.instance.game.fieldProvider.fields.set( fItemsKeys[i] , fieldDest );
			}
		}		
		
		
		private function initServerData(sfsObj:SFSObject):void
		{
			// create init data 
			initData = new InitData();
			initData.nickName = sfsObj.getText("name");
			initData.id = sfsObj.getInt("id");
			new TimeManager(sfsObj.getLong("serverTime"));
			
			var elements:ISFSArray = sfsObj.getSFSArray("resources");
			var element:ISFSObject;
			for(var i:int=0; i<elements.size(); i++)
			{
				element = elements.getSFSObject(i);
				initData.resources.set(element.getInt("type"), element.getInt("count"));
				if(element.getInt("type") < 1000)
					initData.buildingsLevel.set(element.getInt("type"), element.getInt("level"));
			}
			
			elements = sfsObj.getSFSArray("quests");
			for( i=0; i<elements.size(); i++ )
			{
				element = elements.getSFSObject(i);
				initData.quests.set(element.getInt("index"), element.getInt("score"));
			}
			
			elements = sfsObj.getSFSArray("exchanges");
			for( i=0; i<elements.size(); i++ )
			{
				element = elements.getSFSObject(i);
				initData.exchanges.set( element.getInt("type"), new Exchange( element.getInt("type"), element.getInt("num_exchanges"), element.getLong("expired_at"), element.getInt("outcome")));
			}			
		}
	}
}