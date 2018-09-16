package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.groups.RewardsPalette;
import com.gerantech.towercraft.controls.sliders.BuildingSlider;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.others.Quest;
import feathers.controls.ImageLoader;
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
static public var HEIGHT:int = 380;
static private var PADDING:int = 16;
public var quest:Quest;
private var timeoutId:uint;
private var titleDisplay:ShadowLabel;
private var messageDisplay:RTLLabel;
private var sliderDisplay:BuildingSlider;
private var rewardPalette:RewardsPalette;
private var actionButton:CustomButton;
private var actionLayout:AnchorLayoutData;
private var iconDisplay:ImageLoader;

public function QuestItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
	this.height = HEIGHT; 
	layout = new AnchorLayout();	
	
	var mySkin:Image = new Image(appModel.theme.itemRendererUpSkinTexture);
	mySkin.scale9Grid = MainTheme.ITEM_RENDERER_SCALE9_GRID;
	backgroundSkin = mySkin;
	
	iconDisplay = new ImageLoader();
	iconDisplay.layoutData = new AnchorLayoutData(NaN, 0);
	iconDisplay.width = 180;
	iconDisplay.height = 120;
	addChild(iconDisplay);
	
	var messageBG:ImageLoader = new ImageLoader();
	messageBG.source = Assets.getTexture("theme/popup-inside-background-skin", "gui")
	messageBG.alpha = 0.3;
	messageBG.scale9Grid = new Rectangle(4, 4, 2, 2);
	messageBG.layoutData = new AnchorLayoutData(120, appModel.isLTR?300:PADDING, 110, appModel.isLTR?PADDING:300);
	addChild(messageBG);
	
	rewardPalette = new RewardsPalette(loc("quest_rewards"), 1);
	rewardPalette.width = 265;
	rewardPalette.layoutData = new AnchorLayoutData(92, appModel.isLTR?PADDING:NaN, 110, appModel.isLTR?NaN:PADDING);
	addChild(rewardPalette);
	
	titleDisplay = new ShadowLabel("", 1, 0, null, null, false, null, 0.9);
	titleDisplay.layoutData = new AnchorLayoutData(PADDING, PADDING * 12, NaN, PADDING);
	addChild(titleDisplay);
	
	messageDisplay = new RTLLabel("", 0, "center", null, true, null, 0.7);
	messageDisplay.touchable = false;
	messageDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?316:PADDING*2, NaN, appModel.isLTR?PADDING*2:316, NaN, 0);
	addChild(messageDisplay);
	
	sliderDisplay = new BuildingSlider();
	sliderDisplay.height = 50;
	sliderDisplay.showUpgradeIcon = false;
	sliderDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?300:PADDING, PADDING*2, appModel.isLTR?PADDING:300);
	addChild(sliderDisplay);
	
	actionLayout = new AnchorLayoutData(NaN, appModel.isLTR?PADDING:NaN, PADDING, appModel.isLTR?NaN:PADDING);;
	actionButton = new CustomButton();
	actionButton.height = 84;
	actionButton.layoutData = actionLayout;
	actionButton.addEventListener(Event.TRIGGERED, actionButton_triggeredHandler);
	addChild(actionButton);
}

override protected function commitData():void
{
	super.commitData();
	removeTweens();
	if( _data == null || _owner == null )
		return;
	
	this.height = HEIGHT;
	alpha = 1;
	quest = _data as Quest; trace(index, quest.id);
	
	var iconStr:String = QuestItemRenderer.getIcon(quest.type);
	iconDisplay.source = Assets.getTexture(iconStr, "gui");
	iconDisplay.height = iconStr.substr(0,9) == "home/tab-" ? 160 : 120;
	iconDisplay.y = iconStr.substr(0,9) == "home/tab-" ? -PADDING * 3 : -PADDING;
	
	if( quest.type == Quest.TYPE_7_CARD_COLLECT || quest.type == Quest.TYPE_8_CARD_UPGRADE )
		titleDisplay.text = loc("quest_title_" + quest.type, [loc("building_title_" + quest.key), quest.target]);
	else if( quest.type == Quest.TYPE_6_CHALLENGES )
		titleDisplay.text = loc("quest_title_" + quest.type, [quest.target, loc("challenge_title_" + (quest.key - 1221))]);
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

	actionLayout.right = appModel.isLTR?PADDING:(quest.passed()?PADDING:NaN);
	actionLayout.left =  appModel.isLTR?(quest.passed()?PADDING:NaN):PADDING;
	actionButton.label = loc(quest.passed() ? "collect_label" : "go_label");
	actionButton.style = quest.passed() ? CustomButton.STYLE_NEUTRAL : CustomButton.STYLE_NORMAL;
	actionButton.width = quest.passed() ? NaN : 265;
	Image(backgroundSkin).texture = quest.passed() ? appModel.theme.itemRendererSelectedSkinTexture : appModel.theme.itemRendererUpSkinTexture;
	if( quest.passed() )
		punchAction();

	if( player.getTutorStep() == PrefsTypes.T_161_QUEST_FOCUS && quest.type == Quest.TYPE_3_BATTLES && quest.nextStep == 1 )
	{
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_162_QUEST_SHOWN);
		actionButton.showTutorArrow(false);
	}
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
	Starling.juggler.tween(this, 0.8, {delay:0.5, alpha:-0.5, height:20, transition:Transitions.EASE_IN, onComplete:removeMe});
}

private function removeMe():void 
{
	owner.dispatchEventWith(Event.UPDATE, false, this);
}

private function removeTweens():void 
{
	clearTimeout(timeoutId);
	Starling.juggler.removeTweens(actionButton);
	Starling.juggler.removeTweens(actionLayout);
}

static private function getIcon(type:int) : String
{
	switch( type )
	{
		case 0: return "res-1000";
		case 1: return "arena-" + Math.min(8, AppModel.instance.game.player.get_arena(0) + 1);
		case 2:
		case 3:
		case 4: return "home/tab-2";
		case 5: return "home/tab-3";
		case 6: return "home/tab-4";
		case 7:
		case 8: return "home/tab-1";
		case 9: return "books/56";
	}
	return "home/tasks";
}
}
}