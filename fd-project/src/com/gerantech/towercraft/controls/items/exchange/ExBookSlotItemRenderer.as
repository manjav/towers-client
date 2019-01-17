package com.gerantech.towercraft.controls.items.exchange
{
import com.gerantech.towercraft.controls.buttons.ExchangeButton;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.controls.overlays.TutorialArrow;
import com.gerantech.towercraft.controls.texts.CountdownLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.models.vo.RewardData;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.exchanges.ExchangeItem;
import com.gt.towers.exchanges.Exchanger;
import dragonBones.events.EventObject;
import dragonBones.starling.StarlingArmatureDisplay;
import dragonBones.starling.StarlingEvent;
import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
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
private var tutorialArrow:TutorialArrow;
private var ribbonImage:ImageLoader;

public function ExBookSlotItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
	padding = 16;
	backgroundSkin = skin = null;
}
override protected function commitData():void
{
	if( index < 0 || _data == null )
		return;
	reset();
	
	if( firstCommit )
		exchangeManager.addEventListener(FeathersEventType.BEGIN_INTERACTION, exchangeManager_beginInteractionHandler);
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
	else if( state == ExchangeItem.CHEST_STATE_READY && player.getTutorStep() == PrefsTypes.T_032_SLOT_OPENED )
	{
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_033_BOOK_OPENED);
		showTutorArrow();
	}
	else if( state == ExchangeItem.CHEST_STATE_WAIT && exchange.outcome == ExchangeType.BOOK_51_METAL )
	{
		var tutorialData:TutorialData = new TutorialData("open_slot");
		tutorialData.data = "free";
		tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_slot_description"));
		tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorialManager_finishHandler);
		tutorials.show(tutorialData);
	}
	
	// show book falling
	owner.addEventListener(FeathersEventType.CREATION_COMPLETE, createComplteHandler);
}

private function createComplteHandler(event:Event):void 
{
	event.currentTarget.removeEventListener(FeathersEventType.CREATION_COMPLETE, createComplteHandler);
	setTimeout(achieve, 10);
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
		bookArmature.scale = OpenBookOverlay.getBookScale(exchange.outcome) * 0.68;
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
		
		ribbonImage = new ImageLoader();
		ribbonImage.pixelSnapping = false;
		ribbonImage.source = Assets.getTexture("home/open-ribbon", "gui");
		ribbonImage.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0);
		ribbonImage.addEventListener(FeathersEventType.CREATION_COMPLETE, ribbonImage_createCompleteHandler);
		waitGroup.addChild(ribbonImage);
		
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

protected function ribbonImage_createCompleteHandler(event:Event) : void
{
	ribbonImage.removeEventListener(FeathersEventType.CREATION_COMPLETE, ribbonImage_createCompleteHandler);
	var openLabel:ShadowLabel = new  ShadowLabel(loc("open_label"), 1, 0, "center", null, false, null, 0.6);
	openLabel.width = ribbonImage.width;
	openLabel.pivotX = openLabel.width * 0.5;
	openLabel.x = ribbonImage.width * 0.5;
	openLabel.y = 18;
	ribbonImage.addChild(openLabel);
	
	showOpenWarn();
}
private function showOpenWarn() : void 
{
	if( state != ExchangeItem.CHEST_STATE_WAIT )
		return;
	Starling.juggler.removeTweens(ribbonImage);
	ribbonImage.y = 0;
	ribbonImage.scaleY = 1;
	var readyToOpen:Boolean = exchanger.findItem(ExchangeType.C110_BATTLES, ExchangeItem.CHEST_STATE_BUSY, timeManager.now) == null;
	if( !readyToOpen )
		return;
	up();
	function up()	: void { Starling.juggler.tween(ribbonImage, 1.5, {scaleY:0.95, y:-1,	transition:Transitions.EASE_OUT,onComplete:down,	delay:0}); }
	function down() : void { Starling.juggler.tween(ribbonImage, 0.3, {scaleY:1.10, y:4,	transition:Transitions.EASE_IN,	onComplete:up,		delay:Math.random() * 3}); }
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
		hardImage.layoutData = new AnchorLayoutData(padding * 4, NaN, NaN, NaN, padding * 2.2);
		busyGroup.addChild(hardImage);
		
		countdownDisplay = new CountdownLabel();
		countdownDisplay.layoutData = new AnchorLayoutData(NaN, padding * 2, padding, padding * 1.3);
		busyGroup.addChild(countdownDisplay);
		
		hardLabel = new ShadowLabel("12", 1, 0, "right", null, false, null, 0.9);
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


private function achieve():void 
{
	if( appModel.battleFieldView == null || appModel.battleFieldView.battleData.outcomes == null )
		return;
	
	var achieved:int =-1;
	var rd:RewardData;
	for ( var i:int = 0; i < appModel.battleFieldView.battleData.outcomes.length; i++ )
	{
		rd = appModel.battleFieldView.battleData.outcomes[i];
		if ( rd.value == exchange.type )
		{
			achieved = i;
			break;
		}
	}

	if( achieved == -1 )
		return;

	emptyLabel.removeFromParent();
	var bookAnimation:StarlingArmatureDisplay = OpenBookOverlay.factory.buildArmatureDisplay( "book-" + rd.key );
	bookAnimation.scale = OpenBookOverlay.getBookScale(exchange.outcome) * 1.9;
	bookAnimation.animation.gotoAndPlayByFrame("appear", 0, 1);
	bookAnimation.animation.timeScale = 0.5;
	bookAnimation.x = rd.x;
	bookAnimation.y = rd.y;
	bookAnimation.addEventListener(EventObject.COMPLETE, bookAnimation_completeHandler);
	appModel.navigator.addChild(bookAnimation);
	var globalPos:Rectangle = this.getBounds(stage);trace(globalPos)
	Starling.juggler.tween(bookAnimation, 0.5, {delay:0.5, x:globalPos.x + width * 0.53, scale:OpenBookOverlay.getBookScale(exchange.outcome) * 0.68, transition:Transitions.EASE_IN_OUT});
	Starling.juggler.tween(bookAnimation, 0.5, {delay:0.5, y:globalPos.y + height * 0.65, transition:Transitions.EASE_IN_BACK});
	function bookAnimation_completeHandler(event:StarlingEvent):void
	{
		bookAnimation.removeFromParent(true);
		exchange.expiredAt = 0;
		exchange.outcome = rd.key;
		exchange.outcomes.set(rd.key, player.get_arena(0));
		commitData();
	}
	
	appModel.battleFieldView.battleData.outcomes.removeAt(achieved);
}

private function tutorialManager_finishHandler(event:Event):void
{
	if( exchange.category != ExchangeType.C110_BATTLES || event.data.name != "open_slot" || stage == null )
		return;
	tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorialManager_finishHandler);
	showTutorArrow();
}
private function showTutorArrow () : void
{
	if( tutorialArrow != null )
		tutorialArrow.removeFromParent(true);
	
	tutorialArrow = new TutorialArrow(false);
	tutorialArrow.layoutData = new AnchorLayoutData(padding, NaN, NaN, NaN, 0);
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

private function reset() : void
{
	//tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorialManager_finishHandler);
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


override protected function resetData(item:ExchangeItem):void 
{
	showOpenWarn();
	super.resetData(item);
}

override protected function showAchieveAnimation(item:ExchangeItem):void {}
override protected function exchangeManager_endInteractionHandler(event:Event):void {}
protected function exchangeManager_beginInteractionHandler(event:Event):void 
{
	resetData(event.data as ExchangeItem);
}
override public function dispose():void
{
	reset();
	super.dispose();
}
}
}