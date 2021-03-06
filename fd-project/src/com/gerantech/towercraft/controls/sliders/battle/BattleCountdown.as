package com.gerantech.towercraft.controls.sliders.battle
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import feathers.controls.text.BitmapFontTextRenderer;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.text.BitmapFontTextFormat;
import flash.geom.Rectangle;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;

/**
* ...
* @author Mansour Djawadi
*/
public class BattleCountdown extends IBattleSlider
{
public var timeLabel:BitmapFontTextRenderer;

public function BattleCountdown() 
{
	super();
}
override protected function initialize():void
{
	super.initialize();
	
	var bgImage:Image = new Image(Assets.getTexture("theme/check-up-icon", "gui"));
	bgImage.alpha = 0.6;
	bgImage.scale9Grid = new Rectangle(8, 8, 8, 8);
	backgroundSkin = bgImage;
	
	var padding:int = 16;
	layout = new AnchorLayout();
	
	var messageLabel:RTLLabel =  new RTLLabel("زمان باقیمانده", 1, "center", null, false, null, 0.8);
	messageLabel.layoutData = new AnchorLayoutData(0, padding, NaN, padding, NaN, -22);
	addChild(messageLabel);
	
	timeLabel = new BitmapFontTextRenderer();
	timeLabel.textFormat = new BitmapFontTextFormat(Assets.getFont(), 56, 0xFFFFFF, "center");
	timeLabel.layoutData = new AnchorLayoutData(NaN, padding, NaN, padding, NaN, 20);
	timeLabel.pixelSnapping = false;
	addChild(timeLabel);
}
override public function set value(val:Number):void 
{
	if( val < 0 )
		return;
	timeLabel.text = StrUtils.uintToTime(val);
}
override public function enableStars(score:int):void 
{
	if( score == -1 )
	{
		Image(backgroundSkin).texture = Assets.getTexture("theme/check-down-icon", "gui");
		Image(backgroundSkin).color = 0xFF0000;
		backgroundSkin.alpha = 0.8;
		timeLabel.scale = 0.4;
		Starling.juggler.tween(timeLabel, 0.5, {scale : 1, transition:Transitions.EASE_OUT_BACK});
	}
}
}
}