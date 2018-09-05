package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.groups.RewardsPalette;
import com.gerantech.towercraft.controls.sliders.BuildingSlider;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gt.towers.others.Quest;
import feathers.controls.ImageLoader;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.display.Image;
import starling.events.Event;

public class QuestItemRenderer extends AbstractTouchableListItemRenderer
{
private var deleteButton:CustomButton;
private var titleDisplay:ShadowLabel;
private var messageDisplay:RTLLabel;
private var sliderDisplay:BuildingSlider;
private var rewardPalette:RewardsPalette;
private var quest:Quest;

public function QuestItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
	this.height = 380; 
	
	layout = new AnchorLayout();
	var padding:int = 16;
	
	var mySkin:Image = new Image(appModel.theme.itemRendererUpSkinTexture);
	mySkin.scale9Grid = MainTheme.ITEM_RENDERER_SCALE9_GRID;
	backgroundSkin = mySkin;
	
	titleDisplay = new ShadowLabel("", 1, 0, null, null, false, null, 0.9);
	titleDisplay.width = padding * 12;
	titleDisplay.layoutData = new AnchorLayoutData(padding, padding, NaN, padding);
	addChild(titleDisplay);
	
	var messageBG:ImageLoader = new ImageLoader();
	messageBG.source = Assets.getTexture("theme/popup-inside-background-skin", "gui")
	messageBG.alpha = 0.3;
	messageBG.scale9Grid = new Rectangle(4, 4, 2, 2);
	messageBG.layoutData = new AnchorLayoutData(86, appModel.isLTR?300:padding, 86, appModel.isLTR?padding:300);
	addChild(messageBG);
	
	rewardPalette = new RewardsPalette(loc("quest_rewards"), 1);
	rewardPalette.width = 260;
	rewardPalette.layoutData = new AnchorLayoutData(86, appModel.isLTR?padding:NaN, 86, appModel.isLTR?NaN:padding);
	addChild(rewardPalette);
	
	messageDisplay = new RTLLabel("", 0, "center", null, true, null, 0.7);
	messageDisplay.touchable = false;
	messageDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?316:padding*2, NaN, appModel.isLTR?padding*2:316, NaN, 0);
	addChild(messageDisplay);
	
	sliderDisplay = new BuildingSlider();
	sliderDisplay.height = 48;
	sliderDisplay.showUpgradeIcon = false;
	sliderDisplay.layoutData = new AnchorLayoutData(NaN, padding, padding, padding);
	addChild(sliderDisplay);	
	
	/*deleteButton = new CustomButton();
	deleteButton.label = "x";
	deleteButton.width = deleteButton.height = 100;
	deleteButton.layoutData = new AnchorLayoutData( 0, appModel.isLTR ? 0 : NaN, NaN, appModel.isLTR ? NaN : 0);
	deleteButton.addEventListener(FeathersEventType.CREATION_COMPLETE, function () : void { deleteButton.backgroundSkin.alpha = 0; });
	deleteButton.addEventListener(Event.TRIGGERED, buttons_eventHandler);
	addChild(deleteButton);*/
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null || _owner == null )
		return;
		
	quest = _data as Quest;
	titleDisplay.text = loc("quest_title_" + quest.type, [quest.target]);;
	messageDisplay.text = loc("quest_message_" + quest.type);
	sliderDisplay.maximum = quest.target;
	sliderDisplay.value = Math.round( quest.value );
	sliderDisplay.addChild(sliderDisplay.labelDisplay);	
	sliderDisplay.isEnabled = true;
	rewardPalette.setRewards(quest.rewards);
}

private function buttons_eventHandler(event:Event):void
{
	/*if( event.currentTarget == banButton )
		_owner.dispatchEventWith(Event.SELECT, false, message);
	else if( event.currentTarget == deleteButton )
		_owner.dispatchEventWith(Event.CANCEL, false, message);
	else if( event.currentTarget == offenderButton )
		_owner.dispatchEventWith(Event.READY, false, message);
	else if( event.currentTarget == reporterButton )
		_owner.dispatchEventWith(Event.OPEN, false, message);*/
}
}
}