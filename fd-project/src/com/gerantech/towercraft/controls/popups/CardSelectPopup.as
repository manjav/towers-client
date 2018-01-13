package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.overlays.TutorialArrow;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gt.towers.buildings.Building;
import com.gt.towers.constants.CardTypes;
import com.gt.towers.constants.PrefsTypes;

import flash.geom.Rectangle;

import feathers.layout.AnchorLayoutData;

import starling.core.Starling;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class CardSelectPopup extends SimplePopup
{
public var buildingType:int;
private var building:Building;
private var _bounds:Rectangle;
private var tutorialArrow:TutorialArrow;

public function CardSelectPopup(){}
override protected function initialize():void
{
	super.initialize();
	//closeOnStage = true
	overlay.removeFromParent();
	//overlay.touchable = false;
}

override protected function stage_touchHandler(event:TouchEvent):void
{
	var touch:Touch = event.getTouch(stage, TouchPhase.BEGAN);
	if( touch == null )
		return;
	if( !_bounds.contains(touch.globalX, touch.globalY) )
		close();
}

override protected function transitionInCompleted():void
{
	super.transitionInCompleted();
	
	_bounds = getBounds(stage);
	building = player.buildings.get(buildingType);

	var buildingIcon:BuildingCard = new BuildingCard();
	buildingIcon.showSlider = false;
	buildingIcon.layoutData = new AnchorLayoutData(padding*0.3, padding*0.3, NaN, padding*0.3);
	addChild(buildingIcon);
	buildingIcon.type = buildingType;
	
	var upgradable:Boolean = building.upgradable();
	var detailsButton:CustomButton = new CustomButton();
	detailsButton.label = loc(upgradable ? "upgrade_label" : "info_label");
	detailsButton.style = upgradable ? "normal" : "neutral";
	detailsButton.layoutData = new AnchorLayoutData(NaN, NaN, padding * (data>-1?0.6:4.4), NaN, 0);
	detailsButton.addEventListener(Event.TRIGGERED, detailsButton_triggeredHandler);
	detailsButton.alpha = 0;
	Starling.juggler.tween(detailsButton, 0.1, {alpha:1});
	addChild(detailsButton);
	
	showTutorArrow();
	
	if( data > -1 )
		return;
	
	var usingButton:CustomButton = new CustomButton();
	usingButton.style = "neutral";
	usingButton.label = loc("usage_label");
	usingButton.layoutData = new AnchorLayoutData(NaN, NaN, padding*0.5, NaN, 0);
	usingButton.addEventListener(Event.TRIGGERED, usingButton_triggeredHandler);
	addChild(usingButton);		
	usingButton.alpha = 0;
	Starling.juggler.tween(usingButton, 0.1, {delay:0.05, alpha:1});
	
}
private function showTutorArrow () : void
{
	if( buildingType != CardTypes.INITIAL || player.prefs.getAsInt(PrefsTypes.TUTE_STEP_101) != PrefsTypes.TUTE_114_SELECT_BUILDING )
		return;
	
	if( tutorialArrow != null )
		tutorialArrow.removeFromParent(true);
	
	tutorialArrow = new TutorialArrow(true);
	tutorialArrow.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, height * 0.6);
	addChild(tutorialArrow);
}

protected function usingButton_triggeredHandler(event:Event):void
{
	dispatchEventWith(Event.SELECT, false, building);
	close();
}		
protected function detailsButton_triggeredHandler(event:Event):void
{
	dispatchEventWith(Event.OPEN, false, building);
	close();
}

/*override protected function defaultOverlayFactory():DisplayObject
{
	var overlay:DisplayObject = super.defaultOverlayFactory()
	overlay.visible = false;
	return overlay;
}*/

override protected function transitionOutStarted():void
{
	removeChildren(2);
	super.transitionOutStarted();
}
override public function close(dispose:Boolean=true):void
{
	super.close(dispose);
}
}
}