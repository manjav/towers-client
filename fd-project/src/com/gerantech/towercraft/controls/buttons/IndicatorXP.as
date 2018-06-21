package com.gerantech.towercraft.controls.buttons 
{
	import com.gerantech.towercraft.controls.texts.ShadowLabel;
/**
* ...
* @author Mansour Djawadi
*/
public class IndicatorXP extends Indicator 
{
private var levelDisplay:com.gerantech.towercraft.controls.texts.ShadowLabel;

public function IndicatorXP(direction:String="ltr", resourceType:int=0, hasProgressbar:Boolean=false, hasIncreaseButton:Boolean=true) 
{
	super(direction, resourceType, hasProgressbar, hasIncreaseButton);
}
override protected function initialize():void
{
	super.initialize();
	
	levelDisplay = new ShadowLabel("12", 0x444444, 1, "center", null, false, null, 0.9);
	levelDisplay.layoutData = iconDisplay.layoutData;
	levelDisplay.width = iconDisplay.width;
	addChild(levelDisplay);
}
}
}