package com.gerantech.towercraft.models.vo
{
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.AppModel;
	import com.gt.towers.battle.BattleField;
	import com.gt.towers.battle.fieldes.FieldData;
	import com.smartfoxserver.v2.entities.Buddy;
	import com.smartfoxserver.v2.entities.Room;
	import com.smartfoxserver.v2.entities.User;
	import com.smartfoxserver.v2.entities.data.ISFSObject;

	public class BattleData
	{
		public var room:Room;
		public var map:FieldData;
		public var troopType:int;
		public var startAt:int;
		public var singleMode:Boolean;
		public var battleField:BattleField;
		public var opponent:User;
		public var me:User;

		public function BattleData(data:ISFSObject)
		{
			this.room = SFSConnection.instance.getRoomById(data.getInt("roomId"));
			this.startAt = data.getInt("startAt")-1;
			this.singleMode = data.getBool("singleMode");
			this.troopType = AppModel.instance.game.player.troopType = data.getInt("troopType");
			AppModel.instance.game.player.inFriendlyBattle = data.getBool("isFriendly");
			battleField = new BattleField(AppModel.instance.game, null, data.getText("mapName"), troopType, data.containsKey("hasExtraTime"));
			map = battleField.map;
			var playerIndex:int = getPlayerIndex();
			if( !map.isQuest )
			{
				this.me = room.playerList[ playerIndex ];
				this.opponent = room.playerList[ playerIndex==0?1:0 ];
			}
			else
			{
				this.me = room.playerList[ 0 ];
			}
			/*trace(this.troopType, "tt", data.getText("mapName"))	
			for (var i:int = 0; i < room.userList.length; i++) 
				trace("userList", i, room.userList[i].name);
			for (i = 0; i < room.playerList.length; i++) 
				trace("playerList", i, room.playerList[i].name);
			trace("troopType", troopType, playerIndex)*/
		}
		
		private function getPlayerIndex():int
		{
			if( SFSConnection.instance.mySelf.isSpectator )
			{
				for each ( var b:Buddy in SFSConnection.instance.buddyManager.buddyList ) 
					for ( var i:int = 0; i < room.playerList.length; i++ ) 
						if( room.playerList[i].name == b.name )
							return i;
			}
			else 
			{
				for ( i = 0; i < room.playerList.length; i++ ) 
					if( room.playerList[i].name == SFSConnection.instance.mySelf.name )
						return i;
			}
			return -1;
		}
	}
}