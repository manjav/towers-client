package com.gerantech.towercraft.controls.sliders.battle 
{
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import feathers.controls.ImageLoader;
import feathers.controls.text.BitmapFontTextRenderer;
import feathers.layout.AnchorLayoutData;
import feathers.text.BitmapFontTextFormat;
/**
* ...
* @author Mansour Djawadi
*/
public class HealthBarLeveled extends HealthBar 
{
private var level:int;
private var levelBackDisplay:ImageLoader;
private var levelTextDisplay:BitmapFontTextRenderer;
public function HealthBarLeveled(troopType:int, level:int=1, initValue:Number=0, initMax:Number=1) 
{
	super(troopType, initValue, initMax);
	this.level = level
}
override protected function initialize():void
{
	super.initialize();

	levelBackDisplay = new ImageLoader();
	levelBackDisplay.pixelSnapping = true;
	//levelBackDisplay.alpha = atlas == "battlefields" ? 0.5 : 1;
	levelBackDisplay.scale9Grid = scaleRect;
	levelBackDisplay.visible = value < maximum || troopType > 0;
	levelBackDisplay.source = AppModel.instance.assets.getTexture("healthbar-bg-" + troopType);
	levelBackDisplay.layoutData = new AnchorLayoutData(-5, width - 5, -5, -height - 5);
	addChild(levelBackDisplay);

	levelTextDisplay = new BitmapFontTextRenderer();
	levelTextDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 26, 0xFFFFFF, "center");
	levelTextDisplay.pixelSnapping = true;
	levelTextDisplay.visible = value < maximum || troopType > 0;
	levelTextDisplay.text = level.toString();
	levelTextDisplay.layoutData = new AnchorLayoutData(-15, width - 3, 5, -height - 8);
	addChild(levelTextDisplay);
}
override public function set value(v:Number) : void
{
	super.value = v;
	
	if( super.value == v )
		return;
	
	if( levelBackDisplay != null )
		levelBackDisplay.visible = value < maximum || troopType > 0;
	if( levelTextDisplay != null )
		levelTextDisplay.visible = value < maximum || troopType > 0;
}
}
}