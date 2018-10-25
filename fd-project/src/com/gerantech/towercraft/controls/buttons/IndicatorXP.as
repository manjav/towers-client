package com.gerantech.towercraft.controls.buttons 
{
	import com.gerantech.towercraft.controls.texts.ShadowLabel;
	import com.gt.towers.constants.ResourceType;
/**
* ...
* @author Mansour Djawadi
*/
public class IndicatorXP extends Indicator 
{
private var levelDisplay:com.gerantech.towercraft.controls.texts.ShadowLabel;

public function IndicatorXP(direction:String="ltr") 
{
	super(direction, ResourceType.R1_XP, true, false);
}
override protected function initialize():void
{
	super.initialize();
	if( value == -0.1 )
		value = 0;
	levelDisplay = new ShadowLabel(player.get_level(value).toString(), 0x444444, 1, "center", null, false, null, 0.9);
	levelDisplay.layoutData = iconDisplay.layoutData;
	levelDisplay.width = iconDisplay.width;
	addChild(levelDisplay);
}
override public function setData(minimum:Number, value:Number, maximum:Number):void
{
	var level:int = player.get_level(value);
	super.setData(game.levels[level - 1], value, game.levels[level]);
	if( levelDisplay != null )
		levelDisplay.text = level.toString();
}
}
}