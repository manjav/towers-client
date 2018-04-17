package com.gerantech.towercraft.views.decorators 
{
import com.gerantech.towercraft.models.Assets;
import starling.core.Starling;
import starling.display.MovieClip;
import starling.display.Sprite;
/**
 * ...
 * @author Mansour Djawadi
 */
public class LightRay extends Sprite
{
public var image:MovieClip;
public function LightRay()
{
	image = new MovieClip(Assets.getTextures("lightray-"));
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
}

public function hide():void 
{
	Starling.juggler.remove(this.image);
	this.image.stop();
	this.visible = false;
}

}
}