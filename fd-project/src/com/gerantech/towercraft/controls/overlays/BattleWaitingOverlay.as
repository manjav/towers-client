package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.groups.Devider;
import com.gerantech.towercraft.controls.headers.BattleHeader;
import com.gerantech.towercraft.controls.screens.FactionsScreen;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.smartfoxserver.v2.core.SFSEvent;
import dragonBones.starling.StarlingArmatureDisplay;
import feathers.controls.AutoSizeMode;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.Event;

public class BattleWaitingOverlay extends BaseOverlay
{
public var ready:Boolean;
public var cancelable:Boolean = true;

private var padding:int;
private var cancelButton:CustomButton;
private var waitDisplay:RTLLabel;
private var league:StarlingArmatureDisplay;

public function BattleWaitingOverlay(cancelable:Boolean)
{
	super();
	padding = 48 * appModel.scale;
	this.cancelable = cancelable;
}

override protected function initialize():void
{
	closeOnStage = false;
	autoSizeMode = AutoSizeMode.STAGE;
	super.initialize();
	overlay.alpha = 1;

	league = FactionsScreen.animFactory.buildArmatureDisplay("arena-"+Math.min(8, player.get_arena(0)));
	league.animation.gotoAndPlayByTime("selected", 0, 50);
	league.pivotX = league.pivotY = 0
	league.x = 540 * appModel.scale;
	league.y = 510 * appModel.scale;
	league.scale = 0.2;
	league.alpha = 0;
	Starling.juggler.tween(league, 0.5, {delay:0.2, scale:0.6, alpha:1, transition:Transitions.EASE_OUT_BACK, onComplete:goUp});
	addChild(league);
	function goUp():void { Starling.juggler.tween(league, 2, {y:460*appModel.scale, transition:Transitions.EASE_IN_OUT, onComplete:goDown}); }
	function goDown():void { Starling.juggler.tween(league, 2, {y:510*appModel.scale, transition:Transitions.EASE_IN_OUT, onComplete:goUp}); }
	
	if( cancelable )
	{
		cancelButton = new CustomButton();
		cancelButton.label = loc("cancel_button");
		cancelButton.alignPivot();
		cancelButton.style = "danger";
		cancelButton.width = 240 * appModel.scale;
		cancelButton.x = stage.stageWidth * 0.5 ;
		cancelButton.y = stage.stageHeight * 0.75;
		cancelButton.scale = 0;
		cancelButton.addEventListener(Event.TRIGGERED, cancelButton_triggeredHandler);
		addChild(cancelButton);
		Starling.juggler.tween(cancelButton, 0.5, {delay:1.5, scale:1, transition:Transitions.EASE_OUT_BACK});	
	}
	
	waitDisplay = new RTLLabel(loc("tip_over"), 1, "center", null, false, null, 1.2);
	waitDisplay.x = padding;
	waitDisplay.y = stage.stageHeight * 0.55;
	waitDisplay.alpha = 0;
	waitDisplay.width = stage.stageWidth-padding*2;
	waitDisplay.touchable = false;
	addChild(waitDisplay);
	Starling.juggler.tween(waitDisplay, 0.5, {delay:2, alpha:1, y:stage.stageHeight * 0.6, transition:Transitions.EASE_OUT_BACK});
	
	var tipDisplay:RTLLabel = new RTLLabel(loc("tip_"+Math.min(player.get_arena(0), 2)+"_"+Math.floor(Math.random()*10)), 1, "justify", null, true, "center", 0.9);
	tipDisplay.x = padding;
	tipDisplay.y = stage.stageHeight - padding*5;
	tipDisplay.width = stage.stageWidth-padding*2;
	tipDisplay.touchable = false;
	addChild(tipDisplay);
	
	setTimeout(gotoReady, ready?0:1000);
}

private function gotoReady():void
{
	ready = true;
	if( !initializingStarted )
		return;
	
	dispatchEventWith(Event.READY);
}

private function cancelButton_triggeredHandler(event:Event):void
{
	cancelButton.touchable = false;
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_cancelResponseHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.CANCEL_BATTLE);
}

protected function sfs_cancelResponseHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.CANCEL_BATTLE )
		return;
	
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_cancelResponseHandler);
	appModel.navigator.popToRootScreen();
	cancelButton.touchable = false;
	setTimeout(disappear, 400);
}

public function disappear():void
{
	Starling.juggler.removeTweens(waitDisplay);
	Starling.juggler.tween(overlay, 0.8, {delay:1, alpha:0});
	Starling.juggler.tween(league, 0.3, {alpha:0, transition:Transitions.EASE_IN_BACK});
	if( cancelButton != null )
	{
		cancelButton.touchable = false;
		Starling.juggler.tween(cancelButton, 0.5, {delay:0.1, scale:0, transition:Transitions.EASE_IN_BACK});
	}
	if( waitDisplay != null )
		Starling.juggler.tween(waitDisplay, 0.4, {alpha:0, y:waitDisplay.y-height*0.1, transition:Transitions.EASE_IN_BACK});
	setTimeout(close, 800, true)
}
override protected function defaultOverlayFactory():DisplayObject
{
	var overlay:Devider = new Devider(0);
	overlay.width = stage.stageWidth;
	overlay.height = stage.stageHeight;
	return overlay;
}
}
}