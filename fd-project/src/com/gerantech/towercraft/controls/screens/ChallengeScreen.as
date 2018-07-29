package com.gerantech.towercraft.controls.screens 
{
import com.gerantech.towercraft.controls.buttons.ExchangeButton;
import com.gerantech.towercraft.controls.items.EventWinnerItemRenderer;
import com.gerantech.towercraft.controls.texts.CountdownLabel;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gt.towers.socials.Challenge;
import feathers.controls.List;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayoutData;
import feathers.layout.TiledRowsLayout;
import starling.events.Event;

/**
* ...
* @author Mansour Djawadi ...
*/
public class ChallengeScreen extends BaseFomalScreen
{
public var challenge:Challenge;
private var countdownDisplay:CountdownLabel;

public function ChallengeScreen() {	super();  }
override protected function initialize():void
{
	title = loc("challenge_title_0");
	super.initialize();
	
	var messageDisplay:RTLLabel = new RTLLabel(loc("challenge_message_0"), 1, null, null, true, null, 0.8);
	messageDisplay.layoutData = new AnchorLayoutData(200, 32, NaN, 32);
	addChild(messageDisplay);
	
	var state:int = challenge.getState(timeManager.now);
	
	var rewardsLayout:TiledRowsLayout = new TiledRowsLayout();
	rewardsLayout.useSquareTiles = false;
	rewardsLayout.requestedColumnCount = 2;
	rewardsLayout.padding = rewardsLayout.gap = 24;
	rewardsLayout.typicalItemWidth = stageWidth * 0.5 - rewardsLayout.gap * 3;
	
	var rewardsData:ListCollection = new ListCollection();
	rewardsData.addItem({index:appModel.isLTR?1:2,	book:challenge.rewards.get(appModel.isLTR?1:2)});
	rewardsData.addItem({index:appModel.isLTR?2:1,	book:challenge.rewards.get(appModel.isLTR?2:1)});
	rewardsData.addItem({index:appModel.isLTR?3:4,	book:challenge.rewards.get(appModel.isLTR?3:4)});
	rewardsData.addItem({index:appModel.isLTR?4:3,	book:challenge.rewards.get(appModel.isLTR?4:3)});
	rewardsData.addItem(appModel.isLTR ?			{index:10, book:challenge.rewards.get(10)} : {});
	if( !appModel.isLTR )
		rewardsData.addItem({index:10, book:challenge.rewards.get(10)});
	
	var rewardsList:List = new List();
	rewardsList.touchable = false;
	rewardsList.layout = rewardsLayout;
	rewardsList.layoutData = new AnchorLayoutData(500, 0, NaN, 0);
	rewardsList.dataProvider = rewardsData;
	rewardsList.itemRendererFactory = function () : IListItemRenderer { return new EventWinnerItemRenderer(); }
	addChild(rewardsList);
	

	var descriptionDisplay:RTLLabel = new RTLLabel(loc("challenge_description"), 1, null, null, true, null, 0.8);
	descriptionDisplay.layoutData = new AnchorLayoutData(1100, 32, NaN, 32);
	addChild(descriptionDisplay);
	
	countdownDisplay = new CountdownLabel();
	countdownDisplay.localString = "challenge_time_remaining";
	countdownDisplay.height = 100;
	countdownDisplay.layoutData = new AnchorLayoutData(1250, 150, NaN, 120);
	countdownDisplay.time = challenge.startAt - timeManager.now;
	addChild(countdownDisplay);
	
	var buttonDisplay:ExchangeButton = new ExchangeButton();
	buttonDisplay.count = challenge.requirements.values()[0];
	buttonDisplay.type = challenge.requirements.keys()[0];
	buttonDisplay.addEventListener(Event.TRIGGERED, buttonDisplay_triggeredHandler);
	buttonDisplay.width = 320;
	buttonDisplay.layoutData = new AnchorLayoutData(1350, NaN, NaN, NaN, 0);
	addChild(buttonDisplay);
	
	timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
}

protected function timeManager_changeHandler(e:Event):void 
{
	countdownDisplay.time = challenge.startAt - timeManager.now;
}

protected function buttonDisplay_triggeredHandler(e:Event):void 
{
}
}
}