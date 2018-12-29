package com.gerantech.towercraft.controls.headers
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import dragonBones.starling.StarlingArmatureDisplay;

import flash.geom.Rectangle;

import feathers.controls.AutoSizeMode;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;

public class BattleHeader extends TowersLayout
{
public var labelDisplay:ShadowLabel;
private var label:String;
private var isAllise:Boolean;
private var created:Boolean;
private var needsShowWinner:Boolean;

private var padding:int;
public function BattleHeader(label:String, isAllise:Boolean)
{
	super();
	height = 160;
	this.isAllise = isAllise;
	this.label = label;
	padding = 48;
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	addEventListener(FeathersEventType.CREATION_COMPLETE, creationCompleteHandler);
}

private function creationCompleteHandler():void
{
	var ribbon:Image = new Image(Assets.getTexture("ribbon-"+(isAllise?"blue":"red"), "gui"));
	//ribbon.pivotX = ribbon.width * 0.5;
	addChild(ribbon);
	ribbon.pixelSnapping = false;
	ribbon.scale9Grid = MainTheme.RIBBON_SCALE9_GRID;
	ribbon.x = width * 0.5;
	ribbon.width = 0;
	Starling.juggler.tween(ribbon, 0.6, {x:140, width:width - 280, transition:Transitions.EASE_OUT_BACK});
	
	labelDisplay = new ShadowLabel(label, isAllise?0xDDDDFF:0xFFDDDD, 0, "center", null, false, null, 1.4);
	labelDisplay.autoSizeMode = AutoSizeMode.CONTENT
	labelDisplay.layoutData = new AnchorLayoutData(NaN, 0, NaN, 0, NaN, padding * -0.6); 
	labelDisplay.shadowDistance *= -0.65;
	addChild(labelDisplay);
	
	labelDisplay.alpha = 0;
	Starling.juggler.tween(labelDisplay, 0.3, {delay:0.5, alpha:1});
	
	created = true;
	if( needsShowWinner )
		showWinnerLabel(true);
}

public function addScoreImages(score:int, max:int=-1):void
{
	for (var i:int = 0; i < score; i++) 
	{
		var keyImage:Image = new Image(Assets.getTexture("gold-key" + (i <= max ? "-off" : ""), "gui"));
		keyImage.alignPivot();
		keyImage.x = (Math.ceil(i/4) * ( i==1 ? 1 : -1 )) * padding * 5 + Starling.current.stage.stageWidth * 0.5;
		keyImage.y = padding * ( i==0 ? -2.2	 : -1.8 );
		keyImage.scale = 0;
		Starling.juggler.tween(keyImage, 0.6, {delay:i * 0.3 + 0.5, scale:( i == 0 ? 1.1 : 1 ), transition:Transitions.EASE_OUT_BACK});
		addChild(keyImage);
	}	
}

public function showWinnerLabel(isWinner:Boolean) : void
{
	if( !isWinner )
		return;
	if( !created )
	{
		needsShowWinner = true;
		return;
	}
	
	var winnerLabel:ShadowLabel = new ShadowLabel(loc(isWinner ? "winner_label" : "loser_label"));
	winnerLabel.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, padding * 1.4); 
	addChild(winnerLabel);	
	
	var armatureDisplay:StarlingArmatureDisplay = OpenBookOverlay.factory.buildArmatureDisplay("shine");
	armatureDisplay.animation.timeScale = 0.5;
	armatureDisplay.alpha = 0.7;
	armatureDisplay.x = width * 0.5;
	//armatureDisplay.y = height * 0.5;
	armatureDisplay.scaleX = 3.5;
	armatureDisplay.scaleY = 1.7;
	armatureDisplay.animation.gotoAndPlayByFrame("rotate", 1);
	addChildAt(armatureDisplay, 0);
}
}
}