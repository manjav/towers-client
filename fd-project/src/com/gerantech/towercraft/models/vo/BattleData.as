package com.gerantech.towercraft.models.vo
{
import com.gerantech.towercraft.managers.TimeManager;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.AppModel;
import com.gt.towers.Game;
import com.gt.towers.InitData;
import com.gt.towers.battle.BattleField;
import com.gt.towers.battle.FieldProvider;
import com.gt.towers.utils.maps.IntIntIntMap;
import com.gt.towers.utils.maps.IntIntMap;
import com.smartfoxserver.v2.entities.Room;
import com.smartfoxserver.v2.entities.data.ISFSObject;

public class BattleData
{
public var room:Room;
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
	this.room = SFSConnection.instance.getRoomById(data.getInt("roomId"));
	this.singleMode = data.getBool("singleMode");
	FieldProvider.map = data.getText("map");
	AppModel.instance.game.player.inFriendlyBattle = data.getBool("isFriendly");
	var axisGame:Game = new Game();
	axisGame.init(new InitData());
	battleField = new BattleField();
	battleField.initialize(AppModel.instance.game, axisGame, data.getText("type"), data.getInt("index"), data.getInt("side"), data.getInt("startAt") * 1000, false);
	battleField.state = BattleField.STATE_1_CREATED;
	TimeManager.instance.setNow(battleField.startAt);
	allis = data.getSFSObject("allis");
	axis = data.getSFSObject("axis");
	
	battleField.decks = new IntIntIntMap();
	battleField.decks.set(0, SFSConnection.ToMap(battleField.side == 0 ? allis.getSFSArray("deck") : axis.getSFSArray("deck")));
	battleField.decks.set(1, SFSConnection.ToMap(battleField.side == 1 ? allis.getSFSArray("deck") : axis.getSFSArray("deck")));
}

public function getAlliseDeck():IntIntMap 
{
	return battleField.decks.get(battleField.side);
}
public function getAlliseEllixir():Number 
{
	return battleField.elixirBar.get(battleField.side);
}
}
}