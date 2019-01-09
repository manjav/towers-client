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

public function IndicatorXP(direction:String="ltr", autoApdate:Boolean = true) 
{
	super(direction, ResourceType.XP, true, false, autoApdate);
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

override public function setData(minimum:Number, value:Number, maximum:Number, changeDuration:Number = 0):void
{
	if( value == -1 )
		value = player.get_xp();
	var level:int = player.get_level(value);//trace(value, level, player.resources.toString())
	super.setData(game.levels[level - 1], value, game.levels[level], changeDuration);
	if( levelDisplay != null )
		levelDisplay.text = level.toString();
}
}
}