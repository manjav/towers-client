package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.buttons.ExchangeButton;
import com.gerantech.towercraft.controls.groups.Devider;
import com.gerantech.towercraft.controls.groups.IconGroup;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.controls.texts.CountdownLabel;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.themes.MainTheme;
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
import feathers.controls.Button;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import flash.utils.setTimeout;
import starling.display.Image;
import starling.events.Event;

public class BookDetailsPopup extends SimplePopup
{
private var showButton:Boolean;
private var item:ExchangeItem;
private var actionButton:Button;
private var messageDisplay:RTLLabel;
private var footerDisplay:ImageLoader;
private var countdownDisplay:CountdownLabel;
private var bookArmature:StarlingArmatureDisplay;
public function BookDetailsPopup(item:ExchangeItem, showButton:Boolean = true)
{
	this.item = item;
	this.showButton = showButton;
	super();
}

override protected function initialize():void
{
	super.initialize();
	
	var _h:int = showButton ? 680 : 480;
	transitionIn.sourceBound = transitionOut.destinationBound = new Rectangle(stageWidth * 0.05, stageHeight * 0.5 - _h * 0.4, stageWidth * 0.9, _h * 0.8);
	transitionOut.sourceBound = transitionIn.destinationBound = new Rectangle(stageWidth * 0.05, stageHeight * 0.5 - _h * 0.5, stageWidth * 0.9, _h * 1.0);
	rejustLayoutByTransitionData();

	var insideBG:Devider = new Devider(0x1E66C2);
	insideBG.height = 120;
	insideBG.layoutData = new AnchorLayoutData(80, 0, NaN, 0);
	addChild(insideBG);
	
	var arena:int = item.outcomes.get(item.outcome);
	var leagueDisplay:ShadowLabel	= new ShadowLabel(loc("arena_text") + " " + loc("num_" + (arena + 1)), 0xBBDDFF, 0, null, null, false, null, 0.8);
	leagueDisplay.layoutData = new AnchorLayoutData(26, NaN, NaN, NaN, 220);
	addChild(leagueDisplay);
	
	var titleDisplay:ShadowLabel = new ShadowLabel(loc("exchange_title_" + item.outcome), 1, 0, null, null, false, null, 1.1);
	titleDisplay.layoutData = new AnchorLayoutData(85, NaN, NaN, NaN, 220);
	addChild(titleDisplay);

	var numCards:int = ExchangeType.getNumTotalCards(item.outcome, arena, player.splitTestCoef, 0);
	var cardsPalette:IconGroup = new IconGroup(Assets.getTexture("cards"), int(numCards * 0.9) + " - " + int(numCards * 1.1));
	cardsPalette.width = transitionIn.destinationBound.width * 0.42;
	cardsPalette.layoutData = new AnchorLayoutData(290, NaN, NaN, 50);
	addChild(cardsPalette);
	
	var numSofts:int = ExchangeType.getNumSofts(item.outcome, arena, player.splitTestCoef);
	var softsPalette:IconGroup = new IconGroup(Assets.getTexture("res-" + ResourceType.R3_CURRENCY_SOFT, "gui"), int(numSofts * 0.9) + " - " + int(numSofts * 1.1), 0xFFFF99);
	softsPalette.width = transitionIn.destinationBound.width * 0.42;
	softsPalette.layoutData = new AnchorLayoutData(290, 40);
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
	bookArmature.scale = OpenBookOverlay.getBookScale(item.outcome) * 1.4;
	bookArmature.animation.gotoAndPlayByTime("appear", 0, 1);
	bookArmature.x = 260;
	bookArmature.y = 50;
	addChildAt(bookArmature, 0);
	function bookArmature_soundEventHandler(event:StarlingEvent):void
	{
		bookArmature.removeEventListener(EventObject.SOUND_EVENT, bookArmature_soundEventHandler);
		addChild(bookArmature);
		appModel.sounds.addAndPlay(event.eventObject.name);
	}
	
	if( player.get_battleswins() < 4 )
	{
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_012_SLOT_OPENED);
		//buttonDisplay.showTutorHint();
	}
}

private function update(state:int):void 
{
	closeOnOverlay = closeWithKeyboard = player.getResource(ResourceType.R21_BOOK_OPENED_BATTLE) > 0;
	footerFactory(state);
}

//           -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- Factories -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
private function footerFactory(state:int):void 
{
	if( footerDisplay == null )
	{
		footerDisplay = new ImageLoader();
		footerDisplay.source = Assets.getTexture("theme/inner-rect-medium", "gui")
		footerDisplay.layoutData = new AnchorLayoutData(NaN, 12, 12, 12);
		footerDisplay.scale9Grid = new Rectangle(15, 15, 3, 3);
		footerDisplay.height = 200;
		addChild(footerDisplay);
	}
	footerDisplay.color = 0x87a8d0;
	
	if( actionButton == null )
	{
		actionButton = new Button();
		actionButton.width = 300;
		actionButton.height = 162;
		actionButton.addEventListener(Event.TRIGGERED, batton_triggeredHandler);
		addChild(actionButton);
	}
	actionButton.layoutData = new AnchorLayoutData(NaN, NaN, 30, NaN, 0);
	actionButton.styleName = MainTheme.STYLE_BUTTON_HILIGHT;
	
	var message:String = "";
	if( item.category == ExchangeType.C110_BATTLES )
	{
		if( state == ExchangeItem.CHEST_STATE_BUSY )
		{
			footerDisplay.color = 0x437a50;
			actionButton.styleName = MainTheme.STYLE_BUTTON_NORMAL;
			actionButton.layoutData = new AnchorLayoutData(NaN, 30, 30, NaN);
			timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
			updateButton(ResourceType.R4_CURRENCY_HARD, Exchanger.timeToHard(item.expiredAt - timeManager.now));
			message = loc("popup_chest_message_skip", [Exchanger.timeToHard(item.expiredAt - timeManager.now)]);
			countdownFactory(state);
		}
		else if( state == ExchangeItem.CHEST_STATE_WAIT )
		{
			var free:Boolean = exchanger.isBattleBookReady(item.type, timeManager.now) == MessageTypes.RESPONSE_SUCCEED;
			actionButton.layoutData = new AnchorLayoutData(NaN, free ? NaN : 30, 30, NaN, free ? 0 : NaN);
			updateButton(free ? ResourceType.R2_POINT : ResourceType.R4_CURRENCY_HARD, free ? -1 : Exchanger.timeToHard(ExchangeType.getCooldown(item.outcome)));
			actionButton.styleName = free ? MainTheme.STYLE_BUTTON_HILIGHT : MainTheme.STYLE_BUTTON_NORMAL;
			
			// message ......
			if( free )
				message = loc("popup_chest_message_" + item.category, [StrUtils.toTimeFormat(ExchangeType.getCooldown(item.outcome))]);
			else
				message = loc("popup_chest_error_exists");
			
			if( messageDisplay == null )
			{
				messageDisplay = new ShadowLabel("", free ? 1 : 0xFF1144, 0, null, null, false, null, 0.85);
				messageDisplay.layoutData = new AnchorLayoutData(NaN, NaN, 80, NaN, -160);
				addChild(messageDisplay);
			}
			messageDisplay.text = message;
			
		}
		else if( state == ExchangeItem.CHEST_STATE_READY )
		{
			updateButton(-1, -1);
		}
	}
	else
	{
		footerDisplay.color = 0x437a50;
		actionButton.styleName = MainTheme.STYLE_BUTTON_NORMAL;
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
		countdownDisplay.width = 400;
		countdownDisplay.height = 120;
		countdownDisplay.layoutData = new AnchorLayoutData(NaN, NaN, 45, NaN, -150);
		addChild(countdownDisplay);
	}
	var t:uint = uint(item.expiredAt - timeManager.now);
	countdownDisplay.time = t;
	//buttonDisplay.count = Exchanger.timeToHard(t);
	//messageDisplay.text = loc("popup_chest_message_skip", [Exchanger.timeToHard(t)])
}

private function updateButton(type:int, count:int):void
{
	actionButton.label = ExchangeButton.getLabel(count, type);
	actionButton.defaultIcon = new Image(ExchangeButton.getIcon(count, type));
	//buttonDisplay.count = count;
	//buttonDisplay.type = type;
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
		//if( player.get_battleswins() < 4 )
			//setTimeout(buttonDisplay.showTutorHint, 100);
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
	if( actionButton != null )
		actionButton.removeEventListener(Event.TRIGGERED, batton_triggeredHandler);
	timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
	super.dispose();
}
}
}