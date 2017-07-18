package com.gerantech.towercraft.models.vo
{
	import com.gerantech.towercraft.models.AppModel;
	import com.gt.towers.battle.BattleField;
	import com.gt.towers.battle.fieldes.FieldData;
	import com.smartfoxserver.v2.entities.Room;
	import com.smartfoxserver.v2.entities.data.ISFSObject;

	public class BattleData
	{
		public var map:FieldData;
		public var troopType:int;
		public var startAt:int;
		public var room:Room;
		public var battleField:BattleField;
		public var opponent:ISFSObject;

		
		public function BattleData(mapName:String, opponent:ISFSObject, troopType:int, startAt:int, room:Room)
		{
			this.room = room;
			this.startAt = startAt;
			this.opponent = opponent;
			AppModel.instance.game.player.troopType = this.troopType = troopType;
			battleField = new BattleField(AppModel.instance.game, mapName, troopType);
			map = battleField.map;
		}

		public function get singleMode():Boolean
		{
			if(room == null)
				return false;
			return room.playerList.length == 1;
		}

	}
}