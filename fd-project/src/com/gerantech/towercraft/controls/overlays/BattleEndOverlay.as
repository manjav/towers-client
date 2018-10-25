package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.groups.Devider;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.headers.BattleHeader;
import com.gerantech.towercraft.controls.items.BattleOutcomeRewardItemRenderer;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.managers.VideoAdsManager;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.BattleData;
import com.gt.towers.constants.ResourceType;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.SFSArray;

import flash.utils.setTimeout;

import dragonBones.objects.DragonBonesData;
import dragonBones.starling.StarlingArmatureDisplay;
import dragonBones.starling.StarlingFactory;

import feathers.controls.AutoSizeMode;
import feathers.controls.LayoutGroup;
import feathers.controls.List;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Quad;
import starling.events.Event;

public class BattleEndOverlay extends BaseOverlay
{
public static var animFactory: StarlingFactory;
public static var dragonBonesData:DragonBonesData;
private static var factoryCreateCallback:Function;

public var score:int;
private var rewards:ISFSArray;
public var tutorialMode:Boolean;
private var armatureDisplay:StarlingArmatureDisplay ;
private var initialingCompleted:Boolean;
private var showAdOffer:Boolean;
private var padding:int;

public function BattleEndOverlay(score:int, rewards:ISFSArray, tutorialMode:Boolean=false)
{
	super();
	this.score = score;
	this.rewards = rewards;
	this.tutorialMode = tutorialMode;
}

override protected function initialize():void
{
	closeOnStage = false;
	autoSizeMode = AutoSizeMode.STAGE;
	super.initialize();
	layout = new AnchorLayout();
	padding = 48;
	
	var battleData:BattleData = appModel.battleFieldView.battleData;
	if( battleData.battleField.map.isOperation )
	{
		var message:String = appModel.battleFieldView.battleData.isLeft ? "operation_canceled" : (score>0?"operation_win_label":"operation_lose_label");
		var messageLabel:ShadowLabel = new ShadowLabel(loc(message), 1, 0, null, null, false, null, 2.2);
		messageLabel.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -padding * 7); 
		addChild(messageLabel);
	}
	else
	{
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
	}
	
	var hlayout:HorizontalLayout = new HorizontalLayout();
	hlayout.horizontalAlign = HorizontalAlign.CENTER;
	hlayout.verticalAlign = VerticalAlign.MIDDLE;
	hlayout.paddingBottom = 42;
	hlayout.gap = 48;
	
	if( rewards.size() > 0 )
	{
		var rewardsList:List = new List();
		rewardsList.backgroundSkin = new Quad(1, 1, 0);
		rewardsList.backgroundSkin.alpha = 0.6;
		rewardsList.height = 400;
		rewardsList.layout = hlayout;
		rewardsList.layoutData = new AnchorLayoutData(NaN, 0, NaN, 0, NaN, 160);
		rewardsList.itemRendererFactory = function ():IListItemRenderer { return new BattleOutcomeRewardItemRenderer();	}
		rewardsList.dataProvider = getRewardsCollection();
		addChild(rewardsList);
	}
	
	var buttons:LayoutGroup = new LayoutGroup();
	buttons.layout = hlayout;
	buttons.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, (rewards.size()>0?480:220));
	addChild(buttons);
	
	var hasRetry:Boolean = appModel.battleFieldView.battleData.battleField.map.isOperation && player.getLastOperation() > 3 && !appModel.battleFieldView.battleData.isLeft;
	
	var closeBatton:CustomButton = new CustomButton();
	closeBatton.width = 300;
	closeBatton.height = 120;
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
		retryButton.width = 300;
		retryButton.height = 120;
		showAdOffer = !keyExists && score < 3 && VideoAdsManager.instance.getAdByType(VideoAdsManager.TYPE_OPERATIONS).available;
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

override protected function defaultOverlayFactory():DisplayObject
{
	var overlay:Devider = new Devider(appModel.battleFieldView.battleData.isLeft?0x000000:(score>0?0x000099:0x990000));
	overlay.alpha = 0.4;
	overlay.width = stage.width;
	overlay.height = stage.height * 3;
	return overlay;
}
private function get keyExists():Boolean
{
	for( var i:int = 0; i < rewards.size(); i++ ) 
		if( rewards.getSFSObject(i).getInt("t") == ResourceType.KEY )
			return true;
	return false;
}

private function getRewardsCollection():ListCollection
{
	var rw:Array = SFSArray(rewards).toArray();
	var ret:ListCollection = new ListCollection();
	for ( var i:int=0; i<rw.length; i++ )
		if( rw[i].t == ResourceType.R2_POINT || rw[i].t == ResourceType.KEY || rw[i].t == ResourceType.R3_CURRENCY_SOFT )
			ret.addItem( rw[i] );
	
	return ret;
}

private function buttons_triggeredHandler(event:Event):void
{
	if( CustomButton(event.currentTarget).name == "retry" )
	{
		dispatchEventWith(FeathersEventType.CLEAR, false, showAdOffer);
		setTimeout(close, 10);
	}
	else
		close();
}
}
}