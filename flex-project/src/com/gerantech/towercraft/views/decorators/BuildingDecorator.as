package com.gerantech.towercraft.views.decorators
{
import com.gerantech.towercraft.managers.BaseManager;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.views.BattleFieldView;
import com.gerantech.towercraft.views.HealthBar;
import com.gerantech.towercraft.views.PlaceView;
import com.gt.towers.buildings.Place;
import com.gt.towers.constants.BuildingFeatureType;
import com.gt.towers.constants.CardTypes;

import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import feathers.controls.text.BitmapFontTextRenderer;
import feathers.text.BitmapFontTextFormat;

import starling.core.Starling;
import starling.display.Image;
import starling.display.MovieClip;
import starling.events.Event;

public dynamic class BuildingDecorator extends BaseManager
{
public var bodyFactory:Function;
public var troopTypeFactory:Function;

protected var placeView:PlaceView;
protected var place:Place;

protected var bodyDisplay:Image;
private var troopTypeDisplay:Image;

protected var __bodyTexture:String;
protected var __troopTypeTexture:String;

private var populationIndicator:BitmapFontTextRenderer;
private var populationBar:HealthBar;
private var populationIcon:Image;
private var underAttack:MovieClip;
private var underAttackId:uint;
public var improvablePanel:ImprovablePanel;

public function BuildingDecorator(placeView:PlaceView)
{
	this.placeView = placeView;
	this.place = placeView.place;
	this.placeView.addEventListener(Event.UPDATE, placeView_updateHandler);
	
	if( bodyFactory == null )
		bodyFactory = defaultBodyFactory;
	
	if( troopTypeFactory == null )
		troopTypeFactory = defaultTroopTypeFactory;
	
	populationBar = new HealthBar(place.building.troopType, place.building.get_population(), place.building.capacity);
	populationBar.width = 140
	populationBar.height = 38
	populationBar.x = place.x - populationBar.width * 0.5 + 24;
	populationBar.y = place.y + 40;
	fieldView.guiImagesContainer.addChild(populationBar);

	populationIndicator = new BitmapFontTextRenderer();
	populationIndicator.textFormat = new BitmapFontTextFormat(Assets.getFont(), 36, 0xFFFFFF, "center")
	populationIndicator.width = populationBar.width;
	populationIndicator.touchable = false;
	populationIndicator.x = place.x - populationIndicator.width * 0.5 + 24 ;
	populationIndicator.y = place.y + 24;
	fieldView.guiTextsContainer.addChild(populationIndicator);
	
	populationIcon = new Image(Assets.getTexture("population-" + place.building.troopType));
	populationIcon.touchable = false;
	populationIcon.x = place.x - populationBar.width/2 - 18;
	populationIcon.y = place.y + 35;
	fieldView.guiImagesContainer.addChild(populationIcon);

	improvablePanel = new ImprovablePanel();
	improvablePanel.x = place.x - improvablePanel.width/2;
	improvablePanel.y = place.y + 50;
	fieldView.guiImagesContainer.addChild(improvablePanel);
	
	underAttack = new MovieClip(Assets.getTextures("building-sword-"), 22);
	underAttack.touchable = false;
	underAttack.visible = false;
	underAttack.x = place.x - underAttack.width * 0.5;
	underAttack.y = place.y - underAttack.height * 2;
	fieldView.buildingsContainer.addChild(underAttack);
	updateBuilding();
}

public function updateBuilding():void
{
	place.building.capacity = game.featureCaculator.get(BuildingFeatureType.F01_CAPACITY, place.building.type, place.building.get_level());
	bodyFactory();
	//	trace(place.index, place.building.type, troopType, place.building.troopType)
}


public function updateTroops(population:int, troopType:int):void
{
	populationIndicator.text = population + "/" + place.building.capacity;
	populationBar.troopType = troopType==-1 ? -1 : (troopType == player.troopType ? 0 : 1);
	populationBar.value = population;
	populationIcon.texture = Assets.getTexture("population-"+place.building.troopType);
	
	// _-_-_-_-_-_-_-_-_-_-_-_-  troop type -_-_-_-_-_-_-_-_-_-_-_-_-_
	var txt:String = __bodyTexture;// + place.building.type;
	if( troopType > -1 )
		txt += troopType == player.troopType ? "-0" : "-1";
	
	troopTypeFactory();
	if( __troopTypeTexture != txt )
	{
		__troopTypeTexture = txt;
		troopTypeDisplay.texture = Assets.getTexture(__troopTypeTexture);
		
		// play change troop sounds
		if( place.building.category == CardTypes.C000 )
		{
			// punch scale on occupation
			bodyDisplay.scale = 1.3;
			troopTypeDisplay.scale = 1.3;
			Starling.juggler.tween(bodyDisplay, 0.25, {scale:1});
			Starling.juggler.tween(troopTypeDisplay, 0.25, {scale:1});
			
			var tsound:String = troopType == player.troopType ? "battle-capture" : "battle-lost";
			if( appModel.sounds.soundIsAdded(tsound) )
				appModel.sounds.playSound(tsound);
			else
				appModel.sounds.addSound(tsound);
		}
	}
}

private function placeView_updateHandler(event:Event):void
{
	if( place.building.troopType != player.troopType )
	{
		improvablePanel.enabled = false;
		return;
	}
	
	var improvable:Boolean = false ;
	/*if( !player.inTutorial() && !SFSConnection.instance.mySelf.isSpectator )
	{
		var options:IntList = place.building.get_options();
		for (var i:int=0; i < options.size(); i++) 
		{
			//trace("index:", place.index, "option:", options.get(i), "improvable:", place.building.improvable(options.get(i)), "_population:", place.building._population)
			if( place.building.improvable(options.get(i)) && options.get(i)!=1 )
			{
				improvable = true;
				break;
			}
		}
	}*/
	improvablePanel.enabled = place.building.transformable(place.building) && !player.inTutorial() && !SFSConnection.instance.mySelf.isSpectator;
}

protected function defaultBodyFactory():void
{
	if( bodyDisplay == null )
	{
		__bodyTexture = place.building.type < 101 ? "building-1" : "building-14";
		bodyDisplay = new Image(Assets.getTexture(__bodyTexture));
		bodyDisplay.touchable = false;
		bodyDisplay.pivotX = bodyDisplay.width * 0.5;
		bodyDisplay.pivotY = bodyDisplay.height * 0.8;
		bodyDisplay.x = place.x;
		bodyDisplay.y = place.y;	
		fieldView.buildingsContainer.addChild(bodyDisplay);
		return;
	}
	
	if( __bodyTexture == (place.building.type < 101 ? "building-1" : "building-14") )
		return;
	__bodyTexture = place.building.type < 101 ? "building-1" : "building-14";
	bodyDisplay.texture = Assets.getTexture(__bodyTexture);
}

protected function defaultTroopTypeFactory():void
{
	if( troopTypeDisplay != null )
		return;
	
	troopTypeDisplay = new Image(Assets.getTexture("building-1-0"));
	troopTypeDisplay.touchable = false;
	troopTypeDisplay.pivotX = troopTypeDisplay.width * 0.5;
	troopTypeDisplay.pivotY = troopTypeDisplay.height * 0.8;
	troopTypeDisplay.x = place.x;
	troopTypeDisplay.y = place.y;
	fieldView.buildingsContainer.addChild(troopTypeDisplay);
}

public function showUnderAttack():void
{
	appModel.sounds.addAndPlaySound("battle-swords");
	underAttack.visible = true;
	clearTimeout(underAttackId);
	underAttackId = setTimeout(underAttack_completeHandler, 1000);
	Starling.juggler.add(underAttack);
	function underAttack_completeHandler():void
	{
		underAttack.visible = false;
		Starling.juggler.remove(underAttack);
	}
}

protected function get fieldView():		BattleFieldView {	return AppModel.instance.battleFieldView;	}
public function dispose():void
{
	populationIndicator.removeFromParent(true);
	populationIcon.removeFromParent(true);
	populationBar.removeFromParent(true);
	underAttack.removeFromParent(true);
	improvablePanel.removeFromParent(true);
	bodyDisplay.removeFromParent(true);
	troopTypeDisplay.removeFromParent(true);
}
}
}