package com.gerantech.towercraft.controls.animations
{
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import feathers.controls.ImageLoader;
import feathers.controls.text.BitmapFontTextRenderer;
import feathers.text.BitmapFontTextFormat;
import starling.display.Sprite;
import starling.textures.Texture;

public class AchievedItem extends Sprite
{
public function AchievedItem(texture:Texture, count:int, size:int = 130, prefix:String="")
{
	var labelDisplay:BitmapFontTextRenderer = new BitmapFontTextRenderer();//imageDisplay.width, imageDisplay.width/2, "");
	labelDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), size, 0xFFFFFF, "left");
	labelDisplay.pixelSnapping = false;
	labelDisplay.text = prefix + count;
	labelDisplay.y = -size * 0.9;
	addChild(labelDisplay);
	
	var iconDisplay:ImageLoader = new ImageLoader();
	iconDisplay.source = texture;
	iconDisplay.width = iconDisplay.height = size;
	iconDisplay.x = -size;
	iconDisplay.y = -size * 0.5;
	addChild(iconDisplay);
}
}
}