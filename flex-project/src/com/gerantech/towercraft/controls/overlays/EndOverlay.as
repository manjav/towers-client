package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.Devider;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.BattleData;
import com.gt.towers.constants.ResourceType;
import com.smartfoxserver.v2.entities.data.ISFSArray;

import flash.utils.setTimeout;

import feathers.controls.AutoSizeMode;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.events.Event;

public class EndOverlay extends BaseOverlay
{
public var score:int;
public var tutorialMode:Boolean;
protected var playerIndex:int;
protected var rewards:ISFSArray;
protected var initialingCompleted:Boolean;
protected var padding:int;
protected var battleData:BattleData;
protected var showAdOffer:Boolean;

public function EndOverlay(playerIndex:int, rewards:ISFSArray, tutorialMode:Boolean=false)
{
	super();
	this.rewards = rewards;
	this.tutorialMode = tutorialMode;
	this.playerIndex = playerIndex;
	if( playerIndex > -1 )
		score = rewards.getSFSObject(playerIndex).getInt("score");
}

override protected function initialize():void
{
	closeOnStage = false;
	autoSizeMode = AutoSizeMode.STAGE;
	super.initialize();
	layout = new AnchorLayout();
	padding = 48 * appModel.scale;
	
	battleData = appModel.battleFieldView.battleData;

	appModel.sounds.addAndPlaySound("outcome-"+(score>0?"victory":"defeat"));
	initialingCompleted = true;
}

override protected function defaultOverlayFactory():DisplayObject
{
	var overlay:Devider = new Devider(appModel.battleFieldView.battleData.isLeft||playerIndex==-1?0x000000:(score>0?0x000099:0x990000));
	overlay.alpha = 0.4;
	overlay.width = stage.width;
	overlay.height = stage.height;
	return overlay;
}
protected function get keyExists():Boolean
{
	if( playerIndex == -1 )
		return false;
	
	var keys:Array = rewards.getSFSObject(playerIndex).getKeys();
	for( var i:int = 0; i < keys.length; i++)
		if( int(keys[i]) == ResourceType.KEY )
			return true;
	return false;
}

protected function getRewardsCollection(playerIndex:int):ListCollection
{
	var ret:ListCollection = new ListCollection();
	if( playerIndex == -1 )
		return ret;

	var keys:Array = rewards.getSFSObject(playerIndex).getKeys();
	for( var i:int = 0; i < keys.length; i++)
	{
		var key:int = int(keys[i])
		if( key == ResourceType.POINT || key == ResourceType.KEY || key == ResourceType.CURRENCY_SOFT )
			ret.push({t:key, c:rewards.getSFSObject(playerIndex).getInt(keys[i])});
	}
	return ret;
}

protected function buttons_triggeredHandler(event:Event):void
{
	if( CustomButton(event.currentTarget).name == "retry" )
	{
		dispatchEventWith(FeathersEventType.CLEAR, false, showAdOffer);
		setTimeout(close, 10);
		return;
	}
	close();
}
}
}