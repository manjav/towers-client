package com.gerantech.towercraft.views
{
import com.gerantech.towercraft.managers.DropTargets;
import com.gerantech.towercraft.managers.TimeManager;
import com.gerantech.towercraft.managers.net.ResponseSender;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Fields;
import com.gerantech.towercraft.models.vo.BattleData;
import com.gerantech.towercraft.views.units.UnitView;
import com.smartfoxserver.v2.entities.data.SFSArray;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;

public class BattleFieldView extends Sprite
{
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
	
	// map alignment
	var _width:Number;
	var _height:Number;
	AppModel.instance.aspectratio = Starling.current.stage.stageWidth / Starling.current.stage.stageHeight;
	if(  AppModel.instance.aspectratio < AppModel.instance.formalAspectratio )
	{
		_width = Starling.current.stage.stageWidth;
		_height = Starling.current.stage.stageWidth * AppModel.instance.formalAspectratio;
		x = pivotX = _width * 0.5;
		pivotY = _height * 0.5;
		y = pivotY + (Starling.current.stage.stageHeight - _height ) * 0.5;
	}
	else
	{
		_height = Starling.current.stage.stageHeight;
		_width = Starling.current.stage.stageHeight * AppModel.instance.formalAspectratio;
		y = pivotY = _height * 0.5;
		pivotX = _width * 0.5;
		x = pivotX + (Starling.current.stage.stageWidth - _width ) * 0.5;
	}
	scale = 0.8;
	
	// tile grass ground
	//var tiledBG:Image = new Image(Assets.getTexture("ground-232"));
    var tiledBG:Quad = new Quad(1, 1, 0xA3BB3A);
	tiledBG.x = -_width * 0.5;
	tiledBG.y = -_height * 0.5;
	tiledBG.width = _width * 2;
	tiledBG.height = _height * 2;
	//tiledBG.tileGrid = new Rectangle(1, 1, 230, 230);
	addChild(tiledBG);
	
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
	battleData.battleField.update();
}

public function createPlaces(battleData:BattleData) : void
{
	this.battleData = battleData;
	responseSender = new ResponseSender(battleData.room);
	TimeManager.instance.addEventListener(Event.UPDATE, timeManager_updateHandler);
	
	addChild(roadsContainer);
	addChild(unitsContainer);
	addChild(elementsContainer);
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
	addChild(guiImagesContainer);
	addChild(guiTextsContainer);
}		

public function deployUnit(id:int, type:int, side:int, level:int, x:Number, y:Number) : void
{
	battleData.battleField.units.set(id, new UnitView(id, type, side, level, x, y));
	trace(unitsContainer.numChildren)
}
	
public function updateUnits():void
{
	//if( !appModel.battleFieldView.battleData.room.containsVariable("units") )
	//	return;
	var unitsList:SFSArray = battleData.room.getVariable("units").getValue() as SFSArray;
	for(var i:int=0; i<unitsList.size(); i++)
	{
		var vars:Array = unitsList.getText(i).split(",");// id, x, y, health
		//UnitView(battleData.battleField.units.get(vars[0])).setPosition(vars[1], vars[2]);
	}
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
	super.dispose();
}
}
}