package com.gerantech.towercraft.models.vo
{
import com.gerantech.towercraft.managers.TimeManager;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.AppModel;
import com.gt.towers.Game;
import com.gt.towers.InitData;
import com.gt.towers.battle.BattleField;
import com.gt.towers.battle.fieldes.FieldData;
import com.gt.towers.utils.maps.IntIntMap;
import com.smartfoxserver.v2.entities.Room;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;

public class BattleData
{
public var room:Room;
public var map:FieldData;
public var troopType:int;
public var startAt:int;
public var singleMode:Boolean;
public var battleField:BattleField;
public var isLeft:Boolean;
public var allis:ISFSObject;
public var axis:ISFSObject;
public var outcomes:Vector.<RewardData>;

public function BattleData(data:ISFSObject)
{
	this.troopType = AppModel.instance.game.player.troopType = data.getInt("troopType");
	this.room = SFSConnection.instance.getRoomById(data.getInt("roomId"));
	this.singleMode = data.getBool("singleMode");
	this.startAt = data.getInt("startAt") + 1;
	TimeManager.instance.setNow(this.startAt);
	AppModel.instance.game.player.inFriendlyBattle = data.getBool("isFriendly");
	var axisGame:Game = new Game();
	axisGame.init(new InitData());
	battleField = new BattleField(AppModel.instance.game, axisGame, data.getText("mapName"), troopType, data.getBool("hasExtraTime"));
	map = battleField.map;
	allis = data.getSFSObject("allis");
	axis = data.getSFSObject("axis");
}
}
}