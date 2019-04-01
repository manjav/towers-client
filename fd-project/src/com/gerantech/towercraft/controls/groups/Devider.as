package com.gerantech.towercraft.controls.groups
{
import com.gerantech.towercraft.models.Assets;
import feathers.controls.LayoutGroup;
import flash.geom.Rectangle;
import starling.display.Image;

public class Devider extends LayoutGroup
{
static private const RECT:Rectangle = new Rectangle(2, 2, 12, 12);
public function Devider(color:uint = 0, size:uint = 1)
{
	if( size < 1 )
		size = 1;
	backgroundSkin = new Image(Assets.getTexture("theme/quad-skin", "gui"));
	Image(backgroundSkin).color = color;
	Image(backgroundSkin).scale9Grid = RECT;
}
}
}