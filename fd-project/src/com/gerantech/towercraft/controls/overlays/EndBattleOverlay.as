package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.headers.BattleHeader;
import com.gerantech.towercraft.controls.items.BattleOutcomeRewardItemRenderer;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;

import feathers.controls.List;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
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
	
	var reward_1:ISFSObject = rewards.getSFSObject(playerIndex==-1?1:1-playerIndex);
	var reward_2:ISFSObject = rewards.getSFSObject(playerIndex==-1?0:playerIndex);
	var isDraw:Boolean = reward_1.getInt("score") == reward_2.getInt("score") ;
	var pi:int = playerIndex == -1 ? 0 : playerIndex;
	
	if( isDraw || player.inFriendlyBattle )
	{
		var drawLabel:ShadowLabel = new ShadowLabel(loc(player.inFriendlyBattle?"buddy_battle":"draw_label"), 1, 0, null, null, false, null, 1.4);
		drawLabel.layoutData = new AnchorLayoutData(padding * 3.5, NaN, NaN, NaN, 0);
		addChild(drawLabel);
	}
	
	// header 1
	//if( !reward_1.containsKey("name") )
	//	reward_1.putText("name", battleData.opponent.getVariable("name").getStringValue());
	var header_1:BattleHeader = new BattleHeader(reward_1.getText("name"), reward_1.getInt("id")==player.id);
	header_1.layoutData = new AnchorLayoutData(padding * 11, 0, NaN, 0);
	addChild(header_1);
	header_1.addScoreImages(reward_1.getInt("score"));
	if( !isDraw )
		header_1.showWinnerLabel(reward_1.getInt("score")>reward_2.getInt("score"));
	
	
	// header 2
	var header_2:BattleHeader = new BattleHeader(reward_2.getText("name"), reward_2.getInt("id")==player.id);
	header_2.layoutData = new AnchorLayoutData(padding * 20, 0, NaN, 0);
	addChild(header_2);
	header_2.addScoreImages(reward_2.getInt("score"));
	if( !isDraw )
		header_2.showWinnerLabel(reward_2.getInt("score")>reward_1.getInt("score"));

	var hlayout:HorizontalLayout = new HorizontalLayout();
	hlayout.horizontalAlign = HorizontalAlign.CENTER;
	hlayout.verticalAlign = VerticalAlign.MIDDLE;
	hlayout.gap = padding;
	
	if( playerIndex > -1 && !isDraw )
	{
		var _rewards:ListCollection = getRewardsCollection(playerIndex);
		if( _rewards.length > 0 )
		{
			var rewardsList:List = new List();
			rewardsList.backgroundSkin = new Quad(1, 1, 0);
			rewardsList.backgroundSkin.alpha = 0.8;
			rewardsList.height = 280 * appModel.scale;
			rewardsList.layout = hlayout;
			rewardsList.layoutData = new AnchorLayoutData(padding * 25, 0, NaN, 0);
			rewardsList.itemRendererFactory = function ():IListItemRenderer { return new BattleOutcomeRewardItemRenderer();	}
			rewardsList.dataProvider = _rewards;
			addChild(rewardsList);
		}
	}
	
	var closeBatton:CustomButton = new CustomButton();
	closeBatton.width = 300 * appModel.scale;
	closeBatton.height = 120 * appModel.scale;
	closeBatton.layoutData = new AnchorLayoutData((rewardsList != null?31.4:27) * padding, NaN, NaN, NaN, 0);
	closeBatton.name = "close";
	closeBatton.label = loc("close_button");
	closeBatton.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
	Starling.juggler.tween(closeBatton, 0.5, {delay:0.9, alpha:1});
	closeBatton.alpha = 0;
	addChild(closeBatton);
}
}
}