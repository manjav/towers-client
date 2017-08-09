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
		
		public static function getField( field:FieldData ) : Vector.<Image>
		{
			var ret:Vector.<Image> = new Vector.<Image>();
			for each(var item:ImageData in field.images._list)
			{
				var img:Image = new Image(Assets.getTexture(item.name, "battlefields"));
				img.transformationMatrix = new Matrix(item.a, item.b, item.c, item.d, item.tx, item.ty);
				img.x *= AppModel.instance.scale;
				img.y *= AppModel.instance.scale;
				img.width *= AppModel.instance.scale*2;
				img.height *= AppModel.instance.scale*2;
				//trace(item.name, img.x, img.y, img.scale);
				ret.push(img);
			}
			return ret;
		}
	}
}