package com.gerantech.towercraft.views
{
import com.gerantech.towercraft.controls.headers.BattleFooter;
import com.gerantech.towercraft.managers.DropTargets;
import com.gerantech.towercraft.managers.TimeManager;
import com.gerantech.towercraft.managers.net.ResponseSender;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Fields;
import com.gerantech.towercraft.models.vo.BattleData;
import com.gerantech.towercraft.views.units.UnitView;
import com.gerantech.towercraft.views.weapons.BulletView;
import com.gt.towers.battle.BattleField;
import com.gt.towers.battle.units.Card;
import com.gt.towers.calculators.BulletFirePositionCalculator;
import com.gt.towers.constants.CardTypes;
import com.gt.towers.utils.Point3;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;

public class BattleFieldView extends Sprite
{
public static const DEBUG_MODE:Boolean = true;
//private var units:IntUnitMap;
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
	
	// map alignment
	alignPivot();
	
	AppModel.instance.aspectratio = Starling.current.stage.stageWidth / Starling.current.stage.stageHeight;
	pivotX = BattleField.WIDTH * 0.5;
	pivotY = BattleField.HEIGHT * 0.5;
	x = Starling.current.stage.stageWidth * 0.5;
	y = (Starling.current.stage.stageHeight - BattleFooter.HEIGHT * 0.5) * 0.5;

	// tile grass ground
	/*var tiledBG:Image = new Image(Assets.getTexture("ground-232"));
	tiledBG.tileGrid = new Rectangle(1, 1, 230, 230);*/
    var tiledBG:Quad = new Quad(1, 1, 0xA3BB3A);
	tiledBG.x = -BattleField.WIDTH * 0.5;
	tiledBG.width = BattleField.WIDTH * 2;
	tiledBG.y = -BattleField.HEIGHT * 0.5;
	tiledBG.height = BattleField.HEIGHT * 2;
	addChild(tiledBG);
	
	var axisRegion:Quad = new Quad(BattleField.WIDTH, BattleField.HEIGHT * 0.33333, 0xFF0000);
	axisRegion.alpha = 0.05;
	addChild(axisRegion);
	
	var allisRegion:Quad = new Quad(BattleField.WIDTH, BattleField.HEIGHT * 0.33333, 0x0000FF);
	allisRegion.y = BattleField.HEIGHT * 0.666666
	allisRegion.alpha = 0.2;
	addChild(allisRegion);
	
	roadsContainer = new Sprite();
	unitsContainer = new Sprite();
	elementsContainer = new Sprite();
	buildingsContainer = new Sprite();
	effectsContainer = new Sprite();
	guiImagesContainer = new Sprite();
	guiTextsContainer = new Sprite();

	scale = 0.8;
	touchable = false;
	//units = new IntUnitMap();
}		

protected function timeManager_updateHandler(e:Event):void 
{
	battleData.battleField.update(e.data as int);
}

public function createPlaces(battleData:BattleData) : void
{
	this.battleData = battleData;
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

	var images:Vector.<Image> = Fields.getField(battleData.battleField.map, "battlefields");
	for each( var img:Image in images )
		if( img.name == "battlefields" )
			elementsContainer.addChild(img);
		else
			roadsContainer.addChild(img);
	
	/*var len:uint = battleData.battleField.places.size();
	places = new Vector.<PlaceView>(len, true);
	for ( var i:uint=0; i<len; i++ )
	{
		var p:PlaceView = new PlaceView(battleData.battleField.places.get(i));
		p.name = p.place.index.toString();
		
		addChild(p);
		places[p.place.index] = p
	}*/
	
	addChild(buildingsContainer);
	addChild(effectsContainer);
	addChild(guiImagesContainer);
	addChild(guiTextsContainer);
}		

public function summonUnit(id:int, type:int, level:int, side:int, x:Number, y:Number, health:Number = -1, fixedPosition:Boolean = false) : void
{
	if( CardTypes.isSpell(type) )
	{
		var card:Card = new Card(AppModel.instance.game, type, level);
		var offset:Point3 = BulletFirePositionCalculator.getPoint(card.type, 0);
		var _x:Number = side == battleData.battleField.side ? x : BattleField.WIDTH - x;
		var _y:Number = side == battleData.battleField.side ? y : BattleField.HEIGHT - y;
		offset.x *= (side == battleData.battleField.side) ? 1 : -1;
		offset.y *= (side == battleData.battleField.side) ? 1 : -1;
		var spell:BulletView = new BulletView(battleData.battleField, id, card, side, _x + offset.x, _y + offset.y, offset.z, _x, _y, 0);
		battleData.battleField.bullets.set(id, spell);
		//trace("summon spell", " side:" + side, " x:" + x, " y:" + y, " offsetX:" + offset.x, " offsetY:" + offset.y, " offsetZ:" + offset.z);
		return;
	}
	
	var u:UnitView = new UnitView(id, type, level, side, x, y, 0);
	if( health >= 0 )
		u.health = health;
	if( fixedPosition )
		u.setPosition(battleData.battleField.side == 0 ? x : BattleField.WIDTH - x, battleData.battleField.side == 0 ? y : BattleField.HEIGHT - y, 0, true);
	battleData.battleField.units.set(id, u);

	/*units.set(id, new UnitView(id, type, side, level, x, y));
	UnitView(units.get(id)).alpha = 0.5;
	units.get(id).movable = false;*/
}

public function hitUnits(buletId:int, damage:Number, targets:Array) : void
{
	for each( var id:int in targets )
		battleData.battleField.units.get(id).hit(damage);
}

public function updateUnits():void
{
	/*if( !battleData.room.containsVariable("units") )
		return;
	var unitsList:SFSArray = battleData.room.getVariable("units").getValue() as SFSArray;
	for(var i:int=0; i<unitsList.size(); i++)
	{
		var vars:Array = unitsList.getText(i).split(",");// id, x, y, health
		if( !battleData.battleField.units.exists(vars[0]) )
			continue;
		//UnitView(units.get(vars[0])).setPosition(-1, vars[2]);
		var u:Unit = UnitView(battleData.battleField.units.get(vars[0]));
		var damage:Number = u.health - vars[3];
		if( damage > 0 )
			u.hit(damage);
		trace(u.side, damage);
		//u.setPosition(vars[1], vars[2]);
	}*/
}

override public function dispose() : void
{
	TimeManager.instance.removeEventListener(Event.UPDATE, timeManager_updateHandler);
	battleData.battleField.dispose();
	super.dispose();
}
}
}