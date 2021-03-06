package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gt.towers.battle.units.Card;
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
private var detailsButton:CustomButton;

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

	var buildingIcon:BuildingCard = new BuildingCard(true, false, false, true);
	buildingIcon.layoutData = new AnchorLayoutData(padding * 0.3, padding * 0.3, NaN, padding * 0.3);
	addChild(buildingIcon);
	buildingIcon.setData(card.type, card.level, card.count());
	
	var upgradable:Boolean = building.upgradable();
	detailsButton = new CustomButton();
	detailsButton.height = 120;
	detailsButton.label = loc(upgradable ? "upgrade_label" : "info_label");
	detailsButton.style = upgradable ? "normal" : "neutral";
	detailsButton.layoutData = new AnchorLayoutData(NaN, NaN, padding * (data>-1?0.6:4.4), NaN, 0);
	detailsButton.addEventListener(Event.TRIGGERED, detailsButton_triggeredHandler);
	detailsButton.alpha = 0;
	Starling.juggler.tween(detailsButton, 0.1, {alpha:1});
	addChild(detailsButton);
	
	showTutorHint();
	
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
private function showTutorHint () : void
{
	if( player.getTutorStep() != PrefsTypes.T_015_DECK_FOCUS )
		return;
	detailsButton.showTutorHint();
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