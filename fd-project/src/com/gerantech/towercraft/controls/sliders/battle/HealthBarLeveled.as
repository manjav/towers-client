package com.gerantech.towercraft.controls.sliders.battle 
{
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.views.BattleFieldView;
import feathers.controls.ImageLoader;
import feathers.controls.text.BitmapFontTextRenderer;
import feathers.layout.AnchorLayoutData;
import starling.display.Image;
/**
* ...
* @author Mansour Djawadi
*/
public class HealthBarLeveled extends HealthBar 
{
private var level:int;
private var levelDisplay:Image;
public function HealthBarLeveled(filedView:BattleFieldView, troopType:int, level:int=1, initValue:Number=0, initMax:Number=1) 
{
	super(filedView, troopType, initValue, initMax);
	this.level = level;

	levelDisplay = new Image(AppModel.instance.assets.getTexture("sliders/" + troopType + "/level-" + level));
	levelDisplay.pivotX = levelDisplay.width * 0.5;
	levelDisplay.touchable = false;
	levelDisplay.visible = value < maximum || troopType > 0;
	filedView.guiImagesContainer.addChild(levelDisplay);
}

override public function setPosition(x:Number, y:Number) : void
{
	super.setPosition(x, y);
	if( levelDisplay != null )
	{
		levelDisplay.x = x + (value < maximum ? 0 :width * 0.5) - levelDisplay.width;
		levelDisplay.y = y - 8;
	}
}

override public function set value(v:Number) : void
{
	if( super.value == v )
		return;
	super.value = v;
	
	var visible:Boolean = v < maximum || troopType > 0;
	if( sliderFillDisplay != null )
		sliderFillDisplay.visible = visible;
	if( sliderBackDisplay != null )
		sliderBackDisplay.visible = visible;
	if( levelDisplay != null )
		levelDisplay.visible = visible;
}

override public function dispose() : void 
{
	super.dispose();
	if( levelDisplay != null )
		levelDisplay.removeFromParent(true);
}

public function set alpha(value:Number):void 
{
}
}
}