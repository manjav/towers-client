package com.gerantech.towercraft.views
{
import com.gerantech.towercraft.controls.headers.BattleFooter;
import com.gerantech.towercraft.managers.DropTargets;
import com.gerantech.towercraft.managers.SoundManager;
import com.gerantech.towercraft.managers.TimeManager;
import com.gerantech.towercraft.managers.net.ResponseSender;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.vo.BattleData;
import com.gerantech.towercraft.views.units.UnitView;
import com.gerantech.towercraft.views.weapons.BulletView;
import com.gt.towers.battle.BattleField;
import com.gt.towers.battle.units.Card;
import com.gt.towers.constants.CardTypes;
import com.gt.towers.events.BattleEvent;
import com.gt.towers.utils.GraphicMetrics;
import com.gt.towers.utils.Point2;
import com.gt.towers.utils.Point3;
import com.gt.towers.utils.maps.IntUnitMap;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import flash.filesystem.File;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starlingbuilder.engine.DefaultAssetMediator;

public class BattleFieldView extends Sprite
{
public var mapBuilder:MapBuilder;
public var battleData:BattleData;
public var responseSender:ResponseSender;
public var dropTargets:DropTargets;
public var roadsContainer:Sprite;
public var unitsContainer:Sprite;
public var guiImagesContainer:Sprite;
public var guiTextsContainer:Sprite;
public var effectsContainer:Sprite;
private var units:IntUnitMap;
private var center:Point2;

public function BattleFieldView() { super(); }
public function initialize () : void 
{
	units = new IntUnitMap();
	touchGroup = true;
	alignPivot();
	scale = 0.8;
	
	roadsContainer = new Sprite();
	unitsContainer = new Sprite();
	effectsContainer = new Sprite();
	guiImagesContainer = new Sprite();
	guiTextsContainer = new Sprite();
	
	if( AppModel.instance.assets.getObject("arts-rules") != null )
	{
		Starling.juggler.delayCall(assetManagerLoaded, 0.1, 1);
		return;
	}
	AppModel.instance.assets.enqueue(File.applicationDirectory.resolvePath("assets/images/battle"));
	AppModel.instance.assets.loadQueue(assetManagerLoaded);
}

private function assetManagerLoaded(ratio:Number):void 
{
	if( ratio < 1 )
		return;
	if( AppModel.instance.artRules == null )
		AppModel.instance.artRules = new ArtRules(AppModel.instance.assets.getObject("arts-rules"));
	mapBuilder = new MapBuilder(new DefaultAssetMediator(AppModel.instance.assets));
	dispatchEventWith(Event.COMPLETE);
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
	center = new Point2(Starling.current.stage.stageWidth * 0.5, (Starling.current.stage.stageHeight - BattleFooter.HEIGHT * 0.5) * 0.5);
	x = center.x;
	y = center.y;

	battleData.battleField.state = BattleField.STATE_2_STARTED;
	responseSender = new ResponseSender(battleData.room);
	TimeManager.instance.addEventListener(Event.UPDATE, timeManager_updateHandler);
	
	addChild(roadsContainer);
	addChild(unitsContainer);

	for( var i:int = 0; i < battleData.sfsData.getSFSArray("units").size(); i ++ )
	{
		var u:ISFSObject =  battleData.sfsData.getSFSArray("units").getSFSObject(i);
		summonUnit(u.getInt("i"), u.getInt("t"), u.getInt("l"), u.getInt("s"), u.getDouble("x"), u.getDouble("y"), u.getDouble("h"), true);
	}

	/*for ( i = 0; i < battleData.battleField.tileMap.width; i ++ )
		for ( var j:int = 0; j < battleData.battleField.tileMap.height; j ++ )
			drawTile(i, j, battleData.battleField.tileMap.map[i][j], battleData.battleField.tileMap.tileWidth, battleData.battleField.tileMap.tileHeight);*/
	
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
	if( mapBuilder == null )
	{
		trace("not able to summon id: " + id, "type: " + type, "side: " + side)
		return;
	}
	
	var card:Card = battleData.battleField.decks.get(side).get(type);
	if( card == null )
		card = new Card(battleData.battleField.games[side], type, level);
	if( CardTypes.isSpell(type) )
	{
		var offset:Point3 = GraphicMetrics.getSpellStartPoint(card.type);
		var spell:BulletView = new BulletView(battleData.battleField, id, card, side, x + offset.x, y + offset.y * (side == 0 ? 0.7 : -0.7), offset.z * 0.7, x, y, 0);
		battleData.battleField.bullets.set(id, spell);
		//trace("summon spell", " side:" + side, " x:" + x, " y:" + y, " offset:" + offset);
		return;
	}
	
	var u:UnitView = new UnitView(card, id, side, x, y, 0);
	u.addEventListener("findPath", findPathHandler);

	if( health >= 0 )
		u.health = health;
	battleData.battleField.units.set(id, u);
	
	AppModel.instance.sounds.addAndPlayRandom(AppModel.instance.artRules.getArray(type, ArtRules.SUMMON_SFX), SoundManager.CATE_SFX, SoundManager.SINGLE_BYPASS_THIS);
}

private function findPathHandler(e:BattleEvent):void 
{
	guiTextsContainer.removeChildren();
	var u:UnitView = e.currentTarget as UnitView;
	if( u.path == null )
		return;
	var c:uint = Math.random() * 0xFFFFFF;
	for (var i:int = 0; i < u.path.length; i ++)
		drawTile(u.path[i].x, u.path[i].y, c, battleData.battleField.tileMap.tileWidth, battleData.battleField.tileMap.tileHeight, 0.3);
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

public function updateUnits() : void
{
	if( !battleData.room.containsVariable("units") )
		return;
		
	var serverUnitIds:Array = SFSObject(battleData.room.getVariable("units").getValue()).getIntArray("keys");
	var clientUnitIds:Vector.<int> = battleData.battleField.units.keys();
	for( var i:int = 0; i < clientUnitIds.length; i++ )
		if( serverUnitIds.indexOf(clientUnitIds[i]) == -1 )
			battleData.battleField.units.get(clientUnitIds[i]).hit(100);
	
	/*var unitsList:SFSArray = battleData.room.getVariable("units").getValue() as SFSArray;
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
	}*/
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

public function shake() : void
{return;
	x = center.x + 5;
	y = center.y + 5;
	Starling.juggler.tween(this, 0.4, {x:center.x, y:center.y, transition:Transitions.EASE_IN_ELASTIC});
}

private function drawTile(x:Number, y:Number, color:int, width:int, height:int, alpha:Number = 0.1):void
{
	var q:Quad = new Quad(width - 2, height - 2, color);
	q.alpha = alpha;
	q.x = x - width * 0.5;
	q.y = y - -height * 0.5;
	guiTextsContainer.addChild(q);
}
}
}