package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.groups.IconGroup;
import com.gerantech.towercraft.controls.buttons.ExchangeButton;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;

import flash.geom.Rectangle;

import dragonBones.starling.StarlingArmatureDisplay;

import feathers.controls.ImageLoader;
import feathers.controls.text.BitmapFontTextRenderer;
import feathers.layout.AnchorLayoutData;
import feathers.text.BitmapFontTextFormat;

import starling.events.Event;

public class ChestsDetailsPopup extends SimplePopup
{
private var item:ExchangeItem;
private var chestArmature:StarlingArmatureDisplay;
private var buttonDisplay:ExchangeButton;
private var timeDisplay:BitmapFontTextRenderer;

private var messageDisplay:RTLLabel;

public function ChestsDetailsPopup(item:ExchangeItem)
{
	this.item = item;
	super();
}

override protected function initialize():void
{
	super.initialize();
	transitionIn.sourceBound = transitionOut.destinationBound = new Rectangle(stage.stageWidth*0.05, stage.stageHeight*0.30, stage.stageWidth*0.9, stage.stageHeight*0.4);
	transitionOut.sourceBound = transitionIn.destinationBound = new Rectangle(stage.stageWidth*0.05, stage.stageHeight*0.25, stage.stageWidth*0.9, stage.stageHeight*0.5);
	rejustLayoutByTransitionData();
	
	var insideBG:ImageLoader = new ImageLoader();
	insideBG.alpha = 0.8;
	insideBG.scale9Grid = new Rectangle(2, 2, 1, 1);
	insideBG.maintainAspectRatio = false;
	insideBG.source = Assets.getTexture("theme/popup-inside-background-skin", "gui");
	insideBG.layoutData = new AnchorLayoutData(padding*6, padding, padding*1.2, padding);
	addChild(insideBG);
	
	var titleDisplay:RTLLabel = new RTLLabel(loc("exchange_title_"+item.outcome), 0, "center", null, false, null, 1.3);
	titleDisplay.layoutData = new AnchorLayoutData(padding*7.6, NaN, NaN, NaN, 0);
	addChild(titleDisplay);
	
	var downBG:ImageLoader = new ImageLoader();
	downBG.alpha = 0.8;
	downBG.color = item.getState(timeManager.now) == ExchangeItem.CHEST_STATE_BUSY ? 0xAA9999 : 0x9999AA
	downBG.scale9Grid = new Rectangle(2, 2, 1, 1);
	downBG.maintainAspectRatio = false;
	downBG.source = Assets.getTexture("theme/popup-inside-background-skin", "gui");
	downBG.layoutData = new AnchorLayoutData(NaN, padding*1.3, padding*1.5, padding*1.3);
	downBG.height = padding * 4.4;
	addChild(downBG);
	
	var cardsPalette:IconGroup = new IconGroup(Assets.getTexture("cards", "gui"), int(ExchangeType.getNumTotalCards(item.outcome)*0.9)+" - "+int(ExchangeType.getNumTotalCards(item.outcome)*1.1));
	cardsPalette.width = transitionIn.destinationBound.width * 0.4;
	cardsPalette.layoutData = new AnchorLayoutData(NaN, NaN, padding*10, padding*2.4);
	addChild(cardsPalette);
	
	var softsPalette:IconGroup = new IconGroup(Assets.getTexture("res-"+ResourceType.CURRENCY_SOFT, "gui"), int(ExchangeType.getNumSofts(item.outcome)*0.9)+" - "+int(ExchangeType.getNumSofts(item.outcome)*1.1), 0xFFFF99);
	softsPalette.width = transitionIn.destinationBound.width * 0.4;
	softsPalette.layoutData = new AnchorLayoutData(NaN, padding*2, padding*10);
	addChild(softsPalette);

	var message:String = item.getState(timeManager.now) == ExchangeItem.CHEST_STATE_BUSY ? loc("popup_chest_message_skip", [exchanger.timeToHard(item.expiredAt-timeManager.now)]) : loc("popup_chest_message_"+item.category, [StrUtils.toTimeFormat(ExchangeType.getCooldown(item.outcome))]);
	messageDisplay = new RTLLabel(message, 0, "center", null, false, null, 0.9);
	messageDisplay.layoutData = new AnchorLayoutData(NaN, padding, padding*7, padding);
	addChild(messageDisplay);
	
	buttonDisplay = new ExchangeButton();
	buttonDisplay.disableSelectDispatching = true;
	buttonDisplay.width = 300 * appModel.scale;
	buttonDisplay.height = 110 * appModel.scale;
	buttonDisplay.addEventListener(Event.SELECT, batton_selectHandler);
	buttonDisplay.addEventListener(Event.TRIGGERED, batton_triggeredHandler);
	buttonDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding*2, NaN, 0);
	
	if( item.category == ExchangeType.CHEST_CATE_110_BATTLES )
	{
		if( item.getState(timeManager.now) == ExchangeItem.CHEST_STATE_BUSY )
		{
			buttonDisplay.style = "neutral";
			buttonDisplay.width = 240 * appModel.scale;
			buttonDisplay.layoutData = new AnchorLayoutData(NaN, padding*2, padding*2, NaN);
			timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
			updateButton(ResourceType.CURRENCY_HARD, exchanger.timeToHard(item.expiredAt-timeManager.now));
			updateCounter();
		}
		else if( item.getState(timeManager.now) == ExchangeItem.CHEST_STATE_WAIT )
		{
			updateButton(ResourceType.KEY, ExchangeType.getKeyRequierement(item.outcome));
		}
	}
	else
	{
		updateButton(ResourceType.CURRENCY_HARD, ExchangeType.getHardRequierement(item.outcome));
	}
	addChild(buttonDisplay);
}

override protected function transitionInCompleted():void
{
	super.transitionInCompleted();
	
	OpenBookOverlay.createFactory();
	chestArmature = OpenBookOverlay.factory.buildArmatureDisplay("book-"+item.outcome);
	chestArmature.scale = appModel.scale * 2;
	chestArmature.animation.gotoAndPlayByTime("fall-closed", 0, 1);
	addChildAt(chestArmature, 3);		
	chestArmature.x = transitionIn.destinationBound.width * 0.5;
	chestArmature.y = padding * 0.5
}

private function timeManager_changeHandler(event:Event):void
{
	updateButton(ResourceType.CURRENCY_HARD, exchanger.timeToHard(item.expiredAt-timeManager.now));
	updateCounter();
}

private function updateButton(type:int, count:int):void
{
	buttonDisplay.count = count;
	buttonDisplay.type = type;
if( item.category == ExchangeType.CHEST_CATE_120_OFFERS || item.getState(timeManager.now) == ExchangeItem.CHEST_STATE_BUSY )
		buttonDisplay.isEnabled = player.resources.get(type) >= count;	
	else 
		buttonDisplay.isEnabled = exchanger.readyToStartOpening(item.type, timeManager.now)
}
private function updateCounter():void
{
	if( item.getState(timeManager.now) != ExchangeItem.CHEST_STATE_BUSY )
		return;
	if( timeDisplay == null )
	{
		timeDisplay = new BitmapFontTextRenderer();//imageDisplay.width, imageDisplay.width/2, "");
		timeDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 54*appModel.scale, 0xFFFFFF, "center")
		timeDisplay.layoutData = new AnchorLayoutData(NaN, 340*appModel.scale, padding*3, padding*2);
		addChild(timeDisplay);	
	}
	var t:uint = uint(item.expiredAt - timeManager.now);
	timeDisplay.text = "< "+StrUtils.toTimeFormat(t);
	buttonDisplay.count = exchanger.timeToHard(t);
	messageDisplay.text = loc("popup_chest_message_skip", [exchanger.timeToHard(t)])
}

private function batton_selectHandler(event:Event):void
{
	if( item.category == ExchangeType.CHEST_CATE_110_BATTLES && item.getState(timeManager.now) != ExchangeItem.CHEST_STATE_BUSY )
		appModel.navigator.addLog(loc("popup_chest_error_exists"));
	else
		appModel.navigator.addLog(loc("popup_chest_error_resource"));
}
private function batton_triggeredHandler(event:Event):void
{
	dispatchEventWith(Event.SELECT, false, item);
	close();
}

override public function dispose():void
{
	buttonDisplay.removeEventListener(Event.TRIGGERED, batton_triggeredHandler);
	timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
	super.dispose();
}


}
}