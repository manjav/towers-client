package com.gerantech.towercraft.models.vo
{
	import com.gerantech.towercraft.models.AppModel;
	import com.gt.towers.battle.BattleField;
	import com.gt.towers.battle.fieldes.FieldData;
	import com.smartfoxserver.v2.entities.Room;
	import com.smartfoxserver.v2.entities.data.ISFSObject;

	public class BattleData
	{
		public var room:Room;
		public var map:FieldData;
		public var troopType:int;
		public var startAt:int;
		public var singleMode:Boolean;
		public var opponent:ISFSObject;
		public var battleField:BattleField;

		public function BattleData(mapName:String, opponent:ISFSObject, troopType:int, startAt:int, singleMode:Boolean, room:Room)
		{
			this.room = room;
			this.startAt = startAt;
			this.opponent = opponent;
			this.singleMode = singleMode;
			AppModel.instance.game.player.troopType = this.troopType = troopType;
			battleField = new BattleField(AppModel.instance.game, mapName, troopType);
			map = battleField.map;
		}
	}
}