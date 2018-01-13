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
		
		public function hitTroop(troopId:int, damage:Number):void
		{
			//trace("hitTroop", troopId);
			var sfsObj:SFSObject = new SFSObject();
			sfsObj.putInt("i", troopId);
			sfsObj.putDouble("d", damage);
			send(SFSCommands.HIT, sfsObj, room);			
		}

		public function improveBuilding(index:int, cardIndex:int):void
		{
			var sfsObj:SFSObject = new SFSObject();
			sfsObj.putInt("i", index);
			sfsObj.putInt("c", cardIndex);
			send(SFSCommands.BUILDING_IMPROVE, sfsObj, room);
		}
		
		public function leave(retryMode:Boolean=false):void
		{
			var params:SFSObject = new SFSObject();
			if( retryMode )
				params.putBool("retryMode", true);
				
			send(SFSCommands.LEAVE, params, room, false);			
		}
		
		public function resetAllVars():void
		{
			send(SFSCommands.RESET_ALL, null, room, false);			
		}
		
		public function sendSticker(stickerType:int):void
		{
			var sfsObj:SFSObject = new SFSObject();
			sfsObj.putInt("t", stickerType);
			send(SFSCommands.SEND_STICKER, sfsObj, room);			
		}
		
		private function send (extCmd:String, params:ISFSObject, room:Room, dislabledForSpectators:Boolean=true) : Boolean
		{
			if( !actived )
				return false;
			if ( dislabledForSpectators && SFSConnection.instance.mySelf.isSpectator )
				return false;
			SFSConnection.instance.sendExtensionRequest(extCmd, params, room);
			return true;
		}
	}
}