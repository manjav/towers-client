package com.gerantech.towercraft.managers.net
{
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.views.PlaceView;
	import com.smartfoxserver.v2.entities.Room;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.smartfoxserver.v2.entities.data.SFSObject;

	public class ResponseSender
	{
		public var room:Room;
		public var actived:Boolean = true;
		public function ResponseSender(room:Room)
		{
			this.room = room;
		}
		
		public function fight(sourceTowers:Vector.<PlaceView>, destination:PlaceView):void
		{
			var sfsObj:SFSObject = new SFSObject();
			var sources:Array = new Array();
			for each(var tp:PlaceView in sourceTowers)
				sources.push(tp.place.index);
			sfsObj.putIntArray("s", sources);
			sfsObj.putInt("d", destination.place.index);
			send(SFSCommands.FIGHT, sfsObj, room);
			//trace("sources", sources);
			//trace("destination", destination.place.index);			
		}
		
		public function hitTroop(troopId:int):void
		{
			var sfsObj:SFSObject = new SFSObject();
			sfsObj.putInt("i", troopId);
			send(SFSCommands.HIT, sfsObj, room);			
		}

		public function improveBuilding(index:int, upgradeType:int):void
		{
			var sfsObj:SFSObject = new SFSObject();
			sfsObj.putInt("i", index);
			sfsObj.putInt("t", upgradeType);
			send(SFSCommands.BUILDING_IMPROVE, sfsObj, room);
		}
		
		public function leave():void
		{
			send(SFSCommands.LEAVE, null, room);			
		}
		
		public function resetAllVars():void
		{
			send(SFSCommands.RESET_ALL_VARS, null, room);			
		}
		
		
		
		
		
		private function send (extCmd:String, params:ISFSObject, room:Room) : Boolean
		{
			if ( !actived )
				return false;
			SFSConnection.instance.sendExtensionRequest(extCmd, params, room);
			return true;
		}
	}
}