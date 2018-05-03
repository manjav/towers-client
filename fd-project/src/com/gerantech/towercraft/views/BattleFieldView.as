package com.gerantech.towercraft.views
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.managers.DropTargets;
import com.gerantech.towercraft.managers.net.ResponseSender;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.Fields;
import com.gerantech.towercraft.models.vo.BattleData;
import starling.display.Quad;

import flash.geom.Rectangle;

import feathers.layout.AnchorLayout;

import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;

public class BattleFieldView extends TowersLayout
{
public var battleData:BattleData;

public var places:Vector.<PlaceView>;
public var troopsList:Vector.<TroopView>;
public var responseSender:ResponseSender;
public var dropTargets:DropTargets;
public var roadsContainer:Sprite;
public var troopsContainer:Sprite;
public var elementsContainer:Sprite;
public var buildingsContainer:Sprite;
public var guiImagesContainer:Sprite;
public var guiTextsContainer:Sprite;

public function BattleFieldView(){}
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	pivotX = 540;
	pivotY = 960;
	x = pivotX * appModel.scale;
	y = pivotY * appModel.scale + (stage.stageHeight - 1920 * appModel.scale) * 0.5;
	scale = appModel.scale * 0.8;

	// tile grass ground
	//var tiledBG:Image = new Image(Assets.getTexture("ground-232"));
    var tiledBG:Quad = new Quad(1, 1, 0xA3BB3A);
	tiledBG.x = -1080 * 0.25;
	tiledBG.y = -1920 * 0.25;
	tiledBG.width = 1080 * 2;
	tiledBG.height = 1920 * 2;// 2600;
	//tiledBG.tileGrid = new Rectangle(1, 1, 228, 228);
	addChild(tiledBG);

	roadsContainer = new Sprite();
	troopsContainer = new Sprite();
	elementsContainer = new Sprite();
	buildingsContainer = new Sprite();
	guiImagesContainer = new Sprite();
	guiTextsContainer = new Sprite();

	troopsList = new Vector.<TroopView>();
	troopsContainer.addEventListener(Event.ADDED, battleField_addedHandler);
	troopsContainer.addEventListener(Event.REMOVED, battleField_removedHandler);
}

private function battleField_addedHandler(event:Event):void
{
	var troopView:TroopView = event.target as TroopView;
	if( troopView == null )
		return;
	troopsList.push(troopView);
}
private function battleField_removedHandler(event:Event):void
{
	var troopView:TroopView = event.target as TroopView;
	if( troopView == null )
		return;
	troopsList.removeAt(troopsList.indexOf(troopView));
}		

public function createPlaces(battleData:BattleData):void
{
	this.battleData = battleData;
	responseSender = new ResponseSender(battleData.room);
	
	addChild(roadsContainer);
	addChild(troopsContainer);
	addChild(elementsContainer);
	var images:Vector.<Image> = Fields.getField(battleData.battleField.map, "battlefields");
	for each( var img:Image in images )
		if( img.name == "battlefields" )
			elementsContainer.addChild(img);
		else
			roadsContainer.addChild(img);
	
	var len:uint = battleData.battleField.places.size();
	places = new Vector.<PlaceView>(len, true);
	for ( var i:uint=0; i<len; i++ )
	{
		var p:PlaceView = new PlaceView(battleData.battleField.places.get(i));
		p.name = p.place.index.toString();
		
		addChild(p);
		places[p.place.index] = p
	}
	
	addChild(buildingsContainer);
	addChild(guiImagesContainer);
	addChild(guiTextsContainer);
}

public function createDrops() : void
{
	dropTargets = new DropTargets(stage);
	for each( var t:PlaceView in places )
		if( t.touchable )
			dropTargets.add(t);
}
}
}