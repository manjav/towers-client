package com.gerantech.towercraft.controls.items.exchange
{
import com.gerantech.towercraft.controls.buttons.ExchangeButton;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.controls.overlays.TutorialArrow;
import com.gerantech.towercraft.controls.texts.CountdownLabel;
import com.gerantech.towercraft.events.GameEvent;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;
import com.gt.towers.exchanges.Exchanger;
import dragonBones.starling.StarlingArmatureDisplay;
import feathers.layout.AnchorLayoutData;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;
import starling.display.BlendMode;
import starling.events.Event;

public class ExchangeBookBattleItemRenderer extends ExchangeBookBaseItemRenderer
{
private var state:int = -2;
private var countdownDisplay:CountdownLabel;
private var timeoutId:uint;
//private var tutorialArrow:TutorialArrow;

public function ExchangeBookBattleItemRenderer(){}
override protected function commitData():void
{
	if( index < 0 || _data == null )
		return;
	exchange = exchanger.items.get(_data as int);
	state = exchange.getState(timeManager.now);

	skin.blendMode = BlendMode.ADD;
	skin.alpha = state == ExchangeItem.CHEST_STATE_BUSY ? 0.5 : 1;
	super.commitData();
	countdownFactory();
	
	if( state == ExchangeItem.CHEST_STATE_BUSY )
	{
		if( !timeManager.hasEventListener(Event.CHANGE, timeManager_changeHandler) )
		timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
		timeManager_changeHandler(null);
	}
	//tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorialManager_finishHandler);
}

protected function timeManager_changeHandler(event:Event):void
{
	if(	exchange.getState(timeManager.now) != ExchangeItem.CHEST_STATE_BUSY )
	{
		timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
		removeChildren(0, -1, true);
		bookArmature = null;
		buttonDisplay = null;
		countdownDisplay = null;
		commitData();
		return;
	}
	
	var t:uint = uint(exchange.expiredAt - timeManager.now);//trace(index, t)
	
	if( buttonDisplay != null )
		buttonDisplay.count = Exchanger.timeToHard(t);
	
	if( countdownDisplay != null )
		countdownDisplay.time = t;
}

/**
 * add, remove or update armature depends on type and state
 */
override protected function bookFactory() : StarlingArmatureDisplay
{
	clearTimeout(timeoutId);
	if( exchange.category == ExchangeType.C110_BATTLES || (exchange.category == ExchangeType.C100_FREES && state == ExchangeItem.CHEST_STATE_READY) ) 
	{
		bookArmature = OpenBookOverlay.factory.buildArmatureDisplay( "book-" + exchange.outcome );
		bookArmature.scale = appModel.scale * 0.85;
		bookArmature.x = width * 0.5;
		bookArmature.y = height * 0.45;
		if( state == ExchangeItem.CHEST_STATE_READY )
			timeoutId = setTimeout(bookArmature.animation.gotoAndPlayByTime, Math.random() * 2000, "wait", 0, 100);
		else
			bookArmature.animation.gotoAndStopByProgress("fall-closed", 1);
		addChild(bookArmature);
	}
	return bookArmature;
}

override protected function buttonFactory() : ExchangeButton
{
	if( exchange.category != ExchangeType.C110_BATTLES )//===remove=frees===
		return null;

	buttonDisplay = new ExchangeButton();
	if( state == ExchangeItem.CHEST_STATE_WAIT )
	{
		buttonDisplay.style = "normal";trace(exchange.outcome, ExchangeType.getKeyRequierement(exchange.outcome))
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
	buttonDisplay.height = 80 * appModel.scale;
	buttonDisplay.layoutData = new AnchorLayoutData(NaN, padding, padding, padding);
	addChild(buttonDisplay);
	return buttonDisplay;
}

protected function countdownFactory() : CountdownLabel
{
	if( state != ExchangeItem.CHEST_STATE_BUSY )
		return null;
	
	countdownDisplay = new CountdownLabel();
	if( exchange.category == ExchangeType.C110_BATTLES )//===remove=frees===
		countdownDisplay.layoutData = new AnchorLayoutData(24 * appModel.scale, padding, NaN, 0);
	else
		countdownDisplay.layoutData = new AnchorLayoutData(NaN, padding, NaN, 0, NaN, 0);
	addChild(countdownDisplay);
	return countdownDisplay;
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

override protected function showAchieveAnimation(item:ExchangeItem):void {}
override public function dispose():void
{
	//tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorialManager_finishHandler);
	timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
	clearTimeout(timeoutId);
	super.dispose();
}
}
}