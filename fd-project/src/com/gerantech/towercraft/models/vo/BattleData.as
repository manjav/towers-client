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
public var allise:ISFSObject;
public var axis:ISFSObject;
public var outcomes:Vector.<RewardData>;
public var stars:Vector.<int>;
public var sfsData:ISFSObject;

public function BattleData(data:ISFSObject)
{
	this.sfsData = data;
	this.room = SFSConnection.instance.getRoomById(data.getInt("roomId"));
	this.singleMode = data.getBool("singleMode");
	this.allise = data.getSFSObject("p" + data.getInt("side"));
	this.axis = data.getSFSObject(data.getInt("side") == 0 ? "p1" : "p0");
	
	var alliseGame:Game =	instantiateGame(allise);
	var axisGame:Game =		instantiateGame(axis);
	function instantiateGame(gameSFS:ISFSObject) : Game
	{
		var game:Game = new Game();
		var initData:InitData = new InitData();
		initData.resources.set(ResourceType.R1_XP,	 	gameSFS.getInt("xp"));
		initData.resources.set(ResourceType.R2_POINT,	gameSFS.getInt("point"));
		var deckCards:Array = 							gameSFS.getSFSObject("deck").getKeys();
		for each ( var k:String in deckCards )
			initData.cardsLevel.set(int(k), 			gameSFS.getSFSObject("deck").getInt(k));
		game.init(initData);
		return game;
	}
	
	var field:FieldData = FieldProvider.getField(data.getText("type"), data.getInt("index"));
	field.mapLayout = data.getText("map");
	this.battleField = new BattleField();
	this.battleField.initialize(battleField.side == 0 ? AppModel.instance.game : axisGame, battleField.side == 0 ? axisGame : AppModel.instance.game, field, data.getInt("side"), data.getInt("startAt"), data.getDouble("now"), false, data.getBool("isFriendly"));
	this.battleField.state = BattleField.STATE_1_CREATED;
	this.battleField.decks = new IntIntCardMap();
	this.battleField.decks.set(0, BattleField.getDeckCards(battleField.side == 0 ? alliseGame : axisGame, SFSConnection.ArrayToMap(data.getSFSObject("p0").getSFSObject("deck").getKeys()), data.getBool("isFriendly")));
	this.battleField.decks.set(1, BattleField.getDeckCards(battleField.side == 0 ? axisGame : alliseGame, SFSConnection.ArrayToMap(data.getSFSObject("p1").getSFSObject("deck").getKeys()), data.getBool("isFriendly")));
	TimeManager.instance.setNow(Math.ceil(data.getDouble("now") / 1000));
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