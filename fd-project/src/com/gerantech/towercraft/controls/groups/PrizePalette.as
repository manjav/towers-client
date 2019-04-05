package com.gerantech.towercraft.controls.groups 
{
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.constants.ResourceType;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;
/**
* @author Mansour Djawadi ...
*/
public class PrizePalette extends ColorGroup 
{
public var prize:int;
private var prizeIconDisplay:ImageLoader;
public function PrizePalette(label:String, textColor:uint, prize:int) 
{
	super(label, textColor);
	this.prize = prize;
	
	var prizeSrc:String;
	if( prize == -1 )
		prizeSrc = "settings-22";
	else
		prizeSrc = (ResourceType.isBook(prize)?"books/":"cards/") + prize;
	
	prizeIconDisplay = new ImageLoader();
	prizeIconDisplay.width = 200;
	prizeIconDisplay.height = 180;
	prizeIconDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 10);
	prizeIconDisplay.source = Assets.getTexture(prizeSrc, "gui");
	addChild(prizeIconDisplay);
}
}
}