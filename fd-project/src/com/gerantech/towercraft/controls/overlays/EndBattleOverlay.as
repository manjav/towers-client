package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.headers.BattleHeader;
import com.gerantech.towercraft.controls.items.BattleOutcomeRewardItemRenderer;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.vo.BattleData;
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
public function EndBattleOverlay(battleData:BattleData, playerIndex:int, rewards:ISFSArray, tutorialMode:Boolean = false)
{
	super(battleData, playerIndex, rewards, tutorialMode);
}
override protected function initialize():void
{
	super.initialize();
	
	var reward_1:ISFSObject = rewards.getSFSObject(playerIndex ==-1?1:1 - playerIndex);
	var reward_2:ISFSObject = rewards.getSFSObject(playerIndex ==-1?0:playerIndex);
	var isDraw:Boolean = reward_1.getInt("score") == reward_2.getInt("score") ;
	var pi:int = playerIndex == -1 ? 0 : playerIndex;
	
	if( isDraw || battleData.battleField.friendlyMode )
	{
		var drawLabel:ShadowLabel = new ShadowLabel(loc(battleData.battleField.friendlyMode?"buddy_battle":"draw_label"), 1, 0, null, null, false, null, 1.4);
		drawLabel.layoutData = new AnchorLayoutData(padding * 3.5, NaN, NaN, NaN, 0);
		addChild(drawLabel);
	}
	
	// axis
	var name:String = reward_1.getText("name");
	if( player.inTutorial() && player.tutorialMode == 1 )
		name = loc("trainer_label");
	var axisHeader:BattleHeader = new BattleHeader(name, reward_1.getInt("id") == player.id);
	axisHeader.layoutData = new AnchorLayoutData(padding * 11, 0, NaN, 0);
	addChild(axisHeader);
	axisHeader.addScoreImages(reward_1.getInt("score"));
	if( !isDraw )
		axisHeader.showWinnerLabel(reward_1.getInt("score") > reward_2.getInt("score"));
	
	// allise
	name = reward_2.getText("name") == "guest" ? loc("guest_label") : reward_2.getText("name");
	var alliseHeader:BattleHeader = new BattleHeader(name, reward_2.getInt("id") == player.id);
	alliseHeader.layoutData = new AnchorLayoutData(padding * 20, 0, NaN, 0);
	addChild(alliseHeader);
	alliseHeader.addScoreImages(reward_2.getInt("score"));
	if( !isDraw )
		alliseHeader.showWinnerLabel(reward_2.getInt("score") > reward_1.getInt("score"));

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
			rewardsList.height = 280;
			rewardsList.layout = hlayout;
			rewardsList.layoutData = new AnchorLayoutData(padding * 25, 0, NaN, 0);
			rewardsList.itemRendererFactory = function ():IListItemRenderer { return new BattleOutcomeRewardItemRenderer(battleData);	}
			rewardsList.dataProvider = _rewards;
			addChild(rewardsList);
		}
	}
	
	var closeBatton:CustomButton = new CustomButton();
	closeBatton.width = 300;
	closeBatton.height = 120;
	closeBatton.layoutData = new AnchorLayoutData((rewardsList != null?31.4:27) * padding, NaN, NaN, NaN, 0);
	closeBatton.name = "close";
	closeBatton.label = loc("popup_ok_label");
	closeBatton.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
	Starling.juggler.tween(closeBatton, 0.5, {delay:0.9, alpha:1});
	closeBatton.alpha = 0;
	addChild(closeBatton);
}
}
}