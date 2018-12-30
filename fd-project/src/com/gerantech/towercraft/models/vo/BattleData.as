package com.gerantech.towercraft.models.vo
{
import com.gerantech.towercraft.managers.TimeManager;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.AppModel;
import com.gt.towers.Game;
import com.gt.towers.InitData;
import com.gt.towers.battle.BattleField;
import com.gt.towers.battle.FieldProvider;
import com.gt.towers.battle.fieldes.FieldData;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.utils.maps.IntCardMap;
import com.gt.towers.utils.maps.IntIntCardMap;
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
	this.allis = data.getSFSObject("allis");
	this.axis = data.getSFSObject("axis");
	
	var axisGame:Game = new Game();	
	axisGame.init(new InitData());
	axisGame.player.resources.set(ResourceType.R1_XP,	 axis.getInt("xp"));
	axisGame.player.resources.set(ResourceType.R2_POINT, axis.getInt("point"));
	
	var field:FieldData = FieldProvider.getField(data.getText("type"), data.getInt("index"));
	field.mapLayout = data.getText("map");
	battleField = new BattleField();
	battleField.initialize(AppModel.instance.game, axisGame, field, data.getInt("side"), data.getInt("startAt") * 1000, false, data.getBool("isFriendly"));
	battleField.state = BattleField.STATE_1_CREATED;
	
	battleField.decks = new IntIntCardMap();
	battleField.decks.set(0, BattleField.getDeckCards(battleField.side == 0 ? AppModel.instance.game : axisGame, SFSConnection.ArrayToMap(battleField.side == 0 ? allis.getIntArray("deck") : axis.getIntArray("deck")), data.getBool("isFriendly")));
	battleField.decks.set(1, BattleField.getDeckCards(battleField.side == 1 ? axisGame : AppModel.instance.game, SFSConnection.ArrayToMap(battleField.side == 1 ? allis.getIntArray("deck") : axis.getIntArray("deck")), data.getBool("isFriendly")));
	
	TimeManager.instance.setNow(battleField.startAt);
}

public function getAlliseDeck():IntCardMap 
{
	return battleField.decks.get(battleField.side);
}
public function getAlliseEllixir():Number 
{
	return battleField.elixirBar.get(battleField.side);
}
}
}