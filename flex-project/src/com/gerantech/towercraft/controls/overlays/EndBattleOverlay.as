package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.headers.BattleHeader;
import com.gerantech.towercraft.controls.items.BattleOutcomeRewardItemRenderer;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.vo.BattleData;
import com.smartfoxserver.v2.entities.data.ISFSArray;

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
public function EndBattleOverlay(score:int, rewards:ISFSArray, tutorialMode:Boolean=false)
{
	super(score, rewards, tutorialMode);
}
override protected function initialize():void
{
	closeOnStage = false;
	autoSizeMode = AutoSizeMode.STAGE;
	super.initialize();
	layout = new AnchorLayout();
	padding = 48 * appModel.scale;
	
	var battleData:BattleData = appModel.battleFieldView.battleData;
	
	// opponent elements
	var opponentHeader:BattleHeader = new BattleHeader(battleData.opponent.getVariable("name").getStringValue(), false);
	opponentHeader.width = padding * 16;
	opponentHeader.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -padding * 12);
	addChild(opponentHeader);

	var opponentLabel:ShadowLabel = new ShadowLabel(loc(score>0?"loser_label":"winner_label"), 1, 0, null, null, false, null, 1.4);
	opponentLabel.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -padding * 3); 
	opponentHeader.addChild(opponentLabel);

	// player elements
	var playerHeader:BattleHeader = new BattleHeader(battleData.me.getVariable("name").getStringValue(), true);
	playerHeader.width = padding * 16;
	playerHeader.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -padding * 3);
	addChild(playerHeader);

	var playerLabel:ShadowLabel = new ShadowLabel(loc(score<=0?"loser_label":"winner_label"), 1, 0, null, null, false, null, 1.4);
	playerLabel.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -padding * 3); 
	playerHeader.addChild(playerLabel);

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
		rewardsList.layoutData = new AnchorLayoutData(NaN, 0, NaN, 0, NaN, 160*appModel.scale);
		rewardsList.itemRendererFactory = function ():IListItemRenderer { return new BattleOutcomeRewardItemRenderer();	}
		rewardsList.dataProvider = getRewardsCollection();
		addChild(rewardsList);
	}
	
	var buttons:LayoutGroup = new LayoutGroup();
	buttons.layout = hlayout;
	buttons.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, (rewards.size()>0?480:220)*appModel.scale);
	addChild(buttons);
	
		var closeBatton:CustomButton = new CustomButton();
	closeBatton.width = 300 * appModel.scale;
	closeBatton.height = 120 * appModel.scale;
	closeBatton.style = "danger";
	closeBatton.name = "close";
	closeBatton.label = loc("close_button");
	closeBatton.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
	Starling.juggler.tween(closeBatton, 0.5, {delay:0.9, alpha:1});
	closeBatton.alpha = 0;
	buttons.addChild(closeBatton);
}
}
}