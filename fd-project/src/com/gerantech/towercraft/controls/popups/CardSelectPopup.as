package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.buttons.MMOryButton;
import com.gerantech.towercraft.themes.MainTheme;
import com.gt.towers.battle.units.Card;
import feathers.controls.Button;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.core.Starling;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class CardSelectPopup extends SimplePopup
{
public var cardType:int;
private var card:Card;
private var _bounds:Rectangle;
private var detailsButton:MMOryButton;

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
	if( touch == null || _bounds == null )
		return;
	if( !_bounds.contains(touch.globalX, touch.globalY) )
		close();
}

override protected function transitionInCompleted():void
{
	super.transitionInCompleted();
	
	_bounds = getBounds(stage);
	card = player.cards.get(cardType);

	var buildingIcon:BuildingCard = new BuildingCard(true, false, false, true);
	buildingIcon.layoutData = new AnchorLayoutData(4, 4, NaN, 4);
	addChild(buildingIcon);
	buildingIcon.setData(card.type, card.level, card.count());
	
	var upgradable:Boolean = card.upgradable();
	detailsButton = new MMOryButton();
	//detailsButton.width = 240;
	detailsButton.height = 120;
	detailsButton.label = loc(upgradable ? "upgrade_label" : "info_label");
	detailsButton.styleName = upgradable ? MainTheme.STYLE_BUTTON_NORMAL : MainTheme.STYLE_BUTTON_HILIGHT;
	detailsButton.layoutData = new AnchorLayoutData(NaN, 10, data?24:152, 10);
	detailsButton.addEventListener(Event.TRIGGERED, detailsButton_triggeredHandler);
	detailsButton.alpha = 0;
	Starling.juggler.tween(detailsButton, 0.1, {alpha:1});
	addChild(detailsButton);
	
	showTutorHint();
	
	if( data )
		return;
	
	var usingButton:Button = new Button();
	usingButton.styleName = MainTheme.STYLE_BUTTON_HILIGHT;
	usingButton.label = loc("usage_label");
	//usingButton.width = 240;
	usingButton.height = 120;
	usingButton.layoutData = new AnchorLayoutData(NaN, 10, 24, 10);
	usingButton.addEventListener(Event.TRIGGERED, usingButton_triggeredHandler);
	addChild(usingButton);		
	usingButton.alpha = 0;
	Starling.juggler.tween(usingButton, 0.1, {delay:0.05, alpha:1});
	
}
private function showTutorHint () : void
{
	if( player.inDeckTutorial() && card.upgradable() )
		detailsButton.showTutorHint();
}

protected function usingButton_triggeredHandler(event:Event):void
{
	dispatchEventWith(Event.SELECT, false, card);
	close();
}		
protected function detailsButton_triggeredHandler(event:Event):void
{
	dispatchEventWith(Event.OPEN, false, card);
	close();
}
override protected function transitionOutStarted():void
{
	removeChildren(2);
	super.transitionOutStarted();
}
}
}