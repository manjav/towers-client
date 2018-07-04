package com.gerantech.towercraft.controls.buttons 
{
import com.gerantech.towercraft.controls.overlays.TutorialArrow;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import feathers.controls.ButtonState;
import feathers.controls.ImageLoader;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.core.Starling;
import starling.display.DisplayObject;

/**
* ...
* @author Mansour Djawadi
*/
public class HomeNewButton extends SimpleLayoutButton 
{
private var background:String;
private var label:String;
private var scale9Grid:Rectangle;
private var shadowRect:Rectangle;
private var backgroundDisplay:ImageLoader;
private var labelDisplay:ShadowLabel;
private var padding:int;

public function HomeNewButton(background:String, label:String, width:Number, height:Number, scale9Grid:Rectangle = null, shadowRect:Rectangle = null) 
{
	super();
	this.label = label;
	this.background = background;
	this.scale9Grid = scale9Grid;
	this.shadowRect = shadowRect;
	this.width = width;
	pivotX = this.width * 0.5;
	this.height = height;
	pivotY = this.height * 0.5;
	padding = 32 * appModel.scale * Starling.contentScaleFactor;
}

override protected function initialize() : void
{
	super.initialize();
	layout = new AnchorLayout();
	
	backgroundDisplay = new ImageLoader();
	backgroundDisplay.source = Assets.getTexture("home/" + background, "gui");
	if( scale9Grid != null )
		backgroundDisplay.scale9Grid = scale9Grid;
	if( shadowRect != null )
		backgroundDisplay.layoutData = new AnchorLayoutData(-shadowRect.y, -shadowRect.width, -shadowRect.height, -shadowRect.x);
	else
		backgroundDisplay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChild(backgroundDisplay);

	labelDisplay = new ShadowLabel(label, 1, 0, "center", null, false, null, 1.3);
	labelDisplay.shadowDistance = appModel.theme.gameFontSize * 0.05;
	labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -padding * 0.4);
	addChild(labelDisplay);	
}

override public function set currentState(value:String):void
{
	super.currentState = value;
	scale = value == ButtonState.DOWN ? 0.9 : 1;
}
}
}