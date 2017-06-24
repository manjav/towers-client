/**
 * Created by gilaas on 4/27/2017.
 */
package com.gerantech.towercraft.managers.net
{
	import com.gerantech.towercraft.managers.TimeManager;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.utils.LoadAndSaver;
	import com.gt.towers.Game;
	import com.gt.towers.InitData;
	import com.gt.towers.constants.ExchangeType;
	import com.gt.towers.exchanges.Exchange;
	import com.gt.towers.utils.GameError;
	import com.smartfoxserver.v2.entities.data.ISFSArray;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	public class CoreLoader extends EventDispatcher
	{
		//private var sfsObj:SFSObject;
		private var initData:InitData;
		
		public function CoreLoader(version:String, sfsObj:SFSObject)
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
			var coreFileName:String = "core-"+version+ ".swf";
			var nativePath:String = File.applicationStorageDirectory.resolvePath("cores/"+coreFileName).nativePath;
			var url:String = "http://"+(SFSConnection.instance.currentIp=="185.141.192.33"?"env-3589663.j.scaleforce.gr":SFSConnection.instance.currentIp)+"/cores/"+coreFileName;
			trace(coreFileName, "loaded.");
			var ls:LoadAndSaver = new LoadAndSaver(nativePath, url, null, true);
			ls.addEventListener(Event.COMPLETE, loaderInfo_completeHandler);
		}
		
		private function loaderInfo_completeHandler(e:Event):void
		{
			e.currentTarget.removeEventListener(Event.COMPLETE, loaderInfo_completeHandler);
			var gameClass:Class = LoadAndSaver(e.currentTarget).fileLoader.contentLoaderInfo.applicationDomain.getDefinition("com.gt.towers.Game") as Class;
			//var initClass:Class = e.currentTarget.applicationDomain.getDefinition("com.gt.tanks.InitData") as Class;
			
			try
			{
				var game:Game = new gameClass(initData);
				/*trace("name:",game.get_player().get_nickName());
				trace("id:",game.get_player().get_id());*/
			}
			catch(e:GameError)
			{
				trace(e.message);
			}

			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}