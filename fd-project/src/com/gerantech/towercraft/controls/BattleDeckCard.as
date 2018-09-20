package com.gerantech.towercraft.controls
{
import com.gerantech.towercraft.views.HealthBar;
import com.gt.towers.battle.units.Card;
import com.gt.towers.constants.CardFeatureType;
import com.gt.towers.utils.lists.IntList;

import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.core.Starling;

public class BattleDeckCard extends TowersLayout
{
private var cardType:int;
private var populationBar:HealthBar;

private var cardView:BuildingCard;
public function BattleDeckCard(deck:IntList, index:int)
{
	super();
	this.cardType = deck.get(index);
}

override protected function initialize():void
{
	super.initialize();
	
	var padding:int = 16;
	layout = new AnchorLayout();
	
	cardView = new BuildingCard(false, false, false, false);
	cardView.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
	//cardView.data = deckIndex;
	addChild(cardView);
	cardView.setData(cardType);
}

/*public function get ready():Boolean
{
	if( building == null )
		return false;
	return building._population >= building.capacity; 
}*/

public function updateData():void
{
	//Starling.juggler.tween(populationBar, 0.5, {value:Card._population, transition:Transitions.EASE_OUT_ELASTIC});
	cardView.touchable = appModel.battleFieldView.battleData.battleField.elixirBar.get(player.troopType) >= game.calculator.getInt(CardFeatureType.F02_ELIXIR_SIZE, cardType, 1);
	cardView.alpha = cardView.touchable ? 1 : 0.5;
	//populationBar.value = building._population;
}

override public function dispose():void
{
	Starling.juggler.removeTweens(populationBar);
	super.dispose();
}
}
}