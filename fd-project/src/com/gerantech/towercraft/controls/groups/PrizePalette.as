package com.gerantech.towercraft.controls.groups 
{
	import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
	import dragonBones.starling.StarlingArmatureDisplay;
	import feathers.events.FeathersEventType;
	import starling.events.Event;
/**
* ...
* @author Mansour Djawadi ...
*/
public class PrizePalette extends LabelGroup 
{
private var bookArmature:StarlingArmatureDisplay;

public function PrizePalette(label:String, textColor:uint, book:int) 
{
	super(label, textColor);
	
	bookArmature = OpenBookOverlay.factory.buildArmatureDisplay( "book-" + book );
	bookArmature.scale = OpenBookOverlay.getBookScale(book) * appModel.scale * 0.6;
	bookArmature.animation.timeScale = 0;
	addChild(bookArmature);
	
	addEventListener(FeathersEventType.CREATION_COMPLETE, creationCompleteHandler);
}

private function creationCompleteHandler(e:Event):void 
{
	removeEventListener(FeathersEventType.CREATION_COMPLETE, creationCompleteHandler);
	bookArmature.x = width * 0.5;
	bookArmature.y = height * 0.5;
}
}
}