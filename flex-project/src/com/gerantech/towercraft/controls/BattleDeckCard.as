package com.gerantech.towercraft.controls
{
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.views.HealthBar;
import com.gt.towers.buildings.Building;

import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.animation.Transitions;
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
	card.showLevel = card.showSlider = false;
	card.data = deckIndex;
	card.type = building.type;
	addChild(card);
	
	populationBar = new HealthBar(0, 0, building.capacity);
	populationBar.atlas = "gui";
	populationBar.layoutData = new AnchorLayoutData(NaN, padding, 0, padding * 4);
	populationBar.height = 38 * appModel.scale;
	addChild(populationBar);
	
	/*populationIndicator = new BitmapFontTextRenderer();
	populationIndicator.textFormat = new BitmapFontTextFormat(Assets.getFont(), 36, 0xFFFFFF, "center")
	populationIndicator.width = populationBar.width;
	populationIndicator.touchable = false;
	populationIndicator.x = place.x - populationIndicator.width * 0.5 + 24 ;
	populationIndicator.y = place.y + 24;
	fieldView.guiTextsContainer.addChild(populationIndicator);*/
	
	var populationIcon:ImageLoader = new ImageLoader();
	populationIcon.touchable = false;
	populationIcon.scale = appModel.scale * 2;
	populationIcon.source = Assets.getTexture("population-0", "gui");
	populationIcon.layoutData = new AnchorLayoutData(NaN, NaN, -padding, padding);
	addChild(populationIcon);
}

/*public function get ready():Boolean
{
	if( building == null )
		return false;
	return building._population >= building.capacity; 
}*/

public function updateData():void
{
	Starling.juggler.tween(populationBar, 0.5, {value:building._population, transition:Transitions.EASE_OUT_ELASTIC});
	card.touchable = building._population >= building.capacity;
	card.alpha = touchable ? 1 : 0.5;
	//populationBar.value = building._population;
}

override public function dispose():void
{
	Starling.juggler.removeTweens(populationBar);
	super.dispose();
}


}
}