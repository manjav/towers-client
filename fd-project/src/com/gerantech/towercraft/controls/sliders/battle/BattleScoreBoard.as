package com.gerantech.towercraft.controls.sliders.battle 
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.Assets;
import feathers.controls.ImageLoader;
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
public function BattleScoreBoard() 
{
	super();
	height = 500;
	width = 100;
}
override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	
	var allisBG:ImageLoader = new ImageLoader();
	allisBG.color = 0x000088;
	allisBG.source = Assets.getTexture("theme/seek-slider-progress-skin", "gui");
	allisBG.scale9Grid = new Rectangle(4, 8, 4, 6);
	allisBG.height = 160;
	allisBG.alpha = 0.6;
	allisBG.layoutData = new AnchorLayoutData(NaN, 0, 0, 0);
	addChild(allisBG);


	var axisBG:ImageLoader = new ImageLoader();
	axisBG.color = 0x880000;
	axisBG.source = Assets.getTexture("theme/seek-slider-progress-skin", "gui");
	axisBG.scale9Grid = new Rectangle(4, 8, 4, 6);
	axisBG.height = 160;
	axisBG.alpha = 0.6;
	axisBG.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
	addChild(axisBG);	
	
	
	var allisIcon:ImageLoader = new ImageLoader();
	allisIcon.source = Assets.getTexture("res-1001", "gui");
	allisIcon.height = 160;
	allisIcon.layoutData = new AnchorLayoutData(NaN, 0, 80, 0);
	addChild(allisIcon);

	var axisIcon:ImageLoader = new ImageLoader();
	axisIcon.source = Assets.getTexture("res-1001", "gui");
	axisIcon.height = 160;
	axisIcon.layoutData = new AnchorLayoutData(80, 0, NaN, 0);
	addChild(axisIcon);
	
	
	allisScoreDisplay = new BitmapFontTextRenderer();
	allisScoreDisplay.text = "0";
	allisScoreDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 60, 0x3333FF, "center");
	allisScoreDisplay.layoutData = new AnchorLayoutData(NaN, 0, 20, 0);
	allisScoreDisplay.pixelSnapping = false;
	addChild(allisScoreDisplay);
	
	axisScoreDisplay = new BitmapFontTextRenderer();
	axisScoreDisplay.text = "0";
	axisScoreDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 60, 0xFF3333, "center");
	axisScoreDisplay.layoutData = axisBG.layoutData
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