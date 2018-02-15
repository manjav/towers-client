package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.groups.Devider;
import com.gerantech.towercraft.controls.headers.BattleHeader;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.vo.BattleData;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSObject;

import flash.utils.setTimeout;

import feathers.controls.AutoSizeMode;
import feathers.controls.LayoutGroup;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.Event;

public class BattleStartOverlay extends BaseOverlay
{
public var ready:Boolean;
public var questIndex:int = 0;
public var cancelable:Boolean = true;
public var spectatingData:ISFSObject;

private var padding:int;
private var opponentLabel:ShadowLabel;

private var cancelButton:CustomButton;

private var waitDisplay:RTLLabel;
private var container:LayoutGroup;

private var opponentHeader:BattleHeader;

private var playerHeader:BattleHeader;

public function BattleStartOverlay(questIndex:int, cancelable:Boolean, spectatingData:ISFSObject = null)
{
	super();
	padding = 48 * appModel.scale;
	this.questIndex = questIndex;
	this.cancelable = cancelable;
	this.spectatingData = spectatingData;
}

override protected function initialize():void
{
	closeOnStage = false;
	autoSizeMode = AutoSizeMode.STAGE;
	super.initialize();
	overlay.alpha = 1;
	
	container = new LayoutGroup();
	container.layout = new AnchorLayout();
	container.x = padding;
	container.width = stage.stageWidth - padding * 2;
	container.height = stage.stageHeight;
	addChild(container);
	
	// opponent elements
	var axisName:String = spectatingData == null ? "???" : spectatingData.getSFSArray("players").getSFSObject(1).getText("n");
	opponentHeader = new BattleHeader(questIndex>=0?(loc("quest_label") + " " +(questIndex+1)):axisName, false);
	opponentHeader.layoutData = new AnchorLayoutData(300 * appModel.scale, 0, NaN, 0);
	container.addChild(opponentHeader);
	
	setTimeout(gotoReady, 1200);
		
	if( questIndex >= 0 )
		return;
	
	// player elements
	playerHeader = new BattleHeader(spectatingData==null ? player.nickName : spectatingData.getSFSArray("players").getSFSObject(0).getText("n"), true);
	playerHeader.width = padding * 16;
	playerHeader.layoutData = new AnchorLayoutData(800 * appModel.scale, 0, NaN, 0);
	container.addChild(playerHeader);

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
		Starling.juggler.tween(cancelButton, 0.5, {delay:0.5, scale:1, transition:Transitions.EASE_OUT_BACK});
	}
	
	waitDisplay = new RTLLabel(loc("tip_over"), 1, "center", null, false, null, 1.2);
	waitDisplay.x = padding;
	waitDisplay.y = stage.stageHeight * 0.55;
	waitDisplay.alpha = 0;
	waitDisplay.width = stage.stageWidth-padding*2;
	waitDisplay.touchable = false;
	addChild(waitDisplay);
	Starling.juggler.tween(waitDisplay, 0.5, {delay:2, alpha:1, y:stage.stageHeight*0.6, transition:Transitions.EASE_OUT_BACK});
	
	var tipDisplay:RTLLabel = new RTLLabel(loc("tip_"+Math.min(player.get_arena(0), 2)+"_"+Math.floor(Math.random()*10)), 1, "justify", null, true, "center", 0.9);
	tipDisplay.x = padding;
	tipDisplay.y = stage.stageHeight - padding*5;
	tipDisplay.width = stage.stageWidth-padding*2;
	tipDisplay.touchable = false;
	addChild(tipDisplay);
}

private function gotoReady():void
{
	ready = true;
	dispatchEventWith(Event.READY);
}

public function setData(battleData:BattleData):void
{
    if( battleData.map.isQuest )
    {
        setTimeout(disappear, 1000);        
        return;
    }

    if( questIndex < 0 )
        opponentHeader.labelDisplay.text = battleData.axis.getText("name");
    if( spectatingData == null )
        playerHeader.labelDisplay.text = battleData.allis.getText("name");
	
	if( cancelButton != null )
		cancelButton.touchable = false;
	//opponentHeader.scaleX = 0.5;
	//Starling.juggler.tween(opponentHeader, 0.3, {scaleX:1});
	setTimeout(disappear, 1000);
}

private function cancelButton_triggeredHandler(event:Event):void
{
	cancelButton.touchable = false;
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_canelResponseHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.CANCEL_BATTLE);
}

protected function sfs_canelResponseHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.CANCEL_BATTLE )
		return;
	
	appModel.navigator.popToRootScreen();
	setTimeout(disappear, 400);
}
public function disappear():void
{
	Starling.juggler.removeTweens(waitDisplay);
	Starling.juggler.tween(container, 0.6, {alpha:0, y:-padding*4, transition:Transitions.EASE_IN_BACK});
	Starling.juggler.tween(overlay, 0.3, {delay:0.5, alpha:0});
	if( cancelButton != null )
		Starling.juggler.tween(cancelButton, 0.5, {delay:0.1, scale:0, transition:Transitions.EASE_IN_BACK});
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