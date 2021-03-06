package com.gerantech.towercraft.controls.buttons 
{
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.buildings.Building;
	import com.gt.towers.buildings.Card;
	import feathers.layout.AnchorLayoutData;
	import starling.animation.Transitions;
	import starling.core.Starling;
/**
* ...
* @author Mansour Djawadi
*/
public class IndicatorCard extends Indicator 
{
private var timeoutId:uint;
public function IndicatorCard(direction:String, type:int, autoApdate:Boolean = true)
{
	super(direction, type, true, false, autoApdate);
}
override protected function initialize():void
{
	super.initialize();
	iconDisplay.maintainAspectRatio = false;
	iconDisplay.source = Assets.getTexture("theme/upgrade-ready", "gui");
	AnchorLayoutData(iconDisplay.layoutData).verticalCenter = NaN;
	iconDisplay.y = -20;
	iconDisplay.height = 60;
}

override public function setData(minimum:Number, value:Number, maximum:Number, changeDuration:Number = 0):void
{
	var card:Building = player.buildings.get(type);
	maximum = Card.get_upgradeCards(card == null?1:card._level);
	super.setData(minimum, value, maximum, changeDuration);
	var _upgradable:Boolean = this.value >= maximum;

	if( iconDisplay == null ) 
		return;
	
	Starling.juggler.removeDelayedCalls(punchArrow);
	if( _upgradable )
		Starling.juggler.delayCall(punchArrow, changeDuration);
	else
		reset();
}

private function reset():void 
{
	stopPunching();
	iconDisplay.removeFromParent();
	if( progressBar != null )
		progressBar.paddingTextLeft = 0;
	if( progressBar != null )
		progressBar.isEnabled = false;
}

private function punchArrow(delay:Number = 0):void
{
	stopPunching();
	if( progressBar != null )
	{
		progressBar.paddingTextLeft = 40;
		progressBar.isEnabled = true;
	}
	addChild(iconDisplay);
	Starling.juggler.delayCall(animateIconDisplay, delay);
}
private function animateIconDisplay():void
{
	iconDisplay.y = -55;
	iconDisplay.height = 80;
	Starling.juggler.tween(iconDisplay, 0.5, {y:-20, height:60, transition:Transitions.EASE_OUT_BACK, onComplete:punchArrow, onCompleteArgs:[3 + Math.random() * 1.5]});
}

private function stopPunching():void
{
	iconDisplay.y = -20;
	iconDisplay.height = 60;
	Starling.juggler.removeDelayedCalls(animateIconDisplay);
	if( iconDisplay != null )
		Starling.juggler.removeTweens(iconDisplay);
}

override public function dispose():void
{
	stopPunching();
	super.dispose();
}
}
}