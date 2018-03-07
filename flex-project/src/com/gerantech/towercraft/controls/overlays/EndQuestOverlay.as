package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.headers.BattleHeader;
import com.gerantech.towercraft.controls.items.BattleOutcomeRewardItemRenderer;
import com.gerantech.towercraft.managers.VideoAdsManager;
import com.gerantech.towercraft.models.Assets;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;

import feathers.controls.LayoutGroup;
import feathers.controls.List;
import feathers.controls.renderers.IListItemRenderer;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import starling.core.Starling;
import starling.display.Quad;
import starling.events.Event;
import feathers.data.ListCollection;

public class EndQuestOverlay extends EndOverlay
{
public function EndQuestOverlay(playerIndex:int, rewards:ISFSArray, tutorialMode:Boolean=false)
{
	super(playerIndex, rewards, tutorialMode);
}

override protected function initialize():void
{
	super.initialize();
	
	var score:int = rewards.getSFSObject(0).getInt("score");
	var message:String;
	if( playerIndex == -1 )
		message = "quest_end_label";
	else
		message = appModel.battleFieldView.battleData.isLeft ? "quest_canceled" : (score>0?"quest_win_label":"quest_lose_label");
	
	var opponentHeader:BattleHeader = new BattleHeader(loc(message), true);
	opponentHeader.layoutData = new AnchorLayoutData(550*appModel.scale, 0, NaN, 0);
	addChild(opponentHeader);
	
	opponentHeader.addScoreImages(score, player.quests.get(battleData.map.index)-1);
	
	var hlayout:HorizontalLayout = new HorizontalLayout();
	hlayout.horizontalAlign = HorizontalAlign.CENTER;
	hlayout.verticalAlign = VerticalAlign.MIDDLE;
	hlayout.paddingBottom = 42 * appModel.scale;
	hlayout.gap = 48 * appModel.scale;
	
	var rewardsCollection:ListCollection = getRewardsCollection(playerIndex);
	if( playerIndex > -1 && rewardsCollection.length > 0 )
	{
		var rewardsList:List = new List();
		rewardsList.backgroundSkin = new Quad(1, 1, 0);
		rewardsList.backgroundSkin.alpha = 0.6;
		rewardsList.height = 400 * appModel.scale;
		rewardsList.layout = hlayout;
		rewardsList.layoutData = new AnchorLayoutData(NaN, 0, NaN, 0, NaN, 160 * appModel.scale);
		rewardsList.itemRendererFactory = function ():IListItemRenderer { return new BattleOutcomeRewardItemRenderer();	}
		rewardsList.dataProvider = rewardsCollection;
		addChild(rewardsList);
	}
	
	var buttons:LayoutGroup = new LayoutGroup();
	buttons.layout = hlayout;
	buttons.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, (rewardsCollection.length>0 ? 480 : 220) * appModel.scale);
	addChild(buttons);
	
	var hasRetry:Boolean = playerIndex > -1 && appModel.battleFieldView.battleData.map.isQuest && player.get_questIndex() > 3 && !appModel.battleFieldView.battleData.isLeft;
	
	var closeBatton:CustomButton = new CustomButton();
	closeBatton.width = 300 * appModel.scale;
	closeBatton.height = 120 * appModel.scale;
	if( hasRetry )
		closeBatton.style = "danger";
	closeBatton.name = "close";
	closeBatton.label = loc("close_button");
	closeBatton.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
	Starling.juggler.tween(closeBatton, 0.5, {delay:0.9, alpha:1});
	closeBatton.alpha = 0;
	buttons.addChild(closeBatton);
	
	if( hasRetry )
	{
		var retryButton:CustomButton = new CustomButton();
		retryButton.name = "retry";
		retryButton.width = 300 * appModel.scale;
		retryButton.height = 120 * appModel.scale;
		showAdOffer = !keyExists && score < 3 && VideoAdsManager.instance.getAdByType(VideoAdsManager.TYPE_QUESTS).available;
		if( showAdOffer )
		{
			retryButton.label = "+   " + loc("retry_button");
			retryButton.icon = Assets.getTexture("extra-time", "gui");
		}
		else
		{
			retryButton.label = loc("retry_button");
		}
		retryButton.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
		Starling.juggler.tween(retryButton, 0.5, {delay:1, alpha:1});
		retryButton.alpha = 0;
		buttons.addChild(retryButton);
	}
		
	appModel.sounds.addAndPlaySound("outcome-"+(score>0?"victory":"defeat"));
	initialingCompleted = true;
}
}
}