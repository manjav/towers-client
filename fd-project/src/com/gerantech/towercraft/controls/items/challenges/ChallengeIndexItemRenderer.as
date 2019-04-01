package com.gerantech.towercraft.controls.items.challenges 
{
import com.gerantech.towercraft.controls.buttons.IconButton;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.items.AbstractListItemRenderer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.tooltips.BaseTooltip;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.socials.Challenge;
import feathers.controls.ButtonState;
import feathers.controls.ImageLoader;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.core.Starling;
import starling.events.Event;

/**
* ...
* @author Mansour Djawadi
*/
public class ChallengeIndexItemRenderer extends AbstractListItemRenderer
{
static public var ARENA:int;
static public var IN_HOME:Boolean;
static private const BG_SCALE_GRID:Rectangle = new Rectangle(23, 22, 2, 2);
static private const COLORS:Array = [0x30e465, 0xffa400, 0xff4200, 0xe720ff];

private var chIndex:int;
private var locked:Boolean;
private var backgroundImage:SimpleLayoutButton;
private var backgroundLayoutData:AnchorLayoutData;
private var iconDisplay:ImageLoader;
private var challenge:Challenge;
private var titleDisplay:RTLLabel;
private var messageDisplay:RTLLabel;
private var state:int;
private var bannerDisplay:ImageLoader;
private var infoButton:IconButton;
private var rankButton:IconButton;
public function ChallengeIndexItemRenderer() { super(); }
override protected function initialize() : void
{
	height = 410;
	super.initialize();
	layout = new AnchorLayout();
}

override protected function commitData() : void 
{
	super.commitData();
	challenge = _data as Challenge;
	state = challenge.getState(timeManager.now);
	chIndex = IN_HOME ? player.selectedChallengeIndex : index;
	locked = Challenge.getUnlockAt(challenge.type) > ARENA;trace(index, challenge.unlockAt, ARENA)
	
	backgroundFactory();
	iconFactory();
	bannerFactory();
	infoFactory();
	rankingFactory();
	titleFactory();
	messageFactory();
	
	alpha = 0;
	Starling.juggler.tween(this, 0.25, {delay:Math.log(index + 1) * 0.2, alpha:1});
}

private function infoFactory() : void
{
	if( locked || infoButton != null )
		return;
	infoButton = new IconButton(Assets.getTexture("events/info"), 0.6, Assets.getTexture("events/badge"));
	infoButton.width = 96;
	infoButton.height = 103;
	infoButton.layoutData = new AnchorLayoutData(-24, appModel.isLTR? -24 : NaN, NaN, appModel.isLTR? NaN : -24);
	infoButton.addEventListener(Event.TRIGGERED, infoButton_triggeredHandler);
	addChild(infoButton);
}

private function rankingFactory() : void
{
	if( challenge.type != Challenge.TYPE_2_RANKING || locked || rankButton != null )
		return;
	rankButton = new IconButton(Assets.getTexture("home/ranking"), 0.6, Assets.getTexture("events/badge"));
	rankButton.width = 96;
	rankButton.height = 103;
	rankButton.layoutData = new AnchorLayoutData(-24, appModel.isLTR? 100 : NaN, NaN, appModel.isLTR? NaN : 100);
	addChild(rankButton);
}

private function bannerFactory() : void
{
	if( bannerDisplay == null )
	{
		bannerDisplay = new ImageLoader();
		bannerDisplay.touchable = false;
		bannerDisplay.maintainAspectRatio = false;
		bannerDisplay.layoutData = new AnchorLayoutData(150, 11, 60, 11);
		addChild(bannerDisplay);
	}
	bannerDisplay.source = Assets.getTexture(locked ? "events/banner-locked" : "events/banner-default", "gui");
}

private function backgroundFactory() : void
{
	if( backgroundImage == null )
	{
		backgroundLayoutData = new AnchorLayoutData(0, 0, 0, 0);
		backgroundImage = new SimpleLayoutButton();
		backgroundImage.layoutData = backgroundLayoutData;
		backgroundImage.backgroundSkin = new ImageLoader();
		backgroundImage.addEventListener(Event.TRIGGERED, backgroundImage_triggerdHandler);
		backgroundImage.addEventListener(FeathersEventType.STATE_CHANGE, backgroundImage_stateChangeHandler);
		ImageLoader(backgroundImage.backgroundSkin).scale9Grid = BG_SCALE_GRID;
		addChild(backgroundImage);
	}
	ImageLoader(backgroundImage.backgroundSkin).source = Assets.getTexture("events/index-bg-" + chIndex + "-up", "gui");
}

private function iconFactory() : void
{
	if( iconDisplay == null )
	{
		iconDisplay = new ImageLoader();
		iconDisplay.touchable = false;
		iconDisplay.layoutData = new AnchorLayoutData(10, appModel.isLTR ? NaN : 10, appModel.isLTR ? 10 : NaN);
		iconDisplay.width = iconDisplay.height = 150;
		addChild(iconDisplay);
	}
	
	if( locked )
		iconDisplay.source = Assets.getTexture("events/lock", "gui");
	else
		iconDisplay.source = Assets.getTexture("events/type-" + challenge.mode, "gui");
}

private function titleFactory() : void
{
	if( titleDisplay == null )
	{
		titleDisplay = new RTLLabel(null, COLORS[chIndex], null, null, false, null, 0.9);
		titleDisplay.touchable = false;
		titleDisplay.layoutData = new AnchorLayoutData(12, appModel.isLTR ? NaN : 160, appModel.isLTR ? 120 : NaN);
		addChild(titleDisplay);
	}
	titleDisplay.text = loc("challenge_title_" + challenge.mode);
}

private function messageFactory() : void
{
	if( messageDisplay == null )
	{
		messageDisplay = new RTLLabel(null, 1, null, null, false, null, 0.7);
		messageDisplay.touchable = false;
		messageDisplay.layoutData = new AnchorLayoutData(76, appModel.isLTR ? NaN : 160, appModel.isLTR ? 160 : NaN);
		addChild(messageDisplay);
	}
	messageDisplay.text = loc("challenge_message_" + challenge.mode);
}

protected function backgroundImage_stateChangeHandler(event:Event) : void
{
	backgroundLayoutData.top = backgroundLayoutData.right = backgroundLayoutData.left = backgroundLayoutData.bottom = event.data == ButtonState.DOWN ? 4 : 0;
}
protected function backgroundImage_triggerdHandler(event:Event) : void
{
	if( locked )
	{
		appModel.navigator.addLog(loc("arena_unlocked_at", [loc("arena_text") + " " + loc("num_" + (Challenge.getUnlockAt(challenge.type) + 1))]));
		return;
	}
	_owner.dispatchEventWith(Event.TRIGGERED, false, chIndex);
}

private function infoButton_triggeredHandler(event:Event) : void
{
	appModel.navigator.addChild(new BaseTooltip(loc("challenge_info_" + challenge.type), infoButton.getBounds(stage)));
}
}
}