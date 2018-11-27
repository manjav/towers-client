package com.gerantech.towercraft.controls.sliders.battle
{
import com.gerantech.towercraft.models.AppModel;
import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;

public class HealthBar extends LayoutGroup
{
protected var atlas:String  = "battlefields";
protected var maximum:Number;
protected var scaleRect:Rectangle;
private var _value:Number = 0;
private var _troopType:int = -2;
private var sliderFillDisplay:ImageLoader;
private var sliderBackDisplay:ImageLoader;
public function HealthBar(troopType:int, initValue:Number = 0, initMax:Number = 1)
{
	super();
	this.touchable = false;
	this.pivotX = this.width * 0.5;
	this.width = 48;
	this.minHeight = height = 12;
	this.troopType = troopType;
	this.value = initValue;
	this.maximum = initMax;
}

override protected function initialize():void
{
	super.initialize();
	
	scaleRect = new Rectangle(atlas == "battlefields"?4:2, atlas == "battlefields"?8:4, atlas == "battlefields"?4:2, atlas == "battlefields"?6:3);
	layout = new AnchorLayout();
	
	sliderBackDisplay = new ImageLoader();
	sliderBackDisplay.pixelSnapping = true;
	sliderBackDisplay.alpha = atlas == "battlefields" ? 0.5 : 1;
	sliderBackDisplay.scale9Grid = scaleRect;
	sliderBackDisplay.source = AppModel.instance.assets.getTexture("healthbar-bg-" + (atlas == "battlefields"?_troopType: -1));
	sliderBackDisplay.visible = value < maximum;
	sliderBackDisplay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChild(sliderBackDisplay);
	
	sliderFillDisplay = new ImageLoader();
	sliderFillDisplay.pixelSnapping = true;
	sliderFillDisplay.scale9Grid = scaleRect;
	sliderFillDisplay.source = AppModel.instance.assets.getTexture("healthbar-fill-" + _troopType);
	sliderFillDisplay.visible = value < maximum;
	sliderFillDisplay.width =  width * (value / maximum);
	sliderFillDisplay.layoutData = new AnchorLayoutData(0, NaN, 0, 0);
	addChild(sliderFillDisplay);
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

	var impacted:Boolean = _value < maximum;
	if( sliderFillDisplay != null )
	{
		sliderFillDisplay.visible = _value < maximum;
		sliderFillDisplay.width =  width * (v / maximum);
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
		sliderBackDisplay.source = AppModel.instance.assets.getTexture("healthbar-bg-" + _troopType);
	if( sliderFillDisplay != null )
		sliderFillDisplay.source = AppModel.instance.assets.getTexture("healthbar-fill-" + _troopType);

}
}
}