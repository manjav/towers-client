package com.gerantech.towercraft.views
{
import com.gerantech.towercraft.models.Assets;

import flash.geom.Rectangle;

import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

public class HealthBar extends LayoutGroup
{
	
public var atlas:String  = "battlefields";
private var scaleRect:Rectangle;

private var _value:Number = 0;
private var _troopType:int = -2;
private var maximum:Number;

private var fillDisplay:ImageLoader;
private var backroundDisplay:ImageLoader;

public function HealthBar(troopType:int, initValue:Number = 0, initMax:Number = 1)
{
	super();
	touchable = false;
	this.pivotX = this.width * 0.5;
	this.width = 48;
	this.troopType = troopType;
	this.value = initValue;
	this.maximum = initMax;
}

override protected function initialize():void
{
	super.initialize();
	
	scaleRect = new Rectangle(atlas=="battlefields"?4:2, atlas=="battlefields"?8:4, atlas=="battlefields"?4:2, atlas=="battlefields"?6:3);
	layout = new AnchorLayout();
	
	backroundDisplay = new ImageLoader();
	backroundDisplay.alpha = atlas=="battlefields"?0.5:1;
	backroundDisplay.scale9Grid = scaleRect;
	backroundDisplay.source = Assets.getTexture("healthbar-bg-"+(atlas=="battlefields"?_troopType:-1), atlas);
	backroundDisplay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChild(backroundDisplay);
	
	fillDisplay = new ImageLoader();
	fillDisplay.scale9Grid = scaleRect;
	fillDisplay.source = Assets.getTexture("healthbar-fill-"+_troopType, atlas);
	fillDisplay.width =  width*(value/maximum);
	fillDisplay.layoutData = new AnchorLayoutData(0, NaN, 0, 0);
	addChild(fillDisplay);
}


public function get value():Number
{
	return _value;
}
public function set value(v:Number):void
{
	if( _value == v )
		return;
	if( v > maximum )
		v = maximum;
	if( v < 0 )
		v = 0;
	_value = v;
	if( fillDisplay )
		fillDisplay.width =  width*(v/maximum);
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
	
	if( backroundDisplay )
		backroundDisplay.source = Assets.getTexture("healthbar-bg-"+_troopType);
	if( fillDisplay )
		fillDisplay.source = Assets.getTexture("healthbar-fill-"+_troopType);

}
}
}