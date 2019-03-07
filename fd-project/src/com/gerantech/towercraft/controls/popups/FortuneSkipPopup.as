package com.gerantech.towercraft.controls.popups 
{
	import com.gerantech.towercraft.controls.buttons.ExchangeButton;
	import com.gerantech.towercraft.controls.texts.CountdownLabel;
	import com.gerantech.towercraft.utils.StrUtils;
	import com.gt.towers.constants.ResourceType;
	import com.gt.towers.exchanges.ExchangeItem;
	import com.gt.towers.exchanges.Exchanger;
	import feathers.layout.AnchorLayoutData;
	import flash.geom.Rectangle;
	import starling.events.Event;
/**
* ...
* @author Mansour Djawadi
*/
public class FortuneSkipPopup extends ConfirmPopup 
{
private var item:ExchangeItem;
private var countdownDisplay:com.gerantech.towercraft.controls.texts.CountdownLabel;

public function FortuneSkipPopup(item:ExchangeItem) 
{
	this.item = item;
	super(loc("exchange_free_skip"), null, null);
}
override protected function initialize():void
{
	super.initialize();
	transitionIn.sourceBound = transitionOut.destinationBound = new Rectangle(stage.stageWidth * 0.15, stage.stageHeight * 0.30, stage.stageWidth * 0.7, stage.stageHeight * 0.40);
	transitionOut.sourceBound = transitionIn.destinationBound = new Rectangle(stage.stageWidth * 0.15, stage.stageHeight * 0.35, stage.stageWidth * 0.7, stage.stageHeight * 0.30);
	rejustLayoutByTransitionData();
	
	countdownDisplay = new CountdownLabel();
	countdownDisplay.width = padding * 10;
	countdownDisplay.height = padding * 3.5;
	countdownDisplay.layoutData = new AnchorLayoutData (NaN, NaN, NaN, NaN, 0, 0);
	countdownDisplay.time = item.expiredAt - timeManager.now;
	addChild(countdownDisplay);

	buttonContainer.removeChild(acceptButton);
	acceptButton = new ExchangeButton();
	acceptButton.style = "neutral";
	ExchangeButton(acceptButton).count = exchanger.getRequierement(item, timeManager.now).get(ResourceType.R4_CURRENCY_HARD);
	ExchangeButton(acceptButton).type = ResourceType.R4_CURRENCY_HARD;
	acceptButton.addEventListener(Event.TRIGGERED, acceptButton_triggeredHandler);
	buttonContainer.addChild(acceptButton);
}
}
}