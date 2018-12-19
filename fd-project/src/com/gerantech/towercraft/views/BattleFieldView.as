package com.gerantech.towercraft.views
{
import com.gerantech.towercraft.controls.headers.BattleFooter;
import com.gerantech.towercraft.managers.DropTargets;
import com.gerantech.towercraft.managers.TimeManager;
import com.gerantech.towercraft.managers.net.ResponseSender;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.vo.BattleData;
import com.gerantech.towercraft.views.units.UnitView;
import com.gerantech.towercraft.views.weapons.BulletView;
import com.gt.towers.battle.BattleField;
import com.gt.towers.battle.GameObject;
import com.gt.towers.battle.units.Card;
import com.gt.towers.battle.units.Unit;
import com.gt.towers.utils.GraphicMetrics;
import com.gt.towers.constants.CardTypes;
import com.gt.towers.events.BattleEvent;
import com.gt.towers.utils.Point3;
import com.gt.towers.utils.maps.IntUnitMap;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import flash.filesystem.File;
import starling.core.Starling;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starlingbuilder.engine.DefaultAssetMediator;

public class BattleFieldView extends Sprite
{
private var mapBuilder:MapBuilder;
private var units:IntUnitMap;
public var battleData:BattleData;
public var responseSender:ResponseSender;
public var dropTargets:DropTargets;
public var roadsContainer:Sprite;
public var unitsContainer:Sprite;
public var elementsContainer:Sprite;
public var buildingsContainer:Sprite;
public var guiImagesContainer:Sprite;
public var guiTextsContainer:Sprite;
public var effectsContainer:Sprite;

public function BattleFieldView()
{
	super();
	AppModel.instance.assets.enqueue( File.applicationDirectory.resolvePath( "assets/images/battle" ) );
	AppModel.instance.assets.loadQueue(assetManagerLoaded);
	units = new IntUnitMap();
	touchGroup = true;
	alignPivot();
	scale = 0.8;
	
	roadsContainer = new Sprite();
	unitsContainer = new Sprite();
	elementsContainer = new Sprite();
	buildingsContainer = new Sprite();
	effectsContainer = new Sprite();
	guiImagesContainer = new Sprite();
	guiTextsContainer = new Sprite();
}

private function assetManagerLoaded(ratio:Number):void 
{
	if( ratio < 1 )
		return;

	mapBuilder = new MapBuilder(new DefaultAssetMediator(AppModel.instance.assets));
	if( battleData != null )
		createPlaces(battleData);
}	

public function createPlaces(battleData:BattleData) : void
{
	this.battleData = battleData;
	if( mapBuilder == null )
		return;

	mapBuilder.create(battleData.battleField.json, false);
	mapBuilder.mainMap.x = BattleField.WIDTH * 0.5//Starling.current.stage.stageWidth * 0.5;
	mapBuilder.mainMap.y = BattleField.HEIGHT * 0.5//(Starling.current.stage.stageHeight - 330 * 0.5) * 0.5;
	addChild(mapBuilder.mainMap);
	
	AppModel.instance.aspectratio = Starling.current.stage.stageWidth / Starling.current.stage.stageHeight;
	pivotX = BattleField.WIDTH * 0.5;
	pivotY = BattleField.HEIGHT * 0.5;
	x = Starling.current.stage.stageWidth * 0.5;
	y = (Starling.current.stage.stageHeight - BattleFooter.HEIGHT * 0.5) * 0.5;

	battleData.battleField.state = BattleField.STATE_2_STARTED;
	responseSender = new ResponseSender(battleData.room);
	TimeManager.instance.addEventListener(Event.UPDATE, timeManager_updateHandler);
	
	addChild(roadsContainer);
	addChild(unitsContainer);
	addChild(elementsContainer);

	for( var i:int = 0; i < battleData.sfsData.getSFSArray("units").size(); i ++ )
	{
		var u:ISFSObject =  battleData.sfsData.getSFSArray("units").getSFSObject(i);
		summonUnit(u.getInt("i"), u.getInt("t"), u.getInt("l"), u.getInt("s"), u.getDouble("x"), u.getDouble("y"), u.getDouble("h"), true);
	}

	/*for ( i = 0; i < battleData.battleField.tileMap.width; i ++ )
		for ( var j:int = 0; j < battleData.battleField.tileMap.height; j ++ )
			drawTile(i, j, battleData.battleField.tileMap.map[i][j], battleData.battleField.tileMap.tileWidth, battleData.battleField.tileMap.tileHeight);*/
	
	addChild(buildingsContainer);
	addChild(effectsContainer);
	addChild(guiImagesContainer);
	addChild(guiTextsContainer);
}

protected function timeManager_updateHandler(e:Event):void 
{
	battleData.battleField.update(e.data as int);
}

public function summonUnit(id:int, type:int, level:int, side:int, x:Number, y:Number, health:Number = -1, fixedPosition:Boolean = false) : void
{
	if( CardTypes.isSpell(type) )
	{
		var card:Card = new Card(AppModel.instance.game, type, level);
		var offset:Point3 = GraphicMetrics.getPoint(card.type, 0);
		var spell:BulletView = new BulletView(battleData.battleField, id, card, side, x + offset.x, y + offset.y * (side == 0 ? 0.7 : -0.7), offset.z * 0.7, x, y, 0);
		battleData.battleField.bullets.set(id, spell);
		//trace("summon spell", " side:" + side, " x:" + x, " y:" + y, " offset:" + offset);
		return;
	}
	
	var u:UnitView = new UnitView(id, type, level, side, x, y, 0);
	u.addEventListener("findPath", findPathHandler);

	if( health >= 0 )
		u.health = health;
	battleData.battleField.units.set(id, u);
}

private function findPathHandler(e:BattleEvent):void 
{
	guiTextsContainer.removeChildren();
	var u:UnitView = e.currentTarget as UnitView;
	if( u.path == null )
		return;
	var c:uint = Math.random() * 0xFFFFFF;
	for (var i:int = 0; i < u.path.length; i ++)
		drawTile(u.path[i].i, u.path[i].j, c, battleData.battleField.tileMap.tileWidth, battleData.battleField.tileMap.tileHeight, 0.3);
}

public function hitUnits(buletId:int, targets:ISFSArray) : void
{
	for ( var i:int = 0; i < targets.size(); i ++ )
	{
		var id:int = targets.getSFSObject(i).getInt("i");
		var health:Number = targets.getSFSObject(i).getDouble("h");
		if( battleData.battleField.units.exists(id) )
			battleData.battleField.units.get(id).hit(battleData.battleField.units.get(id).health - health);
		else
			trace("unit " + id + " not found.");
	}
}

public function updateUnits():void
{
	return;
	if( !battleData.room.containsVariable("units") )
		return;
	var unitsList:SFSArray = battleData.room.getVariable("units").getValue() as SFSArray;
	for( var i:int=0; i < unitsList.size(); i++ )
	{
		var vars:Array = unitsList.getText(i).split(",");// id, x, y, health
		if( units.exists(vars[0]) )
		{
			units.get(vars[0]).setPosition(vars[1], vars[2], GameObject.NaN);
		}
		else
		{
			var u:UnitView = new UnitView(vars[0], vars[4], 1, vars[5], vars[1], vars[2], 0);
			u.alpha = 0.3;
			u.isDump = true;
			u.movable = false;
			units.set(vars[0], u);
		}
	}
	
	var us:Vector.<Unit> = units.values();
	for (i = 0; i < us.length; i++)
	{
		var id:int = getu(us[i].id);
		if( id == -1 )
		{
			us[i].dispose();
			units.remove(us[i].id);
		}
	}
	function getu(id:int) : int
	{
		for (var j:int = 0; j < unitsList.size(); j++)
		{
			vars = unitsList.getText(j).split(",");// id, x, y, health
			if( vars[0] == us[i].id )
				return us[i].id;
		}
		return -1;
	}
}

override public function dispose() : void
{
	TimeManager.instance.removeEventListener(Event.UPDATE, timeManager_updateHandler);
	if( battleData != null )
		battleData.battleField.dispose();
	if( mapBuilder != null )
		mapBuilder.dispose();
	super.dispose();
}

private function drawTile(i:int, j:int, color:int, width:int, height:int, alpha:Number = 0.1):void
{
	var q:Quad = new Quad(width - 2, height - 2, color);
	q.alpha = alpha;
	q.x = i * width;
	q.y = j * height;
	guiTextsContainer.addChild(q);
}
}
}