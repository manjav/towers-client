package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.BookReward;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.views.effects.MortalParticleSystem;
import com.gt.towers.utils.maps.IntIntMap;
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

public class OpenBookOverlay extends EarnOverlay
{
public static var factory: StarlingFactory;
public static var dragonBonesData:DragonBonesData;

private var rewardKeys:Vector.<int>;
private var rewardItems:Vector.<BookReward>;
private var bookArmature:StarlingArmatureDisplay ;
private var shineArmature:StarlingArmatureDisplay;
private var collectedItemIndex:int = 0;
private var buttonOverlay:SimpleLayoutButton;
private var readyToWait:Boolean;
private var lastTappedTime:int;
private var frequentlyTapped:int;

public function OpenBookOverlay(type:int)
{
	super(type);
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

static public function getBookScale(type:int):Number
{
	return 0.9 + ((type % 10) / 5 ) * 0.2;
}

override protected function initialize():void
{
	super.initialize();
	appModel.navigator.activeScreen.visible = false;// hide back items for better perfomance
	autoSizeMode = AutoSizeMode.STAGE;
	
	layout = new AnchorLayout();
	overlay.alpha = 0;
	Starling.juggler.tween(overlay, 0.3, {
		alpha:1,
		onStart:transitionInStarted,
		onComplete:transitionInCompleted
	});
}
override protected function defaultOverlayFactory(color:uint = 0, alpha:Number = 0.4):DisplayObject
{
	var overlay:DisplayObject = super.defaultOverlayFactory(0x223333, 1);
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
	
	bookArmature = factory.buildArmatureDisplay("book-" + type);
	bookArmature.touchable = false;
	bookArmature.x = stage.stageWidth * 0.5;
	bookArmature.y = stage.stageHeight * 0.5;
	bookArmature.scale = appModel.scale * 2;
	bookArmature.addEventListener(EventObject.COMPLETE, openAnimation_completeHandler);
	bookArmature.addEventListener(EventObject.SOUND_EVENT, openAnimation_soundEventHandler);
	bookArmature.animation.gotoAndPlayByTime("appear", 0, 1);
	addChild(bookArmature);
	Starling.juggler.tween(bookArmature, 0.4, {delay:0.2, y:stage.stageHeight * 0.85, transition:Transitions.EASE_IN});
	
	shineArmature = factory.buildArmatureDisplay("shine");
	shineArmature.touchable = false;
	shineArmature.scale = appModel.scale * 3;
	shineArmature.x = 170 * appModel.scale;
}

override public function set outcomes(value:IntIntMap):void 
{
	super.outcomes = value;
	buttonOverlay = new SimpleLayoutButton();
	buttonOverlay.addEventListener(Event.TRIGGERED, buttonOverlay_triggeredHandler);
	buttonOverlay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChild(buttonOverlay);
	
	rewardItems = new Vector.<BookReward>();
	rewardKeys = outcomes.keys();
	if( readyToWait )
	bookArmature.animation.gotoAndPlayByTime("wait", 0, -1);
}

private function openAnimation_soundEventHandler(event:StarlingEvent):void
{
	appModel.sounds.addAndPlaySound(event.eventObject.name);
}

protected function openAnimation_completeHandler(event:StarlingEvent):void
{
	if( event.eventObject.animationState.name == "appear" )
	{
		readyToWait = true;
		if( outcomes != null )
			bookArmature.animation.gotoAndPlayByTime("wait", 0, -1);
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
	if( collectedItemIndex < outcomes.keys().length )
	{
		bookArmature.animation.gotoAndPlayByTime("open", 0, 1);
		
		// expload
		var explode:MortalParticleSystem = new MortalParticleSystem("explode");
		explode.scaleY = 0.8;
		explode.speedVariance = 0;
		explode.emitAngle = 0.8;
		explode.emitAngleVariance = 2;
		setTimeout(bookArmature.addChildAt, 200, explode, 3);
		
		showReward();
	}
	else if( collectedItemIndex == rewardKeys.length + 1 )
	{
		setTimeout(bookArmature.animation.gotoAndPlayByTime, 400, "hide", 0, 1);
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
		grabReward(rewardItems[i], force, i * 0.1);
}

private function showReward(open:Boolean = true) : void
{
	var reward:BookReward = new BookReward(collectedItemIndex, rewardKeys[collectedItemIndex], outcomes.get(rewardKeys[collectedItemIndex]));
	reward.scale = 0.02;
	reward.x = stage.width * 0.62;
	reward.y = stage.height * 0.82;
	rewardItems[collectedItemIndex] = reward;
	addChild(reward);
	
	if( !open )
		return;
	
	// shine
	shineArmature.animation.gotoAndPlayByTime("rotate", 0, 10);
	reward.addChildAt(shineArmature, 0);
	
	// expload
	var explode:MortalParticleSystem = new MortalParticleSystem("explode", 0.5);
	explode.x = 170 * appModel.scale;
	reward.addChildAt(explode, 1);
	
	Starling.juggler.tween(reward, 0.5, {delay:0.5, scale:1, x:stage.width * 0.5, y:stage.height * 0.5, transition:Transitions.EASE_OUT_BACK, onComplete:reward.showDetails});
}

private function grabReward(reward:BookReward, force:Boolean=false, delay:Number=0):void
{
	if( reward == null || ( reward.state != 1 && !force ) )
		return;
	reward.hideDetails();
	shineArmature.removeFromParent();
	var scal:Number = 0.8;
	var numCol:int = rewardKeys.length == 2 || rewardKeys.length == 4 ? 2 : 3;
	var paddingH:int = 80 * appModel.scale;
	var paddingV:int = reward._height * 0.5 * scal + 80 * appModel.scale;
	var cellH:int = ((stage.stageWidth - reward._width * 0.4 * scal - paddingH * 2) / (numCol - 1));
	Starling.juggler.tween(reward, 0.5, {delay:delay, scale:scal, x:(reward.index % numCol) * cellH + paddingH, y:Math.floor(reward.index / numCol) * reward._height * scal + paddingV, transition:Transitions.EASE_OUT_BACK});
}

override public function dispose():void
{
	appModel.navigator.activeScreen.visible = true;
	appModel.sounds.setVolume("main-theme", 1);
	buttonOverlay.removeEventListener(Event.TRIGGERED, buttonOverlay_triggeredHandler);
	bookArmature.removeEventListener(EventObject.SOUND_EVENT, openAnimation_soundEventHandler);
	bookArmature.removeEventListener(dragonBones.events.EventObject.COMPLETE, openAnimation_completeHandler);
	super.dispose();
}
}
}