package com.gerantech.towercraft.models.vo
{
import com.gerantech.towercraft.managers.TimeManager;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.AppModel;
import com.gt.towers.Game;
import com.gt.towers.InitData;
import com.gt.towers.battle.BattleField;
import com.gt.towers.battle.fieldes.FieldData;
import com.gt.towers.utils.maps.IntIntIntMap;
import com.gt.towers.utils.maps.IntIntMap;
import com.smartfoxserver.v2.entities.Room;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;

public class BattleData
{
public var room:Room;
public var troopType:int;
public var singleMode:Boolean;
public var battleField:BattleField;
public var isLeft:Boolean;
public var allis:ISFSObject;
public var axis:ISFSObject;
public var outcomes:Vector.<RewardData>;
public var sfsData:ISFSObject;

public function BattleData(data:ISFSObject)
{
	this.sfsData = data;
	this.troopType = AppModel.instance.game.player.troopType = data.getInt("troopType");
	this.room = SFSConnection.instance.getRoomById(data.getInt("roomId"));
	this.singleMode = data.getBool("singleMode");

	AppModel.instance.game.player.inFriendlyBattle = data.getBool("isFriendly");
	var axisGame:Game = new Game();
	axisGame.init(new InitData());
	battleField = new BattleField(AppModel.instance.game, axisGame, data.getText("mapName"), troopType, data.getBool("hasExtraTime"));
	battleField.startAt = data.getInt("startAt");
	battleField.now = battleField.startAt * 1000;
	TimeManager.instance.setNow(battleField.startAt);
	allis = data.getSFSObject("allis");
	axis = data.getSFSObject("axis");
	
	battleField.decks = new IntIntIntMap();
	battleField.decks.set(0, SFSConnection.ToMap(troopType == 0 ? allis.getSFSArray("deck") : axis.getSFSArray("deck")));
	battleField.decks.set(1, SFSConnection.ToMap(troopType == 1 ? allis.getSFSArray("deck") : axis.getSFSArray("deck")));
}

public function getAlliseDeck():IntIntMap 
{
	return battleField.decks.get(troopType);
}
}
}