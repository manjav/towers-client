package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.BookReward;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.models.AppModel;
import com.gt.towers.exchanges.ExchangeItem;
import dragonBones.events.EventObject;
import dragonBones.objects.DragonBonesData;
import dragonBones.starling.StarlingArmatureDisplay;
import dragonBones.starling.StarlingEvent;
import dragonBones.starling.StarlingFactory;
import feathers.controls.AutoSizeMode;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.utils.getTimer;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.Event;

public class OpenBookOverlay extends BaseOverlay
{
public static var factory: StarlingFactory;
public static var dragonBonesData:DragonBonesData;
public var item:ExchangeItem;

private var type:int;
private var rewardKeys:Vector.<int>;
private var rewardItems:Vector.<BookReward>;
private var animation:StarlingArmatureDisplay ;
private var collectedItemIndex:int = 0;
private var buttonOverlay:SimpleLayoutButton;
private var readyToWait:Boolean;
private var lastTappedTime:int;
private var frequentlyTapped:int;

public function OpenBookOverlay(type:int)
{
	super();
	this.type = type;
	createFactory();
}

public static function createFactory():void
{
	if( factory != null )
		return;
	factory = new StarlingFactory();
	dragonBonesData = factory.parseDragonBonesData(AppModel.instance.assets.getObject("books_ske"));
	factory.parseTextureAtlasData(AppModel.instance.assets.getObject("books_tex"), AppModel.instance.assets.getTexture("books_tex"));
}			

override protected function initialize():void
{
	super.initialize();
	autoSizeMode = AutoSizeMode.STAGE;
	
	layout = new AnchorLayout();
	overlay.alpha = 0;
	Starling.juggler.tween(overlay, 0.3, {
		alpha:1,
		onStart:transitionInStarted,
		onComplete:transitionInCompleted
	});
}
override protected function defaultOverlayFactory():DisplayObject
{
	var overlay:DisplayObject = super.defaultOverlayFactory();
	overlay.alpha = 1;
	overlay.touchable = true;
	return overlay;
}

override protected function addedToStageHandler(event:Event):void
{
	super.addedToStageHandler(event);
	closeOnStage = false;
	if( dragonBonesData == null )
		return;
	
	appModel.sounds.setVolume("main-theme", 0.3);
	
	animation = factory.buildArmatureDisplay("book-"+type);
	animation.touchable = false;
	animation.x = stage.stageWidth * 0.5;
	animation.y = stage.stageHeight * 0.85;
	animation.scale = appModel.scale * 2;
	animation.addEventListener(EventObject.COMPLETE, openAnimation_completeHandler);
	animation.addEventListener(EventObject.SOUND_EVENT, openAnimation_soundEventHandler);
	animation.animation.gotoAndPlayByTime("fall", 0, 1);
	addChild(animation);
}

public function setItem(item:ExchangeItem) : void
{
	buttonOverlay = new SimpleLayoutButton();
	buttonOverlay.addEventListener(Event.TRIGGERED, buttonOverlay_triggeredHandler);
	buttonOverlay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChild(buttonOverlay);
	
	this.item = item;
	rewardItems = new Vector.<BookReward>();
	rewardKeys = item.outcomes.keys();
	if( readyToWait )
		animation.animation.gotoAndPlayByTime("wait", 0, -1);
}

private function openAnimation_soundEventHandler(event:StarlingEvent):void
{
	appModel.sounds.addAndPlaySound(event.eventObject.name);
}

protected function openAnimation_completeHandler(event:StarlingEvent):void
{
	if( event.eventObject.animationState.name == "fall" )
	{
		readyToWait = true;
		if( item != null )
			animation.animation.gotoAndPlayByTime("wait", 0, -1);
	}
	else if( event.eventObject.animationState.name == "hide" )
	{
		close();
	}
}

protected function buttonOverlay_triggeredHandler():void
{
	var t:int = getTimer();
	if ( t - lastTappedTime < 500 )
	{
		lastTappedTime = t + 0;//wait for tap
		frequentlyTapped ++;
		if( frequentlyTapped == 2 )// if tripple tapped
		{
			lastTappedTime = t + 2000;// wait for open all
			openAll();
		}
		return;
	}
	
	frequentlyTapped = 0;
	lastTappedTime = t + 0;
	
	grabAllRewards();
	if( collectedItemIndex < item.outcomes.keys().length )
	{
		animation.animation.gotoAndPlayByTime(collectedItemIndex < rewardKeys.length - 1?"open":"open", 0, 1);
		showReward();
	}
	else if( collectedItemIndex == rewardKeys.length + 1 )
	{
		setTimeout(animation.animation.gotoAndPlayByTime, 500, "hide", 0, 1);
		hideAllRewards();
	}
	collectedItemIndex ++;
}

private function openAll():void 
{
	for ( var i:int=0; i<rewardItems.length; i++ )
		Starling.juggler.removeTweens( rewardItems[i] );

	while ( collectedItemIndex < rewardKeys.length )
	{
		showReward(false);
		collectedItemIndex ++;
	}
	if( collectedItemIndex == rewardKeys.length )
	{
		collectedItemIndex = rewardKeys.length + 1;
		grabAllRewards(true);
	}
}

private function hideAllRewards():void
{
	for(var i:int=0; i<rewardItems.length; i++)
		Starling.juggler.tween(rewardItems[i], 0.4, {delay:0.1 * i, y:0, alpha:0, transition:Transitions.EASE_IN_BACK});
}
private function grabAllRewards(force:Boolean=false):void
{
	for(var i:int=0; i<rewardItems.length; i++)
		grabReward(rewardItems[i], force, 0.3 + i * 0.1);
}

private function showReward(open:Boolean = true) : void
{
	var reward:BookReward = new BookReward(collectedItemIndex, rewardKeys[collectedItemIndex], item.outcomes.get(rewardKeys[collectedItemIndex]));
	reward.y = stage.height * 0.8;
	rewardItems[collectedItemIndex] = reward;
	addChild(reward);
	
	if( !open )
		return;
	
	reward.scale = 0;
	reward.x = stage.width * 0.5;
	Starling.juggler.tween(reward, 0.5, {delay:0.3, scale:1, x:stage.width * 0.5, y:stage.height * 0.5, transition:Transitions.EASE_OUT_BACK, onComplete:reward.showDetails});
	return;
}

private function grabReward(reward:BookReward, force:Boolean=false, time:Number=0.5):void
{
	if( reward == null || ( reward.state != 1 && !force ) )
		return;
	reward.hideDetails();
	var scal:Number = 0.8;
	var numCol:int = rewardKeys.length == 2 || rewardKeys.length == 4 ? 2 : 3;
	var paddingH:int = (appModel.isLTR?reward._width * 0.4:0) * scal + 80 * appModel.scale;
	var paddingV:int = reward._height * 0.5 * scal + 80 * appModel.scale;
	var cellH:int = ((stage.stageWidth - reward._width * 0.4 * scal - paddingH * 2) / (numCol - 1));
	Starling.juggler.tween(reward, time, {scale:scal, x:(reward.index % numCol) * cellH + paddingH, y:Math.floor(reward.index / numCol) * reward._height * scal + paddingV, transition:Transitions.EASE_OUT_BACK});
}

override public function dispose():void
{
	appModel.sounds.setVolume("main-theme", 1);
	buttonOverlay.removeEventListener(Event.TRIGGERED, buttonOverlay_triggeredHandler);
	animation.removeEventListener(EventObject.SOUND_EVENT, openAnimation_soundEventHandler);
	animation.removeEventListener(dragonBones.events.EventObject.COMPLETE, openAnimation_completeHandler);
	super.dispose();
}
}
}