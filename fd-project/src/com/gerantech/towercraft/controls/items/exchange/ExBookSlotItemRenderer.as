package com.gerantech.towercraft.controls.items.exchange
{
import com.gerantech.towercraft.controls.buttons.ExchangeButton;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.controls.texts.CountdownLabel;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;
import com.gt.towers.exchanges.Exchanger;
import com.gt.towers.utils.maps.IntIntMap;
import dragonBones.events.EventObject;
import dragonBones.starling.StarlingArmatureDisplay;
import dragonBones.starling.StarlingEvent;
import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.Image;
import starling.events.Event;

public class ExBookSlotItemRenderer extends ExBookBaseItemRenderer
{
private var state:int = -2;
private var countdownDisplay:CountdownLabel;
private var backgroundDisplay:ImageLoader;
private var emptyLabel:ShadowLabel;
private var waitGroup:LayoutGroup;
private var busyGroup:LayoutGroup;
private var readyLabel:ShadowLabel;
private var timeoutId:uint;
private var hardLabel:ShadowLabel;
//private var tutorialArrow:TutorialArrow;

public function ExBookSlotItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
	padding = 16 * appModel.scale;
	backgroundSkin = skin = null;
}
override protected function commitData():void
{
	if( index < 0 || _data == null )
		return;
	reset();
	
	exchange = exchanger.items.get(_data as int);
	if( exchange == null )
		return;
	state = exchange.getState(timeManager.now);
	backgroundFactory();
	super.commitData();
	emptyGroupFactory();
	waitGroupFactory();
	busyGroupFactory();
	readyGroupFactory();
	
	if( state == ExchangeItem.CHEST_STATE_BUSY )
	{
		timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
		timeManager_changeHandler(null);
	}
	appModel.navigator.addEventListener("itemAchieved", navigator_itemAchievedHandler);
	//tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorialManager_finishHandler);
}


/**
 * add, remove or update armature depends on type and state
 */
override protected function bookFactory() : StarlingArmatureDisplay
{
	clearTimeout(timeoutId);
	if( state != ExchangeItem.CHEST_STATE_EMPTY ) 
	{
		bookArmature = OpenBookOverlay.factory.buildArmatureDisplay( "book-" + exchange.outcome );
		bookArmature.scale = OpenBookOverlay.getBookScale(exchange.outcome) * appModel.scale * 0.68;
		bookArmature.x = width * 0.53;
		bookArmature.y = height * 0.65;
		if( state == ExchangeItem.CHEST_STATE_READY )
		{
			timeoutId = setTimeout(bookArmature.animation.gotoAndPlayByTime, Math.random() * 2000, "wait", 0, 100);
		}
		else
		{
			bookArmature.animation.gotoAndStopByProgress("appear", 1);
			bookArmature.animation.timeScale = 0;
		}
		addChild(bookArmature);
	}
	return bookArmature;
}

override protected function buttonFactory() : ExchangeButton
{
	/*if( state == ExchangeItem.CHEST_STATE_EMPTY ) 
		return null;

	buttonDisplay = new ExchangeButton();
	if( state == ExchangeItem.CHEST_STATE_WAIT )
	{
		buttonDisplay.style = "normal";
		buttonDisplay.count = ExchangeType.getKeyRequierement(exchange.outcome);
		buttonDisplay.type = ResourceType.KEY;
	}
	else if( state == ExchangeItem.CHEST_STATE_BUSY )
	{
		buttonDisplay.style = "neutral";
		buttonDisplay.count = 10;
		buttonDisplay.type = ResourceType.CURRENCY_HARD;
	}
	else if( state == ExchangeItem.CHEST_STATE_READY )
	{
		buttonDisplay.count = -1;
		buttonDisplay.type = -1;
	}
	buttonDisplay.height = 72 * appModel.scale;
	buttonDisplay.layoutData = new AnchorLayoutData(NaN, 0, 0, 0);
	addChild(buttonDisplay);*/
	return null;
}

protected function backgroundFactory() : ImageLoader
{
	if( backgroundDisplay != null )
	{
		backgroundDisplay.source = Assets.getTexture("home/slot-" + state, "gui");
		return null;
	}
	
	var st:int = Math.max(0, state);
	backgroundDisplay = new ImageLoader();
	backgroundDisplay.source = Assets.getTexture("home/slot-" + st, "gui");
	backgroundDisplay.layoutData = new AnchorLayoutData(-padding, -padding, -padding, -padding);
	backgroundDisplay.scale9Grid = new Rectangle(72, 50, 48, 80);
	addChild(backgroundDisplay);
	return backgroundDisplay;
}
protected function emptyGroupFactory() : ShadowLabel 
{
	if( state != ExchangeItem.CHEST_STATE_EMPTY )
		return null;
	if( emptyLabel == null )
	{
		emptyLabel = new ShadowLabel(loc("empty_label"), 0xAAAAAA, 0);
		emptyLabel.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
	}
	addChild(emptyLabel);
	return emptyLabel;
}
protected function waitGroupFactory() : LayoutGroup 
{
	if( state != ExchangeItem.CHEST_STATE_WAIT )
		return null;
	if( waitGroup == null )
	{
		waitGroup = new LayoutGroup();
		waitGroup.layout = new AnchorLayout();
		waitGroup.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		
		var ribbonImage:ImageLoader = new ImageLoader();
		ribbonImage.source = Assets.getTexture("home/open-ribbon", "gui");
		ribbonImage.layoutData = new AnchorLayoutData(0, NaN, NaN, NaN, 0);
		waitGroup.addChild(ribbonImage);
		
		var openLabel:ShadowLabel = new  ShadowLabel(loc("open_label"), 1, 0, null, null, false, null, 0.6);
		openLabel.layoutData = new AnchorLayoutData(padding, NaN, NaN, NaN, 0);
		waitGroup.addChild(openLabel);
		
		var timeLabel:ShadowLabel = new  ShadowLabel(StrUtils.toTimeFormat(ExchangeType.getCooldown(exchange.outcome)), 1, 0, null, null, false, null, 0.9);
		timeLabel.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -height * 0.15);
		waitGroup.addChild(timeLabel);
		
		var closedLabel:ShadowLabel = new  ShadowLabel(loc("lobby_pri_1"), 1, 0, null, null, false, null, 0.8);
		closedLabel.layoutData = new AnchorLayoutData(NaN, NaN, padding , NaN, 0);
		waitGroup.addChild(closedLabel);
	}
	addChild(waitGroup);
	return waitGroup;
}

protected function busyGroupFactory() : LayoutGroup
{
	if( state != ExchangeItem.CHEST_STATE_BUSY )
		return null;
	
	if( busyGroup == null )
	{
		busyGroup = new LayoutGroup();
		busyGroup.layout = new AnchorLayout();
		busyGroup.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		
		var hardImage:ImageLoader = new ImageLoader();
		hardImage.source = Assets.getTexture("res-1003", "gui");
		hardImage.width = height * 0.2;
		hardImage.layoutData = new AnchorLayoutData(padding * 4, NaN, NaN, NaN, padding * 2);
		busyGroup.addChild(hardImage);
		
		countdownDisplay = new CountdownLabel();
		countdownDisplay.layoutData = new AnchorLayoutData(NaN, padding * 2, padding, padding * 1.3);
		busyGroup.addChild(countdownDisplay);
		
		hardLabel = new ShadowLabel("12", 1, 0, "right");
		hardLabel.shadowDistance = padding * 0.25;
		hardLabel.layoutData = new AnchorLayoutData(padding * 4, NaN, NaN, NaN, -padding * 2);
		busyGroup.addChild(hardLabel);
		
		var openLabel:ShadowLabel = new  ShadowLabel(loc("open_label"), 1, 0, null, null, false, null, 0.7);
		openLabel.layoutData = new AnchorLayoutData(padding, NaN, NaN, NaN, 0);
		busyGroup.addChild(openLabel);
	}

	addChild(busyGroup);
	return busyGroup;
}

protected function readyGroupFactory() : ShadowLabel 
{
	if( state != ExchangeItem.CHEST_STATE_READY )
		return null;
	if( readyLabel == null )
	{
		readyLabel = new  ShadowLabel(loc("open_label"));
		readyLabel.shadowDistance = padding * 0.25;
		readyLabel.layoutData = new AnchorLayoutData(padding * 2, NaN, NaN, NaN, 0);
	}
	addChild(readyLabel);
	return readyLabel;
}


protected function timeManager_changeHandler(event:Event):void
{
	if(	exchange.getState(timeManager.now) != ExchangeItem.CHEST_STATE_BUSY )
	{
		commitData();
		return;
	}
	
	var t:uint = uint(exchange.expiredAt - timeManager.now);//trace(index, t)
	
	if( hardLabel != null )
		hardLabel.text = Exchanger.timeToHard(t).toString();
	
	if( countdownDisplay != null )
		countdownDisplay.time = t;
}


private function navigator_itemAchievedHandler(event:Event):void 
{
	if( event.data.count != exchange.type )
		return;

	var outcome:int = event.data.type;
	var bookAnimation:StarlingArmatureDisplay = OpenBookOverlay.factory.buildArmatureDisplay( "book-" + outcome );
	bookAnimation.scale = OpenBookOverlay.getBookScale(exchange.outcome) * appModel.scale * 1.9;
	bookAnimation.animation.gotoAndPlayByFrame("appear", 0, 1);
	bookAnimation.animation.timeScale = 0.5;
	bookAnimation.x = event.data.x;
	bookAnimation.y = event.data.y;
	bookAnimation.addEventListener(EventObject.COMPLETE, bookAnimation_completeHandler);
	appModel.navigator.addChild(bookAnimation);
	var globalPos:Rectangle = this.getBounds(appModel.navigator); 
	Starling.juggler.tween(bookAnimation, 0.5, {delay:0.5, x:globalPos.x + width * 0.53, scale:OpenBookOverlay.getBookScale(exchange.outcome) * appModel.scale * 0.68, transition:Transitions.EASE_IN_OUT});
	Starling.juggler.tween(bookAnimation, 0.5, {delay:0.5, y:globalPos.y + height * 0.65, transition:Transitions.EASE_IN_BACK});
	function bookAnimation_completeHandler(event:StarlingEvent):void
	{
		bookAnimation.removeFromParent(true);
		exchange.expiredAt = 0;
		exchange.outcome = outcome;
		exchange.outcomes.set(outcome, player.get_arena(0));
		commitData();
	}
}

/*private function tutorialManager_finishHandler(event:Event):void
{
	if( exchange.type != ExchangeType.C101_FREE || event.data.name != "shop_start" || stage == null )
		return;
	tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorialManager_finishHandler);
	showTutorArrow();
}
private function showTutorArrow () : void
{
	if( tutorialArrow != null )
		tutorialArrow.removeFromParent(true);
	
	tutorialArrow = new TutorialArrow(false);
	tutorialArrow.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, padding * 5);
	addChild(tutorialArrow);
}
override public function set isSelected(value:Boolean):void
{
	if( value == super.isSelected )
		return;
	super.isSelected = value;
	if( tutorialArrow != null )
		tutorialArrow.removeFromParent(true);
}
*/
private function reset() : void
{
	//tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorialManager_finishHandler);
	appModel.navigator.removeEventListener("itemAchieved", navigator_itemAchievedHandler);
	timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
	removeChildren(0, -1);
	backgroundDisplay = null;
	bookArmature = null;
	buttonDisplay = null;
	countdownDisplay = null;
	waitGroup = null;
	readyLabel = null;
	clearTimeout(timeoutId);
}

override protected function showAchieveAnimation(item:ExchangeItem):void {}
override public function dispose():void
{
	reset();
	super.dispose();
}
}
}