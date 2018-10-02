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
import com.gt.towers.battle.BattleField;
import com.gt.towers.battle.units.Unit;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;

public class BattleFieldView extends Sprite
{
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

public function BattleFieldView()
{
	super();
	touchable = false;
	//units = new IntUnitMap();
	// map alignment
	var _width:Number = BattleField.WIDTH
	var _height:Number = BattleField.HEIGHT;
	alignPivot();
	AppModel.instance.aspectratio = Starling.current.stage.stageWidth / Starling.current.stage.stageHeight;
	pivotX = BattleField.WIDTH * 0.5;
	pivotY = BattleField.HEIGHT * 0.5;
	x = Starling.current.stage.stageWidth * 0.5;
	y = (Starling.current.stage.stageHeight - BattleFooter.HEIGHT) * 0.5;

	/*if( AppModel.instance.aspectratio < AppModel.instance.formalAspectratio )
	{
		_width = Starling.current.stage.stageWidth;
		_height = Starling.current.stage.stageWidth * (BattleField.HEIGHT / BattleField.WIDTH);// AppModel.instance.formalAspectratio;
		x = pivotX = _width * 0.5;
		pivotY = _height * 0.5;
		y = pivotY + (Starling.current.stage.stageHeight - _height ) * 0.5;
	}
	else
	{
		_height = Starling.current.stage.stageHeight;
		_width = Starling.current.stage.stageHeight * (BattleField.WIDTH / BattleField.HEIGHT);// AppModel.instance.formalAspectratio;
		y = pivotY = _height * 0.5;
		pivotX = _width * 0.5;
		x = pivotX + (Starling.current.stage.stageWidth - _width ) * 0.5;
	}*/
	scale = 0.8;
	
	// tile grass ground
	//var tiledBG:Image = new Image(Assets.getTexture("ground-232"));
    var tiledBG:Quad = new Quad(1, 1, 0xA3BB3A);
	tiledBG.x = 0//-_width * 0.5;
	tiledBG.y = 0//-_height * 0.5;
	tiledBG.width = _width ;
	tiledBG.height = _height;
	//tiledBG.tileGrid = new Rectangle(1, 1, 230, 230);
	addChild(tiledBG);
	
	var tile1dBG:Quad = new Quad(1, 1, 0xFFFFFF);
	tile1dBG.x = 0//-_width * 0.5;
	tile1dBG.y = _height * 0.33333//-_height * 0.5;
	tile1dBG.width = _width ;
	tile1dBG.height = _height * 0.33333;
	tile1dBG.alpha = 0.2;
	addChild(tile1dBG);
	
	roadsContainer = new Sprite();
	unitsContainer = new Sprite();
	elementsContainer = new Sprite();
	buildingsContainer = new Sprite();
	guiImagesContainer = new Sprite();
	guiTextsContainer = new Sprite();
	
	/*troopsList = new Vector.<TroopView>();
	troopsContainer.addEventListener(Event.ADDED, battleField_addedHandler);
	troopsContainer.addEventListener(Event.REMOVED, battleField_removedHandler);
}

private function battleField_addedHandler(event:Event) : void
{
	var troopView:TroopView = event.target as TroopView;
	if( troopView == null )
		return;
	troopsList.push(troopView);
}
private function battleField_removedHandler(event:Event) : void
{
	var troopView:TroopView = event.target as TroopView;
	if( troopView == null )
		return;
	troopsList.removeAt(troopsList.indexOf(troopView));*/
}		

protected function timeManager_updateHandler(e:Event):void 
{
	battleData.battleField.update(e.data as int);
}

public function createPlaces(battleData:BattleData) : void
{
	this.battleData = battleData;
	responseSender = new ResponseSender(battleData.room);
	TimeManager.instance.addEventListener(Event.UPDATE, timeManager_updateHandler);
	
	addChild(roadsContainer);
	addChild(unitsContainer);
	addChild(elementsContainer);
	
	for( var i:int = 0; i < battleData.sfsData.getSFSArray("units").size(); i ++ )
	{
		var u:ISFSObject =  battleData.sfsData.getSFSArray("units").getSFSObject(i);
		deployUnit(u.getInt("i"), u.getInt("t"), u.getInt("l"), u.getInt("s"), u.getDouble("x"), u.getDouble("y"));
	}

	/*var images:Vector.<Image> = Fields.getField(battleData.battleField.map, "battlefields");
	for each( var img:Image in images )
		if( img.name == "battlefields" )
			elementsContainer.addChild(img);
		else
			roadsContainer.addChild(img);*/
	
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
	addChild(guiImagesContainer);
	addChild(guiTextsContainer);
}		

public function deployUnit(id:int, type:int, level:int, side:int, x:Number, y:Number, health:Number = -1) : void
{
	battleData.battleField.units.set(id, new UnitView(id, type, level, side, x, y));
	if( health >= 0 )
		battleData.battleField.units.get(id).health = health;
	//units.set(id, new UnitView(id, type, side, level, x + 100, y));
	//units.get(id).movable = false
}

public function updateUnits():void
{
	/*if( !battleData.room.containsVariable("units") )
		return;
	var unitsList:SFSArray = battleData.room.getVariable("units").getValue() as SFSArray;
	for(var i:int=0; i<unitsList.size(); i++)
	{
		var vars:Array = unitsList.getText(i).split(",");// id, x, y, health
		//UnitView(units.get(vars[0])).setPosition(-1, vars[2]);
		var u:Unit = UnitView(units.get(vars[0]));
		u.setPosition(vars[1], vars[2]);
	}*/
}

/*public function createDrops() : void
{
	dropTargets = new DropTargets(stage);
	for each( var t:PlaceView in places )
		if( t.touchable )
			dropTargets.add(t);
}*/

override public function dispose() : void
{
	TimeManager.instance.removeEventListener(Event.UPDATE, timeManager_updateHandler);
	battleData.battleField.dispose();
	super.dispose();
}
}
}