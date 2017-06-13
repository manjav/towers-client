/**
 * Created by gilaas on 4/27/2017.
 */
package com.gerantech.towercraft.managers.net
{
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.utils.LoadAndSaver;
	import com.gt.towers.Game;
	import com.gt.towers.InitData;
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
			
			var resources:ISFSArray = sfsObj.getSFSArray("resources");
			var resource:ISFSObject;
			for(var i:int=0; i<resources.size(); i++)
			{
				resource = resources.getSFSObject(i);
				initData.resources.set(resource.getInt("type"), resource.getInt("count"));
				if(resource.getInt("type") < 1000)
					initData.buildingsLevel.set(resource.getInt("type"), resource.getInt("level"));
			}

			/*for(var i:int=0; i<WeaponType.NUM_WEAPONS; i++)
				initData.weaponsLevel.set(i, 0);*/

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