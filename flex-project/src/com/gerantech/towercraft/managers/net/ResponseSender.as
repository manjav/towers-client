package com.gerantech.towercraft.managers.net
{
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.views.PlaceView;
	import com.smartfoxserver.v2.entities.Room;
	import com.smartfoxserver.v2.entities.data.SFSObject;

	public class ResponseSender
	{
		public var room:Room;
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
			SFSConnection.instance.sendExtensionRequest(SFSCommands.FIGHT, sfsObj, room);
			//trace("sources", sources);
			//trace("destination", destination.place.index);			
		}
		
		public function hitTroop(troopId:int):void
		{
			var sfsObj:SFSObject = new SFSObject();
			sfsObj.putInt("i", troopId);
			SFSConnection.instance.sendExtensionRequest(SFSCommands.HIT, sfsObj, room);			
		}

		public function improveBuilding(index:int, upgradeType:int):void
		{
			var sfsObj:SFSObject = new SFSObject();
			sfsObj.putInt("i", index);
			sfsObj.putInt("t", upgradeType);
			SFSConnection.instance.sendExtensionRequest(SFSCommands.BUILDING_IMPROVE, sfsObj, room);
		}
		
		public function leave():void
		{
			SFSConnection.instance.sendExtensionRequest(SFSCommands.LEAVE, null, room);			
		}
	}
}