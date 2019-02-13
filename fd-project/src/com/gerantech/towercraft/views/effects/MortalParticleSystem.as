package com.gerantech.towercraft.views.effects 
{
import com.gerantech.towercraft.managers.ParticleManager;
import com.gerantech.towercraft.models.AppModel;
import flash.utils.setTimeout;
import starling.events.Event;
import starling.animation.Tween;
import starling.core.Starling;
import starling.extensions.PDParticleSystem;
import starling.textures.Texture;

/**
* ...
* @author Mansour Djawadi
*/
public class MortalParticleSystem extends PDParticleSystem 
{

public function MortalParticleSystem(name:String, duration:Number = 0.1, autoStart:Boolean = true ) 
{
	super(ParticleManager.getParticleData(name), ParticleManager.getTextureByBitmap(name));
	startSize = startSize * 4;
	touchable = false;
	if( autoStart )
		start(duration);
}

override public function start(duration:Number = 1.79769313486232E+308):void 
{
	addEventListener(Event.COMPLETE, completeHandler);
	super.start(duration);
	Starling.juggler.add(this);
}

protected function completeHandler(e:Event):void 
{
	removeEventListener(Event.COMPLETE, completeHandler);
	remove(false);
}

public function remove(clear:Boolean):void 
{
	removeEventListener(Event.COMPLETE, completeHandler);
	if( clear )
		stop(true);
	Starling.juggler.remove(this);
	removeFromParent(true);
}
}
}