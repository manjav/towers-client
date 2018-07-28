package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.buttons.ExchangeButton;
import com.gerantech.towercraft.controls.groups.PrizePalette;
import com.gerantech.towercraft.controls.texts.CountdownLabel;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.constants.ResourceType;
import feathers.controls.ImageLoader;
import feathers.controls.List;
import feathers.layout.AnchorLayoutData;
import starling.events.Event;
import flash.geom.Rectangle;

public class CampaignDetailsPopup extends SimplePopup
{
private var countdownDisplay:CountdownLabel;
public var buildingType:int;
public function CampaignDetailsPopup(){ }
override protected function initialize():void
{
	// create transition in data
	super.initialize();
	transitionIn.sourceBound = transitionOut.destinationBound = new Rectangle(stageWidth * 0.05, stageHeight * 0.20, stageWidth * 0.9, stageHeight * 0.6);
	transitionOut.sourceBound = transitionIn.destinationBound = new Rectangle(stageWidth * 0.05, stageHeight * 0.25, stageWidth * 0.9, stageHeight * 0.5);
	rejustLayoutByTransitionData();
	
	var titleDisplay:ShadowLabel = new ShadowLabel(loc("campaign_title_0"), 1, 0, "center");
	titleDisplay.layoutData = new AnchorLayoutData(padding, NaN, NaN, NaN, 0);
	addChild(titleDisplay);
	
	var messageDisplay:RTLLabel = new RTLLabel(loc("campaign_message_0"), 1, null, null, true, null, 0.8);
	messageDisplay.layoutData = new AnchorLayoutData(padding * 4, padding, NaN, padding);
	addChild(messageDisplay);
	
}

private function buttonDisplay_triggeredHandler(e:Event):void 
{
	
}

override protected function transitionInCompleted():void
{
	super.transitionInCompleted();
	
	var prizeW:int = width * 0.5 + padding;
	var topPrizePanel:PrizePalette = new PrizePalette(loc("campaign_top_prize"), 0xFFFFFF, 56);
	//topPrizePanel.height = padding * 22;
	topPrizePanel.layoutData = new AnchorLayoutData(padding * 12, padding, NaN, prizeW);
	addChild(topPrizePanel);
	
	var guaranteedPrizePanel:PrizePalette = new PrizePalette(loc("campaign_guaranteed_prize"), 0xFFFFFF, 52);
	//guaranteedPrizePanel.height = padding * 22;
	guaranteedPrizePanel.layoutData = new AnchorLayoutData(padding * 12, prizeW, NaN, padding);
	addChild(guaranteedPrizePanel);
	
	countdownDisplay = new CountdownLabel();
	countdownDisplay.localString = "campaign_time_remaining";
	countdownDisplay.height = padding * 3;
	countdownDisplay.layoutData = new AnchorLayoutData(NaN, padding * 5, padding * 5, padding * 4);
	addChild(countdownDisplay);
	
	var buttonDisplay:ExchangeButton = new ExchangeButton();
	buttonDisplay.count = 10;
	buttonDisplay.type = ResourceType.CURRENCY_HARD;
	buttonDisplay.addEventListener(Event.TRIGGERED, buttonDisplay_triggeredHandler);
	buttonDisplay.width = padding * 18;
	buttonDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding, NaN, 0);
	addChild(buttonDisplay);

}
}
}
