package com.gerantech.towercraft.views.decorators 
{
import com.gerantech.towercraft.models.Assets;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;
import starling.core.Starling;
import starling.display.MovieClip;
import starling.display.Sprite;
/**
 * ...
 * @author Mansour Djawadi
 */
public class LightRay extends Sprite
{
private var timeoutId:uint;
public var image:MovieClip;
public function LightRay()
{
	image = new MovieClip(Assets.getTextures("lightray-"), 24);
	image.touchable = false;
	image.alignPivot("center", "bottom");
	image.touchable = false;
	//rayImage.scale = damage * 0.7;
	addChild(image);
	
	visible = false;
	touchable = false;
}

public function show(rotation:Number, height:Number):void 
{
	this.visible = true;
	this.rotation = rotation ;
	this.image.height = height;
	this.image.play();
	Starling.juggler.add(this.image);
	
	timeoutId = setTimeout(hide, 100);
}

private function hide():void 
{
	clearTimeout(timeoutId);
	Starling.juggler.remove(this.image);
	this.image.stop();
	this.visible = false;
}
override public function dispose():void
{
	hide();
	super.dispose();
}
}
}