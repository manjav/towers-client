package com.gerantech.towercraft.controls.sliders.battle 
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.Assets;
import feathers.controls.text.BitmapFontTextRenderer;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.text.BitmapFontTextFormat;
import flash.geom.Rectangle;
import starling.display.Image;
/**
 * ...
 * @author Mansour Djawadi
 */
public class BattleScoreBoard extends IBattleBoard
{
private var allisScoreDisplay:BitmapFontTextRenderer;
private var axisScoreDisplay:BitmapFontTextRenderer;
public function BattleScoreBoard() {super();}
override protected function initialize():void
{
	super.initialize();
	
	var bgImage:Image = new Image(Assets.getTexture("healthbar-bg--1", "gui"));
	bgImage.alpha = 0.6;
	bgImage.scale9Grid = new Rectangle(4, 8, 4, 6);
	backgroundSkin = bgImage;
	
	layout = new AnchorLayout();
	
	allisScoreDisplay = new BitmapFontTextRenderer();//imageDisplay.width, imageDisplay.width/2, "");
	allisScoreDisplay.text = "0";
	allisScoreDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 40, 0xFFFFFF, "left");
	allisScoreDisplay.layoutData = new AnchorLayoutData(NaN, 0, NaN, NaN, 100);
	allisScoreDisplay.pixelSnapping = false;
	addChild(allisScoreDisplay);
	
	axisScoreDisplay = new BitmapFontTextRenderer();//imageDisplay.width, imageDisplay.width/2, "");
	axisScoreDisplay.text = "0";
	axisScoreDisplay.textFormat = allisScoreDisplay.textFormat;
	axisScoreDisplay.layoutData = new AnchorLayoutData(NaN, 0, NaN, NaN, -100);
	axisScoreDisplay.pixelSnapping = false;
	addChild(axisScoreDisplay);
	
/*	addEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);
}
private function createCompleteHandler(e:Event):void 
{
	removeEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);*/
}

override public function update(allise:int, axis:int):void
{
	allisScoreDisplay.text = allise.toString();
	axisScoreDisplay.text = axis.toString();

	/*//var sum:int = allise + axis;
	Starling.juggler.tween(allisFill,	0.5, {height : height * ( allise	/ sum ), transition:Transitions.EASE_OUT_BACK});
	Starling.juggler.tween(axisFill,	0.5, {height : height * ( axis		/ sum ), transition:Transitions.EASE_OUT_BACK});*/
}
}
}