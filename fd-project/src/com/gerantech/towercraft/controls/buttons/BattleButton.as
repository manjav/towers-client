package com.gerantech.towercraft.controls.buttons 
{
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.constants.PrefsTypes;
import feathers.controls.ButtonState;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.core.Starling;

/**
* ...
* @author Mansour Djawadi
*/
public class BattleButton extends SimpleLayoutButton 
{
private var background:String;
private var label:String;
private var scale9Grid:Rectangle;
private var shadowRect:Rectangle;
private var backgroundDisplay:ImageLoader;
private var labelDisplay:ShadowLabel;
private var padding:int;

public function BattleButton(background:String, label:String, width:Number, height:Number, scale9Grid:Rectangle = null, shadowRect:Rectangle = null) 
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
	padding = 32 * Starling.contentScaleFactor;
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

	labelDisplay = new ShadowLabel(label, 1, 0, "center", null, false, null, 1.5);
	//labelDisplay.shadowDistance = appModel.theme.gameFontSize * 0.05;
	labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -40);
	addChild(labelDisplay);
	
	var costBGDisplay:ImageLoader = new ImageLoader();
	costBGDisplay.height = 80
	costBGDisplay.source = Assets.getTexture("home/button-battle-footer", "gui");
	costBGDisplay.scale9Grid = new Rectangle(29, 42, 2, 1);
	costBGDisplay.layoutData = new AnchorLayoutData(NaN, 100, 18, 100);
	addChild(costBGDisplay);
	
	
	
	
}

/**
 * Triggers the button.
 */
override protected function trigger() : void
{
	if( player.getTutorStep() >= PrefsTypes.T_018_CARD_UPGRADED )
		super.trigger();
}

override public function set currentState(value:String):void
{
	super.currentState = value;
	scale = value == ButtonState.DOWN ? 0.9 : 1;
}
}
}