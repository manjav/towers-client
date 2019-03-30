package com.gerantech.towercraft.controls.toasts 
{
	import feathers.layout.AnchorLayout;
/**
* @author Mansour Djawadi
*/
public class EmoteToast extends BaseToast 
{

public function EmoteToast() 
{
	super();
	this.toastHeight = 112;
	this.animationMode = BaseToast.ANIMATION_MODE_BOTTOM;
}
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	
	//var background:SimpleLayoutButton = new SimpleLayoutButton();
	//background.addEventListener(Event.TRIGGERED, background_triggeredHandler);
	//background.backgroundSkin = new Quad(1, 1, 0);
	//background.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	//background.alpha = 0.8;
	//addChild(background);
}
}
}