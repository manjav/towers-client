package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.buttons.ExchangeButton;
import com.gerantech.towercraft.controls.groups.ColorGroup;
import com.gerantech.towercraft.controls.items.BuildingFeatureItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gt.towers.buildings.Building;
import com.gt.towers.constants.BuildingFeatureType;
import com.gt.towers.constants.CardTypes;
import com.gt.towers.constants.ResourceType;

import flash.geom.Rectangle;

import feathers.controls.List;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayoutData;

import starling.core.Starling;
import starling.events.Event;

public class CardDetailsPopup extends SimplePopup
{
public var buildingType:int;
private var building:Building;

override protected function initialize():void
{
	transitionIn = new TransitionData();
	transitionOut = new TransitionData();
	transitionIn.destinationBound = transitionOut.sourceBound = new Rectangle(stage.stageWidth*0.02, stage.stageHeight*( CardTypes.get_category(buildingType)==500?0.10:0.16), stage.stageWidth*0.96, stage.stageHeight*(CardTypes.get_category(buildingType)==500?0.70:0.58));
	transitionOut.destinationBound = transitionIn.sourceBound = new Rectangle(transitionOut.sourceBound.x, transitionOut.sourceBound.y*1.1, transitionOut.sourceBound.width, transitionOut.sourceBound.height*0.8);
	transitionOut.destinationAlpha = 0.1;

	super.initialize();
	
	if( player.buildings.exists(buildingType) )
		building = player.buildings.get(buildingType);
	else
		building = new Building(game, null, 0, buildingType, 1 );
	
	var buildingIcon:BuildingCard = new BuildingCard();
	buildingIcon.layoutData = new AnchorLayoutData(padding, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN);
	buildingIcon.width = padding * 10;
	addChild(buildingIcon);
	buildingIcon.type = buildingType;
}

override protected function transitionInCompleted():void
{
	super.transitionInCompleted();
		
	var titleDisplay:RTLLabel = new RTLLabel(loc("card_title_"+building.type), 1, null, null, false, null, 1, null, "bold");
	titleDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?padding:padding*12, NaN, appModel.isLTR?padding*12:padding);
	addChild(titleDisplay);
	
	
	var rarityColors:Array = [0xFFFFFF, 0x00eeff, 0xffcc00];
	var rarityPalette:ColorGroup = new ColorGroup(loc("card_rarity_"+building.rarity), rarityColors[building.rarity]);
	rarityPalette.width = padding * 8.4;
	rarityPalette.layoutData = new AnchorLayoutData(padding*3.7, appModel.isLTR?NaN:padding*12, NaN, appModel.isLTR?padding*12:NaN);
	addChild(rarityPalette);
	
	var categoryPalette:ColorGroup = new ColorGroup(loc("card_category_"+building.category));
	categoryPalette.width = padding * 8.4;
	categoryPalette.layoutData = new AnchorLayoutData(padding*3.7, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding);
	addChild(categoryPalette);
	
	var messageDisplay:RTLLabel = new RTLLabel(loc("card_message_"+building.type), 1, "justify", null, true, null, 0.7);
	messageDisplay.layoutData = new AnchorLayoutData(padding*7, appModel.isLTR?padding:padding*12, NaN, appModel.isLTR?padding*12:padding);
	addChild(messageDisplay);
	
	var featureList:List = new List();
	featureList.layoutData = new AnchorLayoutData(padding*16, padding*2, NaN, padding*2);
	featureList.horizontalScrollPolicy = featureList.verticalScrollPolicy = ScrollPolicy.OFF;
	featureList.itemRendererFactory = function ():IListItemRenderer { return new BuildingFeatureItemRenderer(building); }
	featureList.dataProvider = new ListCollection(BuildingFeatureType.getRelatedTo(buildingType)._list);
	addChild(featureList);
	
	var upgradeButton:ExchangeButton = new ExchangeButton();
	upgradeButton.disableSelectDispatching = player.buildings.exists(buildingType);
	upgradeButton.count = building.get_upgradeCost();
	upgradeButton.type = ResourceType.CURRENCY_SOFT;
	upgradeButton.layoutData = new AnchorLayoutData(NaN, NaN, padding, NaN, -padding*5);
	upgradeButton.height = 110*appModel.scale;
	upgradeButton.addEventListener(Event.TRIGGERED, upgradeButton_triggeredHandler);
	upgradeButton.addEventListener(Event.SELECT, upgradeButton_selectHandler);
	upgradeButton.isEnabled = player.has(building.get_upgradeRequirements());
	addChild(upgradeButton);

	var upgradeLabel:RTLLabel = new RTLLabel(loc("upgrade_label"), 1, "center", null, true, null, 0.7);
	upgradeLabel.layoutData = new AnchorLayoutData(NaN, NaN, padding+upgradeButton.height, NaN, -padding*5);
	upgradeLabel.alpha = 0;
	Starling.juggler.tween(upgradeLabel, 0.1, {alpha:1, delay:0.3});
	addChild(upgradeLabel);
	
	var usingButton:CustomButton = new CustomButton();
	usingButton.style = "neutral";
	usingButton.label = loc("usage_label");
	usingButton.isEnabled = player.buildings.exists(buildingType);
	usingButton.height = 110*appModel.scale;
	usingButton.addEventListener(Event.TRIGGERED, usingButton_triggeredHandler);
	usingButton.layoutData = new AnchorLayoutData(NaN, NaN, padding, NaN, padding*5);
	addChild(usingButton);		
}

override protected function transitionOutStarted():void
{
	removeChildren(2);
	super.transitionOutStarted();
}
private function upgradeButton_selectHandler(event:Event):void
{
	appModel.navigator.addLog(loc("popup_upgrade_building_error", [loc("card_title_"+buildingType)]));
}

private function usingButton_triggeredHandler():void
{
	dispatchEventWith(Event.SELECT, false, building);
	close();
}
private function upgradeButton_triggeredHandler():void
{
	dispatchEventWith(Event.UPDATE, false, building);
	close();
}
}
}