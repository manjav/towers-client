package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.groups.Devider;
import com.gerantech.towercraft.managers.ParticleManager;
import com.gerantech.towercraft.models.vo.BattleData;
import com.gt.towers.constants.ResourceType;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import feathers.controls.AutoSizeMode;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.extensions.PDParticleSystem;

public class EndOverlay extends BaseOverlay
{
public var inTutorial:Boolean;
public var winRatio:Number = 1;
public var playerIndex:int;
public var score:int;
public var rewards:ISFSArray;

protected var initialingCompleted:Boolean;
protected var padding:int;
protected var battleData:BattleData;
protected var showAdOffer:Boolean;
private var particle:PDParticleSystem;
private var timeoutId:uint;

public function EndOverlay(playerIndex:int, rewards:ISFSArray, inTutorial:Boolean=false)
{
	super();
	this.rewards = rewards;
	this.inTutorial = inTutorial;
	this.playerIndex = playerIndex;
	if( playerIndex > -1 )
	{
		this.score = rewards.getSFSObject(playerIndex).getInt("score");
		winRatio = this.score / rewards.getSFSObject(playerIndex == 0?1:0).getInt("score");
	}
}

override protected function initialize():void
{
	closeOnStage = false;
	autoSizeMode = AutoSizeMode.STAGE;
	super.initialize();
	overlay.touchable = false;
	layout = new AnchorLayout();
	padding = 48 * appModel.scale;
	
	battleData = appModel.battleFieldView.battleData;

	appModel.sounds.addAndPlaySound("outcome-" + (winRatio >= 1?"victory":"defeat"));
	initialingCompleted = true;
	
	timeoutId = setTimeout(showParticle, 800);
}

private function showParticle():void 
{
	if ( !appModel.battleFieldView.battleData.isLeft && playerIndex != -1 )
	{
		particle = ParticleManager.getParticle(winRatio >= 1 ? "scrap" : "fire");
		particle.x = stage.stageWidth * 0.5;
		particle.y = winRatio >= 1 ? -stage.stageHeight*0.1 : stage.stageHeight * 1.05;
		particle.start();
		Starling.juggler.add(particle);
		addChildAt(particle, 1);
	}
}


override protected function defaultOverlayFactory():DisplayObject
{
	var overlay:Devider = new Devider(appModel.battleFieldView.battleData.isLeft || playerIndex == -1 ? 0x000000 : (winRatio > 1 ? 0x002211 : 0x331300));
	overlay.alpha = 0.7;
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

override public function dispose():void 
{
	clearTimeout(timeoutId);
	if( particle != null )
	{
		particle.stop();
		Starling.juggler.remove(particle);
	}
	super.dispose();
}
}
}