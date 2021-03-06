package com.gerantech.towercraft.controls.headers
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;

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
private var itsMe:Boolean;
private var label:String;
private var headerSale:Number;
private var padding:int;

public function BattleHeader(label:String, itsMe:Boolean, headerSale:Number = 1)
{
	super();
	this.itsMe = itsMe;
	this.label = label;
	this.headerSale = headerSale;
	padding = 48 * appModel.scale;
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	addEventListener(FeathersEventType.CREATION_COMPLETE, creationCompleteHandler);
}

private function creationCompleteHandler():void
{
	var ribbon:Image = new Image(Assets.getTexture("ribbon-"+(itsMe?"blue":"red"), "gui"));
	ribbon.scale = appModel.scale * 2 * headerSale;
	addChild(ribbon);
	ribbon.pixelSnapping = false;
	ribbon.scale9Grid = new Rectangle(46, 30, 3, 3);
	ribbon.x = width * 0.5;
	ribbon.width = 0;
	Starling.juggler.tween(ribbon, 0.6, {x:140*appModel.scale, width:width-280*appModel.scale, transition:Transitions.EASE_OUT_BACK});
	
	labelDisplay = new ShadowLabel(label, itsMe?0xDDDDFF:0xFFDDDD, 0, "center", null, false, null, 1.4 * headerSale);
	labelDisplay.autoSizeMode = AutoSizeMode.CONTENT
	labelDisplay.layoutData = new AnchorLayoutData(NaN, 0, NaN, 0, NaN, padding * -0.9 * headerSale); 
	labelDisplay.shadowDistance *= -1;
	addChild(labelDisplay);
	
	labelDisplay.alpha = 0;
	Starling.juggler.tween(labelDisplay, 0.3, {delay:0.5, alpha:1});
	
	scaleX = 0.8;
	Starling.juggler.tween(this, 0.6, {scaleX:1, transition:Transitions.EASE_OUT});
}

public function addScoreImages(score:int, max:int=-1):void
{
	for (var i:int = 0; i < score; i++) 
	{
		var keyImage:Image = new Image(Assets.getTexture("gold-key" + (i <= max ? "-off" : ""), "gui"));
		keyImage.alignPivot();
		keyImage.x = (Math.ceil(i/4) * ( i==1 ? 1 : -1 )) * padding * 5 + 540 * appModel.scale;
		keyImage.y = padding * ( i==0 ? -2.2	 : -1.8 );
		keyImage.scale = 0;
		Starling.juggler.tween(keyImage, 0.6, {delay:i*0.3 + 0.5, scale:appModel.scale*( i==0 ? 2.2 : 2 ), transition:Transitions.EASE_OUT_BACK});
		addChild(keyImage);
	}	
}

public function showWinnerLabel(isWinner:Boolean):void
{
	var winnerLabel:ShadowLabel = new ShadowLabel(loc(isWinner?"winner_label":"loser_label"));
	winnerLabel.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, padding * 1.3); 
	addChild(winnerLabel);	
}
}
}