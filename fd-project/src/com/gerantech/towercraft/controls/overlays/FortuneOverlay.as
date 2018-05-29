package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.Spinner;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.views.effects.MortalParticleSystem;
import dragonBones.starling.StarlingArmatureDisplay;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.utils.setInterval;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;

public class FortuneOverlay extends BaseOverlay
{
public var delta:Number = 0.005;
public var fortuneHeight:Number;
private var spinners:Vector.<Spinner>;
private var shadow:ImageLoader;

public function FortuneOverlay()
{
	super();
	fortuneHeight = 300 * appModel.scale;
	appModel.sounds.setVolume("main-theme", 0.3);
}

override protected function initialize():void
{
	super.initialize();
	appModel.navigator.activeScreen.visible = false;

	layout = new AnchorLayout();
	closeOnStage = false;

	width = stage.stageWidth;
	height = stage.stageHeight;
	overlay.alpha = 1;

	spinners = new Vector.<Spinner>();
	for (var i:int = 0; i < 6; i++ )
	{
		var spinner:Spinner = new Spinner();
		spinner.display = OpenBookOverlay.factory.buildArmatureDisplay("book-5" + (i + (i>2?4:1)));
		StarlingArmatureDisplay(spinner.display).animation.gotoAndStopByProgress("fall-closed", 1);
		StarlingArmatureDisplay(spinner.display).animation.timeScale = 0;
		spinner.display.touchable = false;
		spinner.angle = i * 360 / 6 * Math.PI / 180;
		spinner.display.x = width * 0.5;
		addChild(spinner.display);
		spinners.push(spinner);
	}

	addEventListener(Event.ENTER_FRAME, enterFrameHandler);
	
	shadow = new ImageLoader();
	shadow.alpha = 0;
	shadow.touchable = false;
	shadow.maintainAspectRatio = false;
	shadow.source = Assets.getTexture("bg-shadow", "gui");
	shadow.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	shadow.color = 0xAA0000;
	addChild(shadow);
	animateShadow(0, 1);
	
	// become to faster rotation
	var time:Number = 4 + Math.random() * 3;
	setTimeout(appModel.sounds.addAndPlaySound, time * 1000 - 2000, "book-appear");
	Starling.juggler.tween(this, time, {delta:0.25, transition:Transitions.EASE_IN, onComplete:rotationCompleted});
	Starling.juggler.tween(this, 3, {fortuneHeight:720 * appModel.scale, transition:Transitions.EASE_OUT_BACK});
	Starling.juggler.tween(this, 1, {delay:time - 1, fortuneHeight:300 * appModel.scale, transition:Transitions.EASE_IN});
}

protected function animateShadow(alphaSeed:Number, delay:Number):void
{
	Starling.juggler.tween(shadow, Math.random() + 0.1, {delay:delay, alpha:Math.random() * alphaSeed + 0.1, onComplete:animateShadow, onCompleteArgs:[alphaSeed==0?0.7:0, 0]});
}

protected function rotationCompleted() : void 
{
	removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
	for ( var i:int = 0; i < 6; i++ )
		spinners[i].dispose();

	Starling.juggler.removeTweens(shadow);
	shadow.removeFromParent();
	
	// explode particles
	var explode:MortalParticleSystem = new MortalParticleSystem("explode", 2);
	explode.x = width * 0.5;
	explode.y = height * 0.5;
	addChild(explode);

	// shine animation
	var shineArmature:StarlingArmatureDisplay = OpenBookOverlay.factory.buildArmatureDisplay("shine");
	shineArmature.touchable = false;
	shineArmature.scale = 0.1;
	shineArmature.x = width * 0.5;
	shineArmature.y = height * 0.5;
	shineArmature.animation.gotoAndPlayByTime("rotate", 0, 10);
	addChild(shineArmature);
	Starling.juggler.tween(shineArmature, 0.3, {scale:appModel.scale * 4, transition:Transitions.EASE_OUT_BACK});

	// book animation
	var bookArmature:StarlingArmatureDisplay = OpenBookOverlay.factory.buildArmatureDisplay("book-5"+2);
	bookArmature.touchable = false;
	bookArmature.x = width * 0.5;
	bookArmature.y = height * 0.5;
	bookArmature.scale = 0.1;
	bookArmature.animation.gotoAndStopByProgress("fall-closed", 1);
	bookArmature.animation.timeScale = 0;
	Starling.juggler.tween(bookArmature, 0.3, {scale:appModel.scale * 2.5, transition:Transitions.EASE_OUT_BACK});
	addChild(bookArmature);
	
	var buttonOverlay:SimpleLayoutButton = new SimpleLayoutButton();
	buttonOverlay.addEventListener(Event.TRIGGERED, buttonOverlay_triggeredHandler);
	buttonOverlay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChild(buttonOverlay);
}

protected function buttonOverlay_triggeredHandler():void
{
	close();
}

protected function enterFrameHandler(e:Event):void 
{
	var _spinners:Array = new Array();
	for ( var i:int = 0; i < 6; i++ )
	{
		var spinner:Spinner = spinners[i] as Spinner;
		spinner.angle -= delta;
		spinner.order = 0.1 + (Math.sin( spinner.angle ) + 1 ) * 0.45;
		spinner.display.visible = spinner.order > 0.3;
		if( spinner.display.visible )
		{
			spinner.display.y = height * 0.5 + fortuneHeight * Math.cos( spinner.angle );
			spinner.display.scale = spinner.order * appModel.scale * 2;
		}
		_spinners.push(spinner);
	}
	_spinners.sortOn("order", Array.NUMERIC  );
	for ( i = 0; i < 6; i++ )
		setChildIndex(_spinners[i].display, i + 2);

}
override public function dispose():void
{
	//shineArmature.removeFromParent();
	appModel.sounds.setVolume("main-theme", 1);
	Starling.juggler.removeTweens(shadow);
	Starling.juggler.removeTweens(this);
	removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
	appModel.navigator.activeScreen.visible = true;
	super.dispose();
}
}
}