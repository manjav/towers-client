package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.groups.Devider;
import com.gerantech.towercraft.models.vo.BattleData;
import com.gt.towers.constants.ResourceType;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.SFSArray;

import flash.utils.setTimeout;

import feathers.controls.AutoSizeMode;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;

import starling.display.DisplayObject;
import starling.events.Event;

public class EndOverlay extends BaseOverlay
{
public var score:int;
public var tutorialMode:Boolean;
protected var rewards:ISFSArray;
protected var initialingCompleted:Boolean;
protected var padding:int;
protected var battleData:BattleData;
protected var showAdOffer:Boolean;

public function EndOverlay(score:int, rewards:ISFSArray, tutorialMode:Boolean=false)
{
	super();
	this.score = score;
	this.rewards = rewards;
	this.tutorialMode = tutorialMode;
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
	var overlay:Devider = new Devider(appModel.battleFieldView.battleData.isLeft?0x000000:(score>0?0x000099:0x990000));
	overlay.alpha = 0.4;
	overlay.width = stage.width;
	overlay.height = stage.height * 3;
	return overlay;
}
protected function get keyExists():Boolean
{
	for( var i:int = 0; i < rewards.size(); i++ ) 
		if( rewards.getSFSObject(i).getInt("t") == ResourceType.KEY )
			return true;
	return false;
}

protected function getRewardsCollection():ListCollection
{
	var rw:Array = SFSArray(rewards).toArray();
	var ret:ListCollection = new ListCollection();
	for ( var i:int=0; i<rw.length; i++ )
		if( rw[i].t == ResourceType.POINT || rw[i].t == ResourceType.KEY || rw[i].t == ResourceType.CURRENCY_SOFT )
			ret.addItem( rw[i] );
	
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