package com.gerantech.towercraft.controls
{
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.views.effects.MortalParticleSystem;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;

public class StarCheck extends Image
{
private var actived:Boolean;
private var size:int = 200;
public function StarCheck(actived:Boolean = false, size:int = 200)
{
	super( Assets.getTexture("gold-key" + (actived ? "" : "-off")));
    this.touchable = false;
	this.actived = actived; 
	pivotX = this.width * 0.5
	pivotY = this.height * 0.5
	width = height = this.size = size;
}

public function active() : void
{
	if( actived )
		return;
	
	var pd:MortalParticleSystem = new MortalParticleSystem("explode", 0.1);
	pd.x = x;
	pd.y = y;
	pd.speed *= 5;
	pd.lifespan *= 0.1;
	//pd.x = pd.y = width * 0.5;
	parent.addChildAt(pd, parent.getChildIndex(this));
	
	texture = Assets.getTexture("gold-key");
	width = height = size * 2;
	Starling.juggler.tween(this, 0.6, {width:size, height:size, transition:Transitions.EASE_OUT_BACK});
}
}
}