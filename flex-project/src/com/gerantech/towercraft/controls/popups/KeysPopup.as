package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.sliders.BuildingSlider;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.constants.ExchangeType;

import flash.geom.Rectangle;

import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;

import starling.core.Starling;

public class KeysPopup extends SimplePopup
{
private var slider:BuildingSlider;

override protected function initialize():void
{
	closeOnStage = true
	super.initialize();
	transitionIn.sourceBound = transitionOut.destinationBound = new Rectangle(stage.stageWidth*0.1, stage.stageHeight*0.35, stage.stageWidth*0.8, stage.stageHeight*0.2);
	transitionOut.sourceBound = transitionIn.destinationBound = new Rectangle(stage.stageWidth*0.1, stage.stageHeight*0.30, stage.stageWidth*0.8, stage.stageHeight*0.3);
	rejustLayoutByTransitionData();
	
	var iconDisplay:ImageLoader = new ImageLoader();
	iconDisplay.width = iconDisplay.height = padding*9;
	iconDisplay.source = Assets.getTexture("cards/1004", "gui");
	iconDisplay.layoutData = new AnchorLayoutData(padding*3, appModel.isLTR?0:NaN, NaN, appModel.isLTR?NaN:0);
	addChild(iconDisplay);
	
	var titleDisplay:ShadowLabel = new ShadowLabel(loc("popup_keys_title"),1, 0, "center", null, false, null, 1.1);
	titleDisplay.layoutData = new AnchorLayoutData(padding, NaN, NaN, NaN, 0);
	addChild(titleDisplay);
	
	var messageDisplay:RTLLabel = new RTLLabel(loc("popup_keys_message", [game.loginData.maxKeysPerDay]), 0xDDDDFF, "justify", null, true, null, 0.8);
	messageDisplay.layoutData = new AnchorLayoutData(padding*5, appModel.isLTR?iconDisplay.width:padding, NaN, appModel.isLTR?padding:iconDisplay.width);
	addChild(messageDisplay);
	
	slider = new BuildingSlider();
	slider.showUpgradeIcon = false;
	slider.width = transitionIn.destinationBound.width/2;
	slider.height = 52 * appModel.scale;
	slider.alpha = 0;
	slider.minimum = 0;
	slider.maximum = game.loginData.maxKeysPerDay;
	slider.layoutData = new AnchorLayoutData(NaN, NaN, 84 * appModel.scale, NaN, 0);
	addChild(slider);
}

override protected function transitionInCompleted():void
{
	Starling.juggler.tween(slider, 0.2, {alpha:1});
	slider.value = exchanger.items.get(ExchangeType.S_41_KEYS).numExchanges;
	super.transitionInCompleted();
}
}
}