package com.gerantech.towercraft.controls.items 
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.buttons.Indicator;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.constants.ResourceType;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;
import starling.display.Sprite;

/**
* ...
* @author Mansour Djawadi
*/
public class CardItem extends BuildingCard 
{
private var changeDuration:Number;
private var newDisplay:ImageLoader;
public var effectsLayer:Sprite
public function CardItem() 
{
	super(false, true, true, false);
	touchable = false;
	effectsLayer = new Sprite();
	effectsLayer.x = width * 0.5;
	effectsLayer.y = height * 0.5;
}

public function _setData(type:int, level:int = 1, count:int = 1, changeDuration:Number = 0) : void
{
	this.changeDuration = changeDuration;
	super.setData(type, level, count);
}

override protected function defaultCoverDisplayFactory() : ImageLoader
{
	super.defaultCoverDisplayFactory();
	if( ResourceType.isBuilding(type) && player.buildings.exists(type) && player.buildings.get(type)._level == -1 )
	{
		if( newDisplay == null )
		{
			newDisplay = new ImageLoader();
			newDisplay.source = Assets.getTexture("cards/new-badge", "gui");
			newDisplay.layoutData = new AnchorLayoutData(-10, NaN, NaN, -10);
			newDisplay.width = 160;
			newDisplay.height = 160;
			addChild(newDisplay);
		}
		//appModel.game.loginData.buildingsLevel.set(type, 1);
		//setTimeout(appModel.sounds.addAndPlay, 100, "book-open-new");
	}
	return coverDisplay;
}

override protected function defaultSliderDisplayFactory() : Indicator
{
	super.defaultSliderDisplayFactory();
	if( sliderDisplay == null )
		return null;
	sliderDisplay.setData(sliderDisplay.minimum, player.getResource(type) - (changeDuration > 0 ? count : 0),	sliderDisplay.maximum);
	if( changeDuration > 0 )
		sliderDisplay.setData(sliderDisplay.minimum, player.getResource(type), sliderDisplay.maximum, changeDuration);
	return sliderDisplay;
}
}
}