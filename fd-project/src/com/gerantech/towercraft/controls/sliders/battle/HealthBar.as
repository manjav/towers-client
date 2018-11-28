package com.gerantech.towercraft.controls.sliders.battle
{
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.views.BattleFieldView;
import starling.display.Image;
import feathers.controls.LayoutGroup;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;

public class HealthBar
{
static protected var SCALE_RECT:Rectangle = new Rectangle(3, 3, 9, 9);
public var width:Number = 48;
public var height:Number = 15;
protected var _value:Number = 0;
protected var _troopType:int = -2;
protected var maximum:Number;
protected var sliderFillDisplay:Image;
protected var sliderBackDisplay:Image;
protected var filedView:BattleFieldView;
public function HealthBar(filedView:BattleFieldView, troopType:int, initValue:Number = 0, initMax:Number = 1)
{
	super();
	this.value = initValue;
	this.maximum = initMax;
	this.troopType = troopType;
	this.filedView = filedView;

	sliderBackDisplay = new Image(AppModel.instance.assets.getTexture("sliders/" + troopType + "/back"));
	sliderBackDisplay.scale9Grid = SCALE_RECT;
	sliderBackDisplay.pixelSnapping = false;
	sliderBackDisplay.touchable = false;
	sliderBackDisplay.width = width;
	sliderBackDisplay.height = height;
	sliderBackDisplay.visible = value < maximum;
	filedView.guiImagesContainer.addChild(sliderBackDisplay);
	
	sliderFillDisplay = new Image(AppModel.instance.assets.getTexture("sliders/" + troopType + "/fill"));
	sliderFillDisplay.scale9Grid = SCALE_RECT;
	sliderFillDisplay.pixelSnapping = false;
	sliderFillDisplay.touchable = false;
	sliderFillDisplay.height = height;
	sliderFillDisplay.visible = value < maximum;
	filedView.guiImagesContainer.addChild(sliderFillDisplay);
}

public function setPosition(x:Number, y:Number) : void
{
	if( sliderBackDisplay != null )
	{
		sliderBackDisplay.x = x - width * 0.5;
		sliderBackDisplay.y = y;
	}
	if( sliderFillDisplay != null )
	{
		sliderFillDisplay.x = x - width * 0.5;
		sliderFillDisplay.y = y;
	}
}



public function get value() : Number
{
	return _value;
}
public function set value(v:Number) : void
{
	if( _value == v )
		return;
	if( v > maximum )
		v = maximum;
	if( v < 0 )
		v = 0;
	_value = v;

	if( sliderFillDisplay != null )
	{
		sliderFillDisplay.visible = _value < maximum;
		sliderFillDisplay.width =  width * (_value / maximum);
	}
	
	if( sliderFillDisplay != null )
		sliderFillDisplay.visible = _value < maximum;
}

public function get troopType():int
{
	return _troopType;
}
public function set troopType(value:int):void
{
	if( _troopType == value )
		return;
	_troopType = value;
	
	if( sliderBackDisplay!= null )
		sliderBackDisplay.texture = AppModel.instance.assets.getTexture("sliders/" + troopType + "/back");
	if( sliderFillDisplay != null )
		sliderFillDisplay.texture = AppModel.instance.assets.getTexture("sliders/" + troopType + "/fill");

}

public function dispose() : void 
{
	if( sliderBackDisplay!= null )
		sliderBackDisplay.removeFromParent(true);
	if( sliderFillDisplay != null )
		sliderFillDisplay.removeFromParent(true);
}
}
}