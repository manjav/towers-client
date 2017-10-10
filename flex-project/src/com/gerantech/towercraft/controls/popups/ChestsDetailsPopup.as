package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.ResourcPalette;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.overlays.OpenChestOverlay;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;
import com.gt.towers.utils.maps.IntIntMap;

import flash.geom.Rectangle;

import dragonBones.starling.StarlingArmatureDisplay;

import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;

import starling.events.Event;

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
	
	var titleDisplay:ShadowLabel = new ShadowLabel(loc("exchange_title_"+item.outcome),1, 0, "center", null, false, null, 1.1);
	titleDisplay.layoutData = new AnchorLayoutData(padding*4, NaN, NaN, NaN, 0);
	addChild(titleDisplay);
	
	var insideBG:ImageLoader = new ImageLoader();
	insideBG.alpha = 0.8;
	insideBG.scale9Grid = new Rectangle(2, 2, 1, 1);
	insideBG.maintainAspectRatio = false;
	insideBG.source = Assets.getTexture("popup-inside-background-skin", "skin");
	insideBG.layoutData = new AnchorLayoutData(padding*7, padding, padding*1.2, padding);
	addChild(insideBG);
	
	var cardsPalette:ResourcPalette = new ResourcPalette(Assets.getTexture("cards", "gui"), int(ExchangeType.getNumTotalCards(item.outcome)*0.9)+" - "+int(ExchangeType.getNumTotalCards(item.outcome)*1.1));
	cardsPalette.width = transitionIn.destinationBound.width * 0.4;
	cardsPalette.layoutData = new AnchorLayoutData(padding*8, NaN, NaN, padding*2.4);
	addChild(cardsPalette);
	
	var softsPalette:ResourcPalette = new ResourcPalette(Assets.getTexture("res-"+ResourceType.CURRENCY_SOFT, "gui"), int(ExchangeType.getNumSofts(item.outcome)*0.9)+" - "+int(ExchangeType.getNumSofts(item.outcome)*1.1), 0xFFFF99);
	softsPalette.width = transitionIn.destinationBound.width * 0.4;
	softsPalette.layoutData = new AnchorLayoutData(padding*8, padding*2, NaN);
	addChild(softsPalette);
	
	var messageDisplay:RTLLabel = new RTLLabel(loc("popup_chest_message_"+item.category, [StrUtils.toTimeFormat(ExchangeType.getCooldown(item.outcome))]), 0, "center", null, false, null, 0.9);
	messageDisplay.layoutData = new AnchorLayoutData(NaN, padding, padding*7, padding);
	addChild(messageDisplay);

	var req:IntIntMap = new IntIntMap();
	if( item.category == ExchangeType.CHEST_CATE_110_BATTLES )
		req.set(ResourceType.KEY, ExchangeType.getKeyRequierement(item.outcome));
	else
		req.set(ResourceType.CURRENCY_HARD, ExchangeType.getHardRequierement(item.outcome));

	var button:CustomButton = new CustomButton();
	button.label = req.get(req.keys()[0]).toString();
	button.icon = Assets.getTexture("res-"+req.keys()[0], "gui");
	button.isEnabled = player.has(req);
	button.width = 300 * appModel.scale;
	button.height = 110 * appModel.scale;
	button.addEventListener(Event.TRIGGERED, batton_triggeredHandler);
	button.layoutData = new AnchorLayoutData(NaN, NaN, padding*2, NaN, 0);
	addChild(button);
}

override protected function transitionInCompleted():void
{
	super.transitionInCompleted();

	OpenChestOverlay.createFactory();
	chestArmature = OpenChestOverlay.factory.buildArmatureDisplay("chest-"+item.outcome);
	chestArmature.scale = appModel.scale * 4;
	//chestArmature.alignPivot("left", "top")
	chestArmature.animation.gotoAndPlayByTime("fall",0, 1);
	addChildAt(chestArmature, 2);		
	chestArmature.x = (transitionIn.destinationBound.width) * 0.5 * appModel.scale * 3;
	chestArmature.y = -padding * 2;
}

private function batton_triggeredHandler(event:Event):void
{
	dispatchEventWith(Event.SELECT, false, item);
	close();
}
}
}