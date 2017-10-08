package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.ResourcPalette;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.overlays.OpenChestOverlay;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;

import flash.geom.Rectangle;

import dragonBones.starling.StarlingArmatureDisplay;

import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;

public class ChestsDetailsPopup extends SimplePopup
{
private var item:ExchangeItem;
private var chestArmature:StarlingArmatureDisplay;

public function ChestsDetailsPopup(item:ExchangeItem)
{
	this.item = item;
	super();
}

override protected function initialize():void
{
	super.initialize();
	transitionIn.sourceBound = transitionOut.destinationBound = new Rectangle(stage.stageWidth*0.05, stage.stageHeight*0.35, stage.stageWidth*0.9, stage.stageHeight*0.3);
	transitionOut.sourceBound = transitionIn.destinationBound = new Rectangle(stage.stageWidth*0.05, stage.stageHeight*0.30, stage.stageWidth*0.9, stage.stageHeight*0.4);
	rejustLayoutByTransitionData();
	
	var titleDisplay:ShadowLabel = new ShadowLabel(loc("popup_keys_title"),1, 0, "center", null, false, null, 1.1);
	titleDisplay.layoutData = new AnchorLayoutData(padding*4, NaN, NaN, NaN, 0);
	addChild(titleDisplay);
	
	var insideBG:ImageLoader = new ImageLoader();
	insideBG.alpha = 0.8;
	insideBG.scale9Grid = new Rectangle(2,2,1,1);
	insideBG.maintainAspectRatio = false;
	insideBG.source = Assets.getTexture("popup-inside-background-skin", "skin");
	insideBG.layoutData = new AnchorLayoutData(padding*7, padding, padding*1.2, padding);
	addChild(insideBG);
	
	var cardsPalette:ResourcPalette = new ResourcPalette(Assets.getTexture("cards", "gui"), "x "+ExchangeType.getRewardCount(item.outcome));
	cardsPalette.width = transitionIn.destinationBound.width * 0.38;
	cardsPalette.layoutData = new AnchorLayoutData(padding*8, NaN, NaN, padding*2.4);
	addChild(cardsPalette);
	
	var softsPalette:ResourcPalette = new ResourcPalette(Assets.getTexture("res-"+ResourceType.CURRENCY_SOFT, "gui"), "321", 0xFFFF99);
	softsPalette.width = transitionIn.destinationBound.width * 0.38;
	softsPalette.layoutData = new AnchorLayoutData(padding*8, padding*2, NaN);
	addChild(softsPalette);
	
	var messageDisplay:RTLLabel = new RTLLabel(loc("popup_keys_title"), 0, "center", null, false, null, 0.9);
	messageDisplay.layoutData = new AnchorLayoutData(NaN, padding, padding*7, padding);
	addChild(messageDisplay);

	var batton:CustomButton = new CustomButton();
	batton.label = String(ExchangeType.getCategory(item.type)==ExchangeType.CHEST_CATE_110_BATTLES?ExchangeType.getKeyRequierement(item.outcome):ExchangeType.getHardRequierement(item.outcome));
	batton.icon = Assets.getTexture("res-"+(ExchangeType.getCategory(item.type)==ExchangeType.CHEST_CATE_110_BATTLES?ResourceType.KEY:ResourceType.CURRENCY_HARD), "gui");
	batton.width = 320 * appModel.scale;
	batton.height = 120 * appModel.scale;
	batton.layoutData = new AnchorLayoutData(NaN, NaN, padding*2, NaN, 0);
	addChild(batton);
}

override protected function transitionInCompleted():void
{
	super.transitionInCompleted();

	OpenChestOverlay.createFactory();
	chestArmature = OpenChestOverlay.factory.buildArmatureDisplay("chest-"+item.outcome);
	chestArmature.scale = appModel.scale * 4;
	//chestArmature.alignPivot("left", "top")
	chestArmature.animation.gotoAndPlayByTime("fall",0, 1);
	addChild(chestArmature);		
	chestArmature.x = (transitionIn.destinationBound.width) * 0.5 * appModel.scale * 3;
	chestArmature.y = -padding * 2;
}


}
}