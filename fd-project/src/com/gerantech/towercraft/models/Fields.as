package com.gerantech.towercraft.models
{
import com.gt.towers.battle.fieldes.FieldData;
import com.gt.towers.battle.fieldes.ImageData;

import flash.geom.Matrix;

import starling.display.Image;

public class Fields
{
public function Fields()
{
}

public static function getField( field:FieldData , atlassName:String) : Vector.<Image>
{
	var ret:Vector.<Image> = new Vector.<Image>();
	for each( var item:ImageData in field.images._list )
	{
		var img:Image = new Image(Assets.getTexture(item.name, atlassName));
		img.transformationMatrix = new Matrix(item.a, item.b, item.c, item.d, item.tx, item.ty);
		ret.push(img);
	}
	return ret;
}
}
}