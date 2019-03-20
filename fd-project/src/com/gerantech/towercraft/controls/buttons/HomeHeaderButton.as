package com.gerantech.towercraft.controls.buttons 
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.texts.CountdownLabel;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.exchanges.ExchangeItem;
import feathers.controls.ButtonState;
import feathers.controls.ImageLoader;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;
import flash.geom.Rectangle;
import starling.core.Starling;
import starling.events.Event;

/**
* ...
* @author Mansour Djawadi
*/
public class HomeHeaderButton extends SimpleLayoutButton 
{
protected var exchange:ExchangeItem;
protected var countdownDisplay:CountdownLabel;
protected var backgroundDisplay:ImageLoader;
protected var iconDisplay:ImageLoader;
protected var titleDisplay:ShadowLabel;
protected var state:int;
public function HomeHeaderButton(){super();}
override protected function initialize() : void
{
	super.initialize();
	layout = new AnchorLayout();
	update();
}

public function update() : void
{
	reset();
	exchange = exchanger.items.get(ExchangeType.C101_FREE);
	if( exchange == null )
		return;
	state = exchange.getState(timeManager.now);
	
	backgroundFactory();
	iconFactory("gift");
	titleFactory(loc(state == ExchangeItem.CHEST_STATE_BUSY ? "wheel_of_fortune" : "open_label"));
	countdownFactory();
	
	if( state == ExchangeItem.CHEST_STATE_BUSY )
	{
		timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
		timeManager_changeHandler(null);
	}
	exchangeManager.addEventListener(FeathersEventType.END_INTERACTION, exchangeManager_endInteractionHandler);
}

protected function backgroundFactory() : ImageLoader
{
	if( backgroundDisplay != null )
	{
		backgroundDisplay.source = Assets.getTexture("home/button-bg-" + state, "gui");
		return null;
	}

	var offRect:Rectangle = new Rectangle(-2, -2, -2, -2);
	var backgroundLayout:AnchorLayoutData = new AnchorLayoutData(offRect.x, offRect.y, offRect.width, offRect.height);
	backgroundDisplay = new ImageLoader();
	backgroundDisplay.pixelSnapping = false;
	backgroundDisplay.source = Assets.getTexture("home/button-bg-" + state, "gui");
	backgroundDisplay.layoutData = backgroundLayout;
	backgroundDisplay.maintainAspectRatio = false;
	backgroundDisplay.scale9Grid = new Rectangle(22, 56, 4, 4);
	addChild(backgroundDisplay);
	if( state == ExchangeItem.CHEST_STATE_READY )
	{
		function repeatPunch(isUp:Boolean):void {
			var p:Number = isUp ? 1 : 3;
			Starling.juggler.tween(backgroundLayout, 1.6, {top:offRect.x * p, right:offRect.y * p, bottom:offRect.width * p, left:offRect.height * p, onComplete:repeatPunch, onCompleteArgs:[!isUp]});
		}
		repeatPunch(true);
	}
	return backgroundDisplay;
}

protected function iconFactory(image:String) : ImageLoader 
{
	if( iconDisplay != null )
		return null;
	iconDisplay = new ImageLoader();
	iconDisplay.touchable = false;
	iconDisplay.source = Assets.getTexture("home/" + image, "gui");
	iconDisplay.layoutData = new AnchorLayoutData(8, 8, 8);
	addChild(iconDisplay);
	return iconDisplay;
}

protected function countdownFactory() : CountdownLabel
{
	if( state != ExchangeItem.CHEST_STATE_BUSY )
		return null;
	
	countdownDisplay = new CountdownLabel();
	countdownDisplay.touchable = false;
	countdownDisplay.height = 90;
	countdownDisplay.layoutData = new AnchorLayoutData(NaN, 170, NaN, 20, NaN, 20);
	addChild(countdownDisplay);
	return countdownDisplay;
}

protected function titleFactory(text:String) : ShadowLabel
{
	//if( state == ExchangeItem.CHEST_STATE_BUSY )
	//	return null;
	titleDisplay = new ShadowLabel(text, 1, 0, "center", null, false, null, state == ExchangeItem.CHEST_STATE_BUSY ? 0.7 : 0.95);
	titleDisplay.touchable = false;
	titleDisplay.shadowDistance = appModel.theme.gameFontSize * 0.05;
	titleDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, -64, state == ExchangeItem.CHEST_STATE_BUSY ? -40 : 0);
	addChild(titleDisplay);
	return titleDisplay;
}

protected function exchangeManager_endInteractionHandler(event:Event) : void 
{
	var item:ExchangeItem = event.data as ExchangeItem;
	if( item.type != exchange.type )
		return;
	update();
}
protected function timeManager_changeHandler(event:Event) : void
{
	if(	exchange.getState(timeManager.now) != ExchangeItem.CHEST_STATE_BUSY )
	{
		update();
		return;
	}
	
	var t:uint = uint(exchange.expiredAt - timeManager.now);//trace(index, t)
	//if( buttonDisplay != null )
	//	buttonDisplay.count = Exchanger.timeToHard(t);
	
	if( countdownDisplay != null )
		countdownDisplay.time = t;
}

// touch effect
override public function set currentState(value:String) : void
{
	super.currentState = value;
	if( backgroundDisplay == null || backgroundDisplay.layoutData == null )
		return;
	var ldata:AnchorLayoutData = backgroundDisplay.layoutData as AnchorLayoutData;
	var vP:int = value == ButtonState.DOWN ? 4 : -2;
	ldata.top = ldata.right = ldata.bottom = ldata.left = vP;
}

protected function reset() : void
{
	//tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorialManager_finishHandler);
	Starling.juggler.removeTweens(backgroundDisplay);
	exchangeManager.removeEventListener(FeathersEventType.END_INTERACTION, exchangeManager_endInteractionHandler);
	timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
	removeChildren(0, -1, true);
	backgroundDisplay = null;
	iconDisplay = null;
	titleDisplay = null;
	countdownDisplay = null;
	//clearTimeout(timeoutId);
}

override public function dispose() : void
{
	reset();
	super.dispose();
}
}
}