package com.gerantech.towercraft.controls.groups 
{
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.utils.maps.IntIntMap;
import dragonBones.starling.StarlingArmatureDisplay;
import feathers.controls.ImageLoader;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;
import starling.events.Event;
/**
* ...
* @author Mansour Djawadi ...
*/
public class RewardsPalette extends LabelGroup 
{
public function RewardsPalette(label:String, textColor:uint) 
{
	super(label, textColor);
}

public function setRewards(rewards:IntIntMap) : void
{
	removeChildren(1);
	var keys:Vector.<int> = rewards.keys();
	var i:int = 0;
	while ( i < keys.length )
	{
		addLine(keys[i], rewards.get(keys[i]), i);
		i ++;
	}
}

private function addLine(key:int, value:int, index:int):void 
{
	var countDisplay:RTLLabel = new  RTLLabel( "x " + value, 0, null, null, false, null, 0.9);
	countDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 30, 70 * index - 25);
	addChild(countDisplay);
	
	var iconDisplay:ImageLoader = new ImageLoader();
	iconDisplay.width = 70;
	iconDisplay.height = 70;
	iconDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, -70, 70 * index - 25);
	iconDisplay.source = Assets.getTexture(getImageSource(key), "gui");
	addChildAt(iconDisplay, 1);
}

private function getImageSource(resourceType:int) : String
{
	var ret:String;
	if( resourceType == -1 )
		ret = "settings-22";
	else if( ResourceType.isBook(resourceType) )
		ret = "books/" + resourceType;
	else if( ResourceType.isBuilding(resourceType) )
		ret = "cards/" + resourceType;
	else
		ret = "res-" + resourceType;
	return ret;
}
}
}