package com.gerantech.towercraft.controls
{
import com.gerantech.towercraft.views.HealthBar;
import com.gt.towers.buildings.Building;

import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.core.Starling;

public class BattleDeckCard extends TowersLayout
{
private var building:Building;
private var deckIndex:int;
private var populationBar:HealthBar;

private var card:BuildingCard;
public function BattleDeckCard(building : Building, deckIndex:int)
{
	super();
	this.building = building;
	this.deckIndex = deckIndex;
}

override protected function initialize():void
{
	super.initialize();
	
	var padding:int = 16 * appModel.scale;
	layout = new AnchorLayout();
	
	card = new BuildingCard();
	card.layoutData = new AnchorLayoutData(0,0,NaN,0);
	card.showCount = true;
	card.showLevel = card.showSlider = false;
	card.data = deckIndex;
	addChild(card);
	card.type = building.type;
}

/*public function get ready():Boolean
{
	if( building == null )
		return false;
	return building._population >= building.capacity; 
}*/

public function updateData():void
{
	//Starling.juggler.tween(populationBar, 0.5, {value:building._population, transition:Transitions.EASE_OUT_ELASTIC});
	card.touchable = appModel.battleFieldView.battleData.battleField.elixirBar.get(player.troopType) >= building.elixirSize;
	card.alpha = card.touchable ? 1 : 0.5;
	//populationBar.value = building._population;
}

override public function dispose():void
{
	Starling.juggler.removeTweens(populationBar);
	super.dispose();
}
}
}