package com.gerantech.towercraft.controls.items.exchange
{
import com.gerantech.towercraft.controls.buttons.ExchangeButton;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.controls.overlays.TutorialArrow;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;
import dragonBones.starling.StarlingArmatureDisplay;
import feathers.controls.text.BitmapFontTextRenderer;
import feathers.layout.AnchorLayoutData;
import feathers.text.BitmapFontTextFormat;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;
import starling.display.BlendMode;
import starling.events.Event;

public class ExchangeBookItemRenderer extends ExchangeBaseItemRenderer
{
private var _state:int = -2;
private var labelDisplay:RTLLabel;
private var timeDisplay:BitmapFontTextRenderer;
private var buttonDisplay:ExchangeButton;
private var chestArmature:StarlingArmatureDisplay;
private var tutorialArrow:TutorialArrow;
private var timeoutId:uint;

public function ExchangeBookItemRenderer(){}
override protected function commitData():void
{
	if( index < 0 || _data == null )
		return;
	skin.blendMode = BlendMode.ADD;
	super.commitData();
	if( firstCommit )
		firstCommit = false;
	
	if( buttonDisplay == null && exchange.category == ExchangeType.C110_BATTLES )
	{
		buttonDisplay = new ExchangeButton();
		buttonDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding, NaN, 0);
		buttonDisplay.height = 80 * appModel.scale;
	}
	
	if( chestArmature == null || chestArmature.armature.name != "book-" + exchange.outcome )
	{
		if( chestArmature != null )
			chestArmature.removeFromParent(true);
		chestArmature = OpenBookOverlay.factory.buildArmatureDisplay("book-" + exchange.outcome);
		chestArmature.scale = appModel.scale * 0.85;
		chestArmature.x = width * 0.5;
		chestArmature.y = height * 0.45;
	}
	updateElements();
	addChild(chestArmature);
	if( buttonDisplay != null )
		addChild(buttonDisplay);
	tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorialManager_finishHandler);
}

private function tutorialManager_finishHandler(event:Event):void
{
	if( exchange.type != ExchangeType.C101_FREE || event.data.name != "shop_start" || stage == null )
		return;
	tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorialManager_finishHandler);
	showTutorArrow();
}

private function timeManager_changeHandler(event:Event):void
{
	updateElements();
	updateCounter();
}
private function updateElements():void
{
	if(	_state == exchange.getState(timeManager.now) )
		return;
	_state = exchange.getState(timeManager.now);

	timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
	if( timeDisplay != null )
		timeDisplay.visible = _state == ExchangeItem.CHEST_STATE_BUSY;
	if( _state == ExchangeItem.CHEST_STATE_WAIT )
	{
		if( buttonDisplay != null )
		{
			buttonDisplay.count = ExchangeType.getKeyRequierement(exchange.outcome);
			buttonDisplay.style = "normal";
			buttonDisplay.type = ResourceType.KEY;
		}
		skin.setTextureForState(STATE_NORMAL, appModel.theme.itemRendererDisabledSkinTexture);
	}
	else if( _state == ExchangeItem.CHEST_STATE_BUSY )
	{
		updateCounter();
		timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
		if( buttonDisplay != null )
		{
			buttonDisplay.type = ResourceType.CURRENCY_HARD;
			buttonDisplay.style = "neutral";
		}
		skin.setTextureForState(STATE_NORMAL, appModel.theme.itemRendererDisabledSkinTexture);
	}
	else if( _state == ExchangeItem.CHEST_STATE_READY )
	{
		if( buttonDisplay != null )
		{
			buttonDisplay.count = -1;
			buttonDisplay.type = -1;
		}
		skin.setTextureForState(STATE_NORMAL, appModel.theme.itemRendererSelectedSkinTexture);
	}
	
	skin.alpha = _state == ExchangeItem.CHEST_STATE_BUSY ? 0.5 : 1;
	skin.defaultTexture = skin.getTextureForState(STATE_NORMAL);
	updateArmature();
}

private function updateCounter():void
{
	if( exchange.getState(timeManager.now) != ExchangeItem.CHEST_STATE_BUSY )
		return;
	if( timeDisplay == null )
	{
		timeDisplay = new BitmapFontTextRenderer();//imageDisplay.width, imageDisplay.width/2, "");
		timeDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 50 * appModel.scale, 0xFFFFFF, "center")
		timeDisplay.layoutData = new AnchorLayoutData(
		exchange.category == ExchangeType.C110_BATTLES ? padding * 0.1 : NaN,
		NaN, exchange.category == ExchangeType.C110_BATTLES ? NaN : padding * 2, NaN, 0);
	}
	var t:uint = uint(exchange.expiredAt - timeManager.now);//trace(index, t)
	timeDisplay.text = "< " + StrUtils.toTimeFormat(t);
	addChild(timeDisplay);
	
	if( buttonDisplay != null )
		buttonDisplay.count = exchanger.timeToHard(t);			
}

private function updateArmature():void
{
	if( chestArmature == null)
		return;

	clearTimeout(timeoutId);
	if( _state == ExchangeItem.CHEST_STATE_READY )
		timeoutId = setTimeout(chestArmature.animation.gotoAndPlayByTime, Math.random() * 2000, "wait", 0, 100);
	else
		chestArmature.animation.gotoAndStopByProgress("fall-closed", 1);
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

override public function dispose():void
{
	timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
	clearTimeout(timeoutId);
	super.dispose();
}
}
}