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
import flash.utils.clearTimeout;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class QuestItemRenderer extends AbstractTouchableListItemRenderer
{
public var quest:Quest;
private var titleDisplay:ShadowLabel;
private var messageDisplay:RTLLabel;
private var sliderDisplay:BuildingSlider;
private var rewardPalette:RewardsPalette;
private var actionButton:CustomButton;
static public var HEIGHT:int = 380;
static private var PADDING:int = 16;
private var actionLayout:feathers.layout.AnchorLayoutData;
private var timeoutId:uint;

public function QuestItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
	this.height = HEIGHT; 
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
	
	actionLayout = new AnchorLayoutData(NaN, appModel.isLTR?PADDING:NaN, PADDING, appModel.isLTR?NaN:PADDING);;
	actionButton = new CustomButton();
	actionButton.width = 265;
	actionButton.height = 84;
	actionButton.layoutData = actionLayout;
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
	removeTweens();
	if( _data == null || _owner == null )
		return;
	
	quest = _data as Quest;
	
	if( quest.type == Quest.TYPE_7_CARD_COLLECT || quest.type == Quest.TYPE_8_CARD_UPGRADE )
		titleDisplay.text = loc("quest_title_" + quest.type, [loc("building_title_" + (quest.key % 100)), quest.target]);
	else if( quest.type == Quest.TYPE_9_BOOK_OPEN )
		titleDisplay.text = loc("quest_title_" + quest.type, [quest.target, loc("exchange_title_" + quest.key)]);
	else
		titleDisplay.text = loc("quest_title_" + quest.type, [quest.target]);
	
	messageDisplay.text = loc("quest_message_" + quest.type);
	rewardPalette.setRewards(quest.rewards);
	sliderDisplay.visible = !quest.passed();
	if( sliderDisplay.visible )
	{
		sliderDisplay.maximum = quest.target;
		sliderDisplay.value = Math.round( quest.current );
		sliderDisplay.addChild(sliderDisplay.labelDisplay);	
		sliderDisplay.isEnabled = true;
	}

	actionLayout.right = appModel.isLTR?PADDING:(quest.passed()?PADDING:NaN)
	actionLayout.left =  appModel.isLTR?(quest.passed()?PADDING:NaN):PADDING;
	actionButton.label = loc(quest.passed() ? "collect_label" : "go_label");
	actionButton.style = quest.passed() ? CustomButton.STYLE_NEUTRAL : CustomButton.STYLE_NORMAL;
	Image(backgroundSkin).texture = quest.passed() ? appModel.theme.itemRendererSelectedSkinTexture : appModel.theme.itemRendererUpSkinTexture;
	if( quest.passed() )
		punchAction();
}

private function punchAction():void 
{
	actionLayout.right = actionLayout.left = -PADDING;
	actionLayout.bottom = -PADDING * 3;
	actionButton.height = 84 + PADDING * 6;
	Starling.juggler.tween(actionButton, 0.4, {height:84,		transition:Transitions.EASE_OUT_BACK});
	Starling.juggler.tween(actionLayout, 0.4, {bottom:PADDING,	transition:Transitions.EASE_OUT_BACK});
	Starling.juggler.tween(actionLayout, 0.5, {right:PADDING, left:PADDING, transition:Transitions.EASE_OUT_BACK, onComplete:tweenCompleted});
	function tweenCompleted() : void
	{
		timeoutId = setTimeout(punchAction, 1000 + Math.random() * 500);
	}
}

protected function actionButton_triggeredHandler(e:Event):void 
{
	owner.dispatchEventWith(Event.SELECT, false, this);
}

public function hide():void 
{
	removeTweens();
	Starling.juggler.tween(this, 0.8, {delay:0.5, alpha:-1, height:0, transition:Transitions.EASE_IN, onComplete:owner.dataProvider.removeItemAt, onCompleteArgs:[index]});
}

private function removeTweens():void 
{
	clearTimeout(timeoutId);
	Starling.juggler.removeTweens(actionButton);
	Starling.juggler.removeTweens(actionLayout);
}
}
}