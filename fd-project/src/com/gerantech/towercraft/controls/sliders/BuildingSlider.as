package com.gerantech.towercraft.controls.sliders
{
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import feathers.controls.ImageLoader;
import feathers.controls.ProgressBar;
import feathers.layout.AnchorLayoutData;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;

public class BuildingSlider extends ProgressBar
{
public var showUpgradeIcon:Boolean = true;
public var labelDisplay:ShadowLabel;
private var timeoutId:uint;
private var upgradeDisplay:ImageLoader;
public function BuildingSlider() { super(); }
override protected function initialize():void
{
	super.initialize();
	labelFactory();
	
	if( showUpgradeIcon )
	{
		upgradeDisplay = new ImageLoader();
		upgradeDisplay.maintainAspectRatio = false;
		upgradeDisplay.source = Assets.getTexture("theme/upgrade-ready");
	}
}

private function labelFactory() : void 
{
	if( labelDisplay != null )
	{
		labelDisplay.text = value + " / " + maximum;
		return;
	}
	labelDisplay = new ShadowLabel(value + " / " + maximum, 0xEEEEFF, 0, "center", "ltr", false, null, 0.75);
	labelDisplay.mainLayout = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
	labelDisplay.shadowLayout = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -3);
	labelDisplay.y = -6;
	//labelDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 48, 0xFFFFFF, "center");
}

override protected function draw():void
{
	labelDisplay.width = width;
	super.draw();
}

override public function set value(newValue:Number):void
{
	var _val:int = Math.max(0, newValue);
	if( _val == super.value )
		return;
	super.value = _val;
	labelFactory();
	//addChild(labelDisplay);
	isEnabled = _val >= maximum;
	
	if( showUpgradeIcon && _val >= maximum )
	{
		upgradeDisplay.width = upgradeDisplay.height = height;
		upgradeDisplay.x = height * 0.1;
		upgradeDisplay.y = -height * 0.6;
		addChild(upgradeDisplay);
		punchArrow();
	}
	else
	{
		if( upgradeDisplay)
			upgradeDisplay.removeFromParent();
		stopPunching();
	}
	
	var gap:Number = (showUpgradeIcon && _val >= maximum ) ? height * 0.3 : 0;
	labelDisplay.x = gap;
	labelDisplay.width = width-gap;
}

private function punchArrow():void
{
	stopPunching();
	timeoutId = setTimeout(animateUpgradeDisplay, 3000 + Math.random() * 1500);
}
private function animateUpgradeDisplay():void
{
	Starling.juggler.tween(upgradeDisplay, 0.5, {y: -height * 0.6, height:height, transition:Transitions.EASE_OUT_BACK, onComplete:punchArrow});
	upgradeDisplay.y = -height * 1.5;
	upgradeDisplay.height = height * 1.8;
}

private function stopPunching():void
{
	clearTimeout(timeoutId);
	if( upgradeDisplay )
		Starling.juggler.removeTweens(upgradeDisplay);
}

override public function dispose():void
{
	stopPunching();
	super.dispose();
}
}
}