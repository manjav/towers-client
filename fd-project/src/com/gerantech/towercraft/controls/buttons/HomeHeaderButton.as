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
protected var padding:Number;
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
	
	padding = 42 * appModel.scale;
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
	titleFactory(loc("open_label"));
	countdownFactory();
	
	if( state == ExchangeItem.CHEST_STATE_BUSY )
	{
		timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
		timeManager_changeHandler(null);
	}
	exchangeManager.addEventListener(Event.COMPLETE, exchangeManager_completeHandler);
}

protected function backgroundFactory() : ImageLoader
{
	if( backgroundDisplay != null )
	{
		backgroundDisplay.source = Assets.getTexture("home/header-button-" + state, "gui");
		return null;
	}

	var offRect:Rectangle = new Rectangle(-36, -52, -46, -53);
	var backgroundLayout:AnchorLayoutData = new AnchorLayoutData(offRect.x, offRect.y, offRect.width, offRect.height);
	backgroundDisplay = new ImageLoader();
	backgroundDisplay.pixelSnapping = false;
	backgroundDisplay.source = Assets.getTexture("home/header-button-" + state, "gui");
	backgroundDisplay.layoutData = backgroundLayout;
	backgroundDisplay.maintainAspectRatio = false;
	backgroundDisplay.scale9Grid = new Rectangle(92, 66, 38, 20);
	addChild(backgroundDisplay);
	if( state == ExchangeItem.CHEST_STATE_READY )
	{
		function repeatPunch(isUp:Boolean):void {
			var p:Number = isUp ? 1.2 : 1;
			Starling.juggler.tween(backgroundLayout, 1.0, {top:offRect.x * p, right:offRect.y * p, bottom:offRect.width * p, left:offRect.height * p, onComplete:repeatPunch, onCompleteArgs:[!isUp]});
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
	iconDisplay.layoutData = new AnchorLayoutData(padding * 0.2, padding * 0.25, padding * 0.25);
	addChild(iconDisplay);
	return iconDisplay;
}

protected function countdownFactory() : CountdownLabel
{
	if( state != ExchangeItem.CHEST_STATE_BUSY )
		return null;
	
	countdownDisplay = new CountdownLabel();
	countdownDisplay.touchable = false;
	countdownDisplay.height = 120 * appModel.scale;
	countdownDisplay.layoutData = new AnchorLayoutData(NaN, padding * 4.2, NaN, padding * 0.5, NaN, 0);
	addChild(countdownDisplay);
	return countdownDisplay;
}

protected function titleFactory(text:String) : ShadowLabel
{
	if( state == ExchangeItem.CHEST_STATE_BUSY )
		return null;
	if( titleDisplay != null )
	{
		titleDisplay.text = text;
		return null;
	}
	titleDisplay = new ShadowLabel(text, 1, 0, "center", null, false, null, 1.3);
	titleDisplay.touchable = false;
	titleDisplay.shadowDistance = appModel.theme.gameFontSize * 0.05;
	titleDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, -padding * 1.6, -padding * 0.25);
	addChild(titleDisplay);
	return titleDisplay;
}

protected function exchangeManager_completeHandler(event:Event) : void 
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
	var vP:int = -padding * (value == ButtonState.DOWN ? 0.85 : 1);
	ldata.top = ldata.right = ldata.bottom = ldata.left = vP;
}

protected function reset() : void
{
	//tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorialManager_finishHandler);
	Starling.juggler.removeTweens(backgroundDisplay);
	exchangeManager.removeEventListener(Event.COMPLETE, exchangeManager_completeHandler);
	timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
	removeChildren(0, -1, true);
	backgroundDisplay = null;
	iconDisplay = null;
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