package com.gerantech.towercraft.controls.toasts 
{
import com.gerantech.towercraft.controls.StarCheck;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Quad;
/**
 * ...
 * @author Mansour Djawadi
 */
public class BattleTurnToast extends BaseToast
{
private var side:int;
private var score:int;
private var stars:Vector.<StarCheck>;
private var titleDisplay:ShadowLabel;
public function BattleTurnToast(side:int, score:int) 
{
	this.side = side;
	this.score = score;
	closeAfter = 3000;
	toastHeight = 320;
	layout = new AnchorLayout();
}

override protected function initialize():void
{
	super.initialize();

	touchable = false;
	backgroundSkin = new Quad (1, 1, side == 0 ? 0x000088 : 0x880000);
	backgroundSkin.alpha = 0.7;
	
	transitionIn.time = 0.7;
	transitionOut.destinationBound.y = transitionIn.sourceBound.y = side == 0 ? 1000 : 350;
	transitionIn.destinationBound.y = transitionOut.sourceBound.y = side == 0 ? 1050 : 400;
	rejustLayoutByTransitionData();
	
	titleDisplay = new ShadowLabel(loc(side == 0 ? "guest_label" : "enemy_label"), 1, 0, null, null, false, null, 1.4);
	titleDisplay.layoutData = new AnchorLayoutData(20, NaN, NaN, NaN, 0);
	addChild(titleDisplay);
	
	// sound
	appModel.sounds.addAndPlaySound("scoreboard-change-" + side);

	var _h:int = transitionIn.destinationBound.height;
	stars = new Vector.<StarCheck>();
	for ( var i:int = 0; i < 3; i++ )
	{
		var star:StarCheck = new StarCheck();
		star.width = star.height = _h * 0.4;
		star.pivotX = star.width * 0.5;
		star.pivotY = star.height * 0.5;
		star.x = transitionIn.destinationBound.width * 0.5 + (i - 1) * _h * 0.6;
		star.y = _h * 0.7; 
		star.isEnabled = score > i + 1;
		addChild(star);
		stars.push(star);
	}
}
override protected function transitionInCompleted() : void
{
	super.transitionInCompleted();

	if( score < 1 )
		return;
	
	stars[score - 1].isEnabled = true;
	stars[score - 1].scale = 1.5;
	Starling.juggler.tween(stars[score - 1], 0.3, {delay: 0.1, scale:1, transition:Transitions.EASE_OUT_BACK});
}
}
}