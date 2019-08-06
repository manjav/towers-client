package com.gerantech.towercraft.controls.toasts 
{
import com.gerantech.towercraft.controls.StarCheck;
import com.gerantech.towercraft.managers.SoundManager;
import flash.utils.setTimeout;
import starling.display.Quad;
/**
 * ...
 * @author Mansour Djawadi
 */
public class BattleKeyChangeToast extends BaseToast
{
private var score:int;
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
	transitionOut.destinationBound.y = transitionIn.sourceBound.y = 350;
	transitionIn.destinationBound.y = transitionOut.sourceBound.y = 400;
	rejustLayoutByTransitionData();
	
	// sound
	if( score == 1 )
		appModel.sounds.addAndPlay("battle-clock-ticking");
	else if( score == 0 )
		appModel.sounds.play("battle-clock-ticking", 0.4, 200, 0.3, SoundManager.SINGLE_FORCE_THIS);

	for ( var i:int = 0; i < 3; i++ )
	{
		var starImage:StarCheck = new StarCheck(i <= score + 1, i == 0 ? 180 : 140);
        starImage.x = stageWidth * 0.5 + (Math.ceil(i / 4) * ( i == 1 ? 1 : -1 )) * 256;
        starImage.y = i == 0 ? -20 : 0;
        addChild(starImage);
		if( i > score )
			setTimeout(starImage.deactive, 600);
	}
}
}
}