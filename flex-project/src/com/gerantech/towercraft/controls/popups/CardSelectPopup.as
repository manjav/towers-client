package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gt.towers.buildings.Building;

import feathers.layout.AnchorLayoutData;

import starling.core.Starling;
import starling.events.Event;

public class CardSelectPopup extends SimplePopup
{
public var buildingType:int;
private var building:Building;

override protected function transitionInCompleted():void
{
	super.transitionInCompleted();
	
	building = player.buildings.get(buildingType);

	var buildingIcon:BuildingCard = new BuildingCard();
	buildingIcon.showSlider = false;
	buildingIcon.type = buildingType;
	buildingIcon.level = building.get_level();
	buildingIcon.layoutData = new AnchorLayoutData(padding*0.5, padding*0.5, NaN, padding*0.5);
	addChild(buildingIcon);
	
	var detailsButton:CustomButton = new CustomButton();
	detailsButton.label = "اطلاعات";
	detailsButton.style = building.upgradable() ? "normal" : "neutral";
	detailsButton.layoutData = new AnchorLayoutData(padding*10.5, NaN, NaN, NaN, 0);
	detailsButton.addEventListener(Event.TRIGGERED, detailsButton_triggeredHandler);
	//detailsButton.isEnabled = player.has(building.get_upgradeRequirements());
	detailsButton.alpha = 0;
	Starling.juggler.tween(detailsButton, 0.1, {alpha:1});
	addChild(detailsButton);
	
	if( data > -1 )
		return;
	
	var usingButton:CustomButton = new CustomButton();
	//usingButton.style = "danger";
	usingButton.label = "استفاده";
	usingButton.layoutData = new AnchorLayoutData(NaN, NaN, padding*0.5, NaN, 0);
	usingButton.addEventListener(Event.TRIGGERED, usingButton_triggeredHandler);
	addChild(usingButton);		
	usingButton.alpha = 0;
	Starling.juggler.tween(usingButton, 0.1, {delay:0.05, alpha:1});
}

protected function usingButton_triggeredHandler(event:Event):void
{
	dispatchEventWith(Event.SELECT, false, building);
	close();
}		
protected function detailsButton_triggeredHandler(event:Event):void
{
	dispatchEventWith(Event.OPEN, false, building);
	close();
}

override protected function transitionOutStarted():void
{
	removeChildren(2);
	super.transitionOutStarted();
}
override public function close(dispose:Boolean=true):void
{
	super.close(dispose);
}
}
}