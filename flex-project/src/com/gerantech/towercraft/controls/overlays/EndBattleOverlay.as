package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.headers.BattleHeader;
import com.gerantech.towercraft.controls.items.BattleOutcomeRewardItemRenderer;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.vo.BattleData;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.controls.AutoSizeMode;
import feathers.controls.LayoutGroup;
import feathers.controls.List;
import feathers.controls.renderers.IListItemRenderer;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import starling.core.Starling;
import starling.display.Quad;
import starling.events.Event;

public class EndBattleOverlay extends EndOverlay
{
public function EndBattleOverlay(playerIndex:int, rewards:ISFSArray, tutorialMode:Boolean=false)
{
	super(playerIndex, rewards, tutorialMode);
}
override protected function initialize():void
{
	super.initialize();
	
	// opponent elements
	var reward:ISFSObject = rewards.getSFSObject(0);
	var opponentHeader:BattleHeader = new BattleHeader(reward.getText("name"), reward.getInt("id")==player.id);
	opponentHeader.layoutData = new AnchorLayoutData(padding * 7, 0, NaN, 0);
	addChild(opponentHeader);
	opponentHeader.showWinnerLabel(reward.getInt("score")>0);
	opponentHeader.addScoreImages(reward.getInt("score"));
	
	// player elements
	reward = rewards.getSFSObject(1);
	if( !reward.containsKey("name") )
		reward.putText("name", battleData.opponent.getVariable("name").getStringValue());
	var playerHeader:BattleHeader = new BattleHeader(rewards.getSFSObject(1).getText("name"), reward.getInt("id")==player.id);
	playerHeader.layoutData = new AnchorLayoutData(padding * 17, 0, NaN, 0);
	addChild(playerHeader);
	playerHeader.showWinnerLabel(reward.getInt("score")>0);
	playerHeader.addScoreImages(reward.getInt("score"));

	var hlayout:HorizontalLayout = new HorizontalLayout();
	hlayout.horizontalAlign = HorizontalAlign.CENTER;
	hlayout.verticalAlign = VerticalAlign.MIDDLE;
	hlayout.paddingBottom = 42 * appModel.scale;
	hlayout.gap = 48 * appModel.scale;
	
	if( rewards.size() > 0 )
	{
		var rewardsList:List = new List();
		rewardsList.backgroundSkin = new Quad(1, 1, 0);
		rewardsList.backgroundSkin.alpha = 0.6;
		rewardsList.height = 400*appModel.scale;
		rewardsList.layout = hlayout;
		rewardsList.layoutData = new AnchorLayoutData(NaN, 0, NaN, 0, NaN, 340 * appModel.scale);
		rewardsList.itemRendererFactory = function ():IListItemRenderer { return new BattleOutcomeRewardItemRenderer();	}
		rewardsList.dataProvider = getRewardsCollection(playerIndex);
		addChild(rewardsList);
	}
	
	var closeBatton:CustomButton = new CustomButton();
	closeBatton.width = 300 * appModel.scale;
	closeBatton.height = 120 * appModel.scale;
	closeBatton.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, (rewards.size()>0?680:380)*appModel.scale);
	closeBatton.style = "danger";
	closeBatton.name = "close";
	closeBatton.label = loc("close_button");
	closeBatton.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
	Starling.juggler.tween(closeBatton, 0.5, {delay:0.9, alpha:1});
	closeBatton.alpha = 0;
	addChild(closeBatton);
}
}
}