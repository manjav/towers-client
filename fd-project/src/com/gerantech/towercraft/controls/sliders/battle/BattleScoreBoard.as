package com.gerantech.towercraft.controls.sliders.battle 
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.constants.ResourceType;
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
private var alliseValue:int;
private var axisValue:int;
public function BattleScoreBoard() 
{
	super();
	height = 500;
	width = 80;
}
override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	
	var allisBG:ImageLoader = new ImageLoader();
	allisBG.color = 0x000044;
	allisBG.source = Assets.getTexture("theme/background-round-skin");
	allisBG.scale9Grid = new Rectangle(7, 7, 2, 2);
	allisBG.height = 140;
	allisBG.alpha = 0.6;
	allisBG.layoutData = new AnchorLayoutData(NaN, 0, 0, 0);
	addChild(allisBG);


	var axisBG:ImageLoader = new ImageLoader();
	axisBG.color = 0x440000;
	axisBG.source = Assets.getTexture("theme/background-round-skin");
	axisBG.scale9Grid = new Rectangle(7, 7, 2, 2);
	axisBG.height = 140;
	axisBG.alpha = 0.6;
	axisBG.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
	addChild(axisBG);	
	
	
	var allisIcon:ImageLoader = new ImageLoader();
	allisIcon.source = Assets.getTexture("res-17");
	allisIcon.height = 70;
	allisIcon.layoutData = new AnchorLayoutData(NaN, 0, 100, 0);
	addChild(allisIcon);

	var axisIcon:ImageLoader = new ImageLoader();
	axisIcon.source = Assets.getTexture("res-17");
	axisIcon.height = 70;
	axisIcon.layoutData = new AnchorLayoutData(100, 0, NaN, 0);
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
	axisScoreDisplay.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
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
	if( alliseValue != allise )
	{
		alliseValue = allise;
		allisScoreDisplay.text = allise.toString();
	}
	if( axisValue != axis )
	{
		axisValue = axis;
		axisScoreDisplay.text = axis.toString();
	}
	/*//var sum:int = allise + axis;
	Starling.juggler.tween(allisFill,	0.5, {height : height * ( allise	/ sum ), transition:Transitions.EASE_OUT_BACK});
	Starling.juggler.tween(axisFill,	0.5, {height : height * ( axis		/ sum ), transition:Transitions.EASE_OUT_BACK});*/
}
}
}