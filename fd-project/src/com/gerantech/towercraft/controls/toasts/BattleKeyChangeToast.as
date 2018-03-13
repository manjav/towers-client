package com.gerantech.towercraft.controls.toasts 
{
import com.gerantech.towercraft.controls.StarCheck;
import com.gerantech.towercraft.controls.groups.Devider;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.display.DisplayObject;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Quad;
/**
 * ...
 * @author Mansour Djawadi
 */
public class BattleKeyChangeToast extends BaseToast
{
private var score:int;
private var stars:Vector.<StarCheck>;
public function BattleKeyChangeToast(score : int) 
{
	this.score = score;
	closeAfter = 3000;
	toastHeight = 240;
}

override protected function initialize():void
{
	super.initialize();

	touchable = false;
	backgroundSkin = new Quad (1, 1, 0);
	backgroundSkin.alpha = 0.5;
	
	transitionIn.time = 0.7;
	transitionOut.destinationBound.y = transitionIn.sourceBound.y = 350 * appModel.scale;
	transitionIn.destinationBound.y = transitionOut.sourceBound.y = 400 * appModel.scale;
	rejustLayoutByTransitionData();
	
	// sound
	if( score == 1 )
		appModel.sounds.addAndPlaySound("battle-clock-ticking");
	else if( score == 0 )
		appModel.sounds.playSoundUnique("battle-clock-ticking", 0.4, 200, 0.3);

	var _h:int = transitionIn.destinationBound.height;
	stars = new Vector.<StarCheck>();
	for ( var i:int = 0; i < 3; i++ )
	{
		var star:StarCheck = new StarCheck();
		star.width = star.height = _h * 0.7;
		star.pivotX = star.width * 0.5;
		star.pivotY = star.height * 0.5;
		star.x = transitionIn.destinationBound.width * 0.5 + Math.ceil(i / 4) * ( i == 1 ? 1 : -1 ) * _h * 0.7;
		star.y = _h * 0.5;
		addChild(star);
		stars.push(star);
	}
	
	for ( i = 0; i < stars.length; i++ )
		stars[i].isEnabled = score >= i;
}
override protected function transitionInCompleted() : void
{
	super.transitionInCompleted();

	stars[score+1].scale = 1.5;
	Starling.juggler.tween(stars[score+1], 0.3, {delay: 0.1, scale:1, transition:Transitions.EASE_OUT_BACK});
}
}
}