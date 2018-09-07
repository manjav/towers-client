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
private var actionButton:CustomButton;
static private var PADDING:int = 16;

public function QuestItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
	this.height = 380; 
	layout = new AnchorLayout();	
	
	var mySkin:Image = new Image(appModel.theme.itemRendererUpSkinTexture);
	mySkin.scale9Grid = MainTheme.ITEM_RENDERER_SCALE9_GRID;
	backgroundSkin = mySkin;
	
	titleDisplay = new ShadowLabel("", 1, 0, null, null, false, null, 0.9);
	titleDisplay.width = PADDING * 12;
	titleDisplay.layoutData = new AnchorLayoutData(PADDING, PADDING, NaN, PADDING);
	addChild(titleDisplay);
	
	var messageBG:ImageLoader = new ImageLoader();
	messageBG.source = Assets.getTexture("theme/popup-inside-background-skin", "gui")
	messageBG.alpha = 0.3;
	messageBG.scale9Grid = new Rectangle(4, 4, 2, 2);
	messageBG.layoutData = new AnchorLayoutData(86, appModel.isLTR?300:PADDING, 110, appModel.isLTR?PADDING:300);
	addChild(messageBG);
	
	rewardPalette = new RewardsPalette(loc("quest_rewards"), 1);
	rewardPalette.width = 265;
	rewardPalette.layoutData = new AnchorLayoutData(86, appModel.isLTR?PADDING:NaN, 110, appModel.isLTR?NaN:PADDING);
	addChild(rewardPalette);
	
	messageDisplay = new RTLLabel("", 0, "center", null, true, null, 0.7);
	messageDisplay.touchable = false;
	messageDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?316:PADDING*2, NaN, appModel.isLTR?PADDING*2:316, NaN, -PADDING);
	addChild(messageDisplay);
	
	sliderDisplay = new BuildingSlider();
	sliderDisplay.height = 50;
	sliderDisplay.showUpgradeIcon = false;
	sliderDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?300:PADDING, PADDING*2, appModel.isLTR?PADDING:300);
	addChild(sliderDisplay);
	
	actionButton = new CustomButton();
	actionButton.width = 265;
	actionButton.height = 84;
	actionButton.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?PADDING:NaN, PADDING, appModel.isLTR?NaN:PADDING);
	actionButton.addEventListener(Event.TRIGGERED, actionButton_triggeredHandler);
	addChild(actionButton);	

	
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
	
	quest = _data as Quest;quest.value = 0
	if( quest.type == Quest.TYPE_CARD_COLLECT || quest.type == Quest.TYPE_CARD_UPGRADE )
		titleDisplay.text = loc("quest_title_" + quest.type, [loc("building_title_" + (quest.key%100)), quest.target]);
	else
		titleDisplay.text = loc("quest_title_" + quest.type, [quest.target]);
	
	messageDisplay.text = loc("quest_message_" + quest.type);
	sliderDisplay.maximum = quest.target;
	sliderDisplay.value = Math.round( quest.value );
	sliderDisplay.addChild(sliderDisplay.labelDisplay);	
	sliderDisplay.isEnabled = true;
	rewardPalette.setRewards(quest.rewards);
	
	
	//if( !quest.passed )
	//	actionButton.width = 265;
	AnchorLayoutData(actionButton.layoutData).right = appModel.isLTR?PADDING:(quest.passed()?PADDING:NaN)
	AnchorLayoutData(actionButton.layoutData).left =  appModel.isLTR?(quest.passed()?PADDING:NaN):PADDING;
	actionButton.label = loc(quest.passed() ? "collect_label" : "go_label");
}

protected function actionButton_triggeredHandler(e:Event):void 
{
	owner.dispatchEventWith(Event.SELECT, false, quest);
}
}
}