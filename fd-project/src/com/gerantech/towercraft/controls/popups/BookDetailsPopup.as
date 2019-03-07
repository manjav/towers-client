package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.buttons.ExchangeButton;
import com.gerantech.towercraft.controls.groups.IconGroup;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.controls.texts.CountdownLabel;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.MessageTypes;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;
import com.gt.towers.exchanges.Exchanger;
import dragonBones.events.EventObject;
import dragonBones.starling.StarlingArmatureDisplay;
import dragonBones.starling.StarlingEvent;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import flash.utils.setTimeout;
import starling.events.Event;

public class BookDetailsPopup extends SimplePopup
{
private var item:ExchangeItem;
private var bookArmature:StarlingArmatureDisplay;
private var buttonDisplay:ExchangeButton;
private var countdownDisplay:CountdownLabel;
private var messageDisplay:RTLLabel;
private var showButton:Boolean;
private var footerDisplay:ImageLoader;

public function BookDetailsPopup(item:ExchangeItem, showButton:Boolean = true)
{
	this.item = item;
	this.showButton = showButton;
	super();
}

override protected function initialize():void
{
	super.initialize();
	
	transitionIn.sourceBound = transitionOut.destinationBound = new Rectangle(stage.stageWidth * 0.05, stage.stageHeight * (showButton ? 0.30 : 0.35), stage.stageWidth * 0.9, stage.stageHeight * (showButton ? 0.4 : 0.25));
	transitionOut.sourceBound = transitionIn.destinationBound = new Rectangle(stage.stageWidth * 0.05, stage.stageHeight * (showButton ? 0.25 : 0.30), stage.stageWidth * 0.9, stage.stageHeight * (showButton ? 0.5 : 0.35));
	rejustLayoutByTransitionData();

	var insideBG:ImageLoader = new ImageLoader();
	insideBG.alpha = 0.8;
	insideBG.scale9Grid = new Rectangle(4, 4, 2, 2);
	insideBG.maintainAspectRatio = false;
	insideBG.source = Assets.getTexture("theme/popup-inside-background-skin", "gui");
	insideBG.layoutData = new AnchorLayoutData(padding * 6, padding, padding * 1.2, padding);
	addChild(insideBG);
	
	var arena:int = item.outcomes.get(item.outcome);
	var leagueDisplay:RTLLabel = new RTLLabel(loc("arena_text") + " " + loc("num_" + (arena + 1)), 0x475768, "center", null, false, null, 0.8);
	leagueDisplay.layoutData = new AnchorLayoutData(padding * 7.5, NaN, NaN, NaN, 0);
	addChild(leagueDisplay);
	
	var titleDisplay:ShadowLabel = new ShadowLabel(loc("exchange_title_" + item.outcome), 0, 1, "center", null, false, null, 1.3);
	titleDisplay.layoutData = new AnchorLayoutData(padding * 9, NaN, NaN, NaN, 0);
	addChild(titleDisplay);

	var numCards:int = ExchangeType.getNumTotalCards(item.outcome, arena, player.splitTestCoef);
	var cardsPalette:IconGroup = new IconGroup(Assets.getTexture("cards", "gui"), int(numCards * 0.9) + " - " + int(numCards * 1.1));
	cardsPalette.width = transitionIn.destinationBound.width * 0.4;
	cardsPalette.layoutData = new AnchorLayoutData(padding * 13, NaN, NaN, padding * 2.4);
	addChild(cardsPalette);
	
	var numSofts:int = ExchangeType.getNumSofts(item.outcome, arena, player.splitTestCoef);
	var softsPalette:IconGroup = new IconGroup(Assets.getTexture("res-" + ResourceType.R3_CURRENCY_SOFT, "gui"), int(numSofts * 0.9) + " - " + int(numSofts * 1.1), 0xFFFF99);
	softsPalette.width = transitionIn.destinationBound.width * 0.4;
	softsPalette.layoutData = new AnchorLayoutData(padding * 13, padding * 2);
	addChild(softsPalette);
	
	if( !showButton )
		return;
		
	update(state);
}

override protected function transitionInCompleted():void
{
	super.transitionInCompleted();
	
	OpenBookOverlay.createFactory();
	bookArmature = OpenBookOverlay.factory.buildArmatureDisplay("book-" + item.outcome);
	bookArmature.addEventListener(EventObject.SOUND_EVENT, bookArmature_soundEventHandler);
	bookArmature.scale = OpenBookOverlay.getBookScale(item.outcome) * 2;
	bookArmature.animation.gotoAndPlayByTime("appear", 0, 1);
	bookArmature.x = transitionIn.destinationBound.width * 0.5;
	bookArmature.y = padding * 0.5;
	addChildAt(bookArmature, 0);
	function bookArmature_soundEventHandler(event:StarlingEvent):void
	{
		bookArmature.removeEventListener(EventObject.SOUND_EVENT, bookArmature_soundEventHandler);
		addChildAt(bookArmature, 3);
		appModel.sounds.addAndPlay(event.eventObject.name);
	}
	
	if( player.get_battleswins() < 4 )
	{
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_032_SLOT_OPENED);
		buttonDisplay.showTutorHint();
	}
}

private function update(state:int):void 
{
	closeOnOverlay = closeWithKeyboard = player.getResource(ResourceType.R21_BOOK_OPENED_BATTLE) > 0;
	footerFactory(state);
	messageFactory(state);
	buttonFactory(state);
}

//           -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- Factories -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
private function footerFactory(state:int):void 
{
	if( footerDisplay == null )
	{
		footerDisplay = new ImageLoader();
		footerDisplay.alpha = 0.8;
		footerDisplay.scale9Grid = new Rectangle(4, 4, 2, 2);
		footerDisplay.maintainAspectRatio = false;
		footerDisplay.source = Assets.getTexture("theme/popup-inside-background-skin", "gui");
		footerDisplay.layoutData = new AnchorLayoutData(NaN, padding * 1.3, padding * 1.5, padding * 1.3);
		footerDisplay.height = padding * 4.4;
		addChild(footerDisplay);
	}
	footerDisplay.color = state == ExchangeItem.CHEST_STATE_BUSY ? 0xAA9999 : 0x9999AA;
}

private function messageFactory(state:int):void 
{
	var message:String = "";
	if( state == ExchangeItem.CHEST_STATE_BUSY )
		message = loc("popup_chest_message_skip", [Exchanger.timeToHard(item.expiredAt - timeManager.now)]);
	else if( state == ExchangeItem.CHEST_STATE_WAIT )
		message = loc("popup_chest_message_" + item.category, [StrUtils.toTimeFormat(ExchangeType.getCooldown(item.outcome))]);
	
	if( messageDisplay == null )
	{
		messageDisplay = new RTLLabel(message, 0, "center", null, false, null, 0.9);
		messageDisplay.layoutData = new AnchorLayoutData(NaN, padding, padding * 7, padding);
		addChild(messageDisplay);
	}
	else
	{
		messageDisplay.text = message;
	}
}

private function buttonFactory(state:int):void 
{
	if( buttonDisplay == null )
	{
		buttonDisplay = new ExchangeButton();
		buttonDisplay.disableSelectDispatching = true;
		buttonDisplay.width = 300;
		buttonDisplay.height = 110;
		buttonDisplay.addEventListener(Event.SELECT, batton_selectHandler);
		buttonDisplay.addEventListener(Event.TRIGGERED, batton_triggeredHandler);
		buttonDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding * 2, NaN, 0);
		addChild(buttonDisplay);
	}
	
	if( item.category == ExchangeType.C110_BATTLES )
	{
		if( state == ExchangeItem.CHEST_STATE_BUSY )
		{
			buttonDisplay.style = "neutral";
			buttonDisplay.width = 240;
			buttonDisplay.layoutData = new AnchorLayoutData(NaN, padding * 2, padding * 2, NaN);
			timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
			updateButton(ResourceType.R4_CURRENCY_HARD, Exchanger.timeToHard(item.expiredAt - timeManager.now));
			countdownFactory(state);
		}
		else if( state == ExchangeItem.CHEST_STATE_WAIT )
		{
			var free:Boolean = exchanger.isBattleBookReady(item.type, timeManager.now) == MessageTypes.RESPONSE_SUCCEED;
			buttonDisplay.style = free ? "normal" : "neutral";
			updateButton(free ? ResourceType.R2_POINT : ResourceType.R4_CURRENCY_HARD, free ? -1 : Exchanger.timeToHard(ExchangeType.getCooldown(item.outcome)));
			if( !free )
				messageDisplay.text =  loc("popup_chest_message_120");
		}
		else if( state == ExchangeItem.CHEST_STATE_READY )
		{
			buttonDisplay.style = "normal";
			updateButton(-1, -1);
		}
	}
	else
	{
		updateButton(ResourceType.R4_CURRENCY_HARD, item.requirements.get(ResourceType.R4_CURRENCY_HARD));
	}
}

private function countdownFactory(state:int):void
{
	if( state != ExchangeItem.CHEST_STATE_BUSY )
	{
		if( countdownDisplay != null )
		{
			countdownDisplay.removeFromParent();
			countdownDisplay = null;
		}
		return;
	}
	if( countdownDisplay == null )
	{
		countdownDisplay = new CountdownLabel();
		countdownDisplay.width = 320;
		countdownDisplay.height = 120;
		countdownDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding * 1.9, NaN, -170);
		addChild(countdownDisplay);
	}
	var t:uint = uint(item.expiredAt - timeManager.now);
	countdownDisplay.time = t;
	buttonDisplay.count = Exchanger.timeToHard(t);
	messageDisplay.text = loc("popup_chest_message_skip", [Exchanger.timeToHard(t)])
}

private function updateButton(type:int, count:int):void
{
	buttonDisplay.count = count;
	buttonDisplay.type = type;
}

//           -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- Handlers -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
protected function timeManager_changeHandler(event:Event):void
{
	updateButton(ResourceType.R4_CURRENCY_HARD, Exchanger.timeToHard(item.expiredAt - timeManager.now));
	var _state:int = state;
	countdownFactory(_state);
	if( _state == ExchangeItem.CHEST_STATE_READY )
	{
		timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
		update(_state);
	}
}

protected function batton_selectHandler(event:Event):void
{
	var res:int = exchanger.isBattleBookReady(item.type, timeManager.now);
	if( res == MessageTypes.RESPONSE_ALREADY_SENT )
		appModel.navigator.addLog(loc("popup_chest_error_exists"));
	else
		appModel.navigator.addLog(loc("popup_chest_error_resource"));
}

protected function batton_triggeredHandler(event:Event) : void
{
	dispatchEventWith(Event.SELECT, false, item);
	if( state == ExchangeItem.CHEST_STATE_BUSY )
	{
		update(state);
		if( player.get_battleswins() < 4 )
			setTimeout(buttonDisplay.showTutorHint, 100);
		return;
	}
	close();
}

//           -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- Properties -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
public function get state() : int 
{
	if( item == null )
		return ExchangeItem.CHEST_STATE_EMPTY;
	return item.getState(timeManager.now);
}

override public function dispose():void
{
	if( buttonDisplay != null )
		buttonDisplay.removeEventListener(Event.TRIGGERED, batton_triggeredHandler);
	timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
	super.dispose();
}
}
}