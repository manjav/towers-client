package com.gerantech.towercraft.controls.headers
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;

import flash.geom.Rectangle;

import feathers.controls.AutoSizeMode;
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

public function BattleHeader(label:String, itsMe:Boolean, headerSale:Number = 1)
{
	super();
	this.itsMe = itsMe;
	this.label = label;
	this.headerSale = headerSale;
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	height = 160  * appModel.scale * headerSale;
	var padding:int = 12 * appModel.scale;

	var ribbon:Image = new Image(Assets.getTexture("ribbon-"+(itsMe?"blue":"red"), "gui"));
	ribbon.scale = appModel.scale * 2;
	ribbon.scale9Grid = new Rectangle(46, 30, 3, 3);
	backgroundSkin = ribbon;
	
	labelDisplay = new ShadowLabel(label, itsMe?0xDDDDFF:0xFFDDDD, 0, "center", null, false, null, 1.4 * headerSale);
	labelDisplay.autoSizeMode = AutoSizeMode.CONTENT
	labelDisplay.width = width * 0.8;
	labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -padding * 2.4 * headerSale); 
	labelDisplay.shadowDistance *= -headerSale;
	addChild(labelDisplay);
	
	labelDisplay.alpha = 0;
	Starling.juggler.tween(labelDisplay, 0.3, {delay:0.5, alpha:1});
	
	scaleX = 0.8;
	Starling.juggler.tween(this, 0.6, {scaleX:1, transition:Transitions.EASE_OUT});
}
}
}