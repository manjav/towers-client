package com.gerantech.towercraft.controls.sliders
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.battle.BattleField;

import feathers.controls.LayoutGroup;
import feathers.controls.text.BitmapFontTextRenderer;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.text.BitmapFontTextFormat;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;

public class ElixirBar extends TowersLayout
{
private var progressBar:Slider;
private var elixirBottle:LayoutGroup;
private var elixirCountDisplay:BitmapFontTextRenderer;
private var _value:Number;

public function ElixirBar()
{
	super();
	touchable = false;
	this.pivotX = this.width * 0.5;
	this.value = appModel.battleFieldView.battleData.battleField.elixirBar.get(player.troopType);
}

override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	width = 280;
	height = 72;
	var padding:int = 12;
	
	progressBar = new Slider();
	progressBar.maximum = BattleField.POPULATION_MAX;
	progressBar.value = value;
	progressBar.isEnabled = false;
	progressBar.layoutData = new AnchorLayoutData (0,0,0,0);
	addChild(progressBar);
	
	elixirBottle = new LayoutGroup();
	elixirBottle.touchable = false;
	elixirBottle.pivotX = elixirBottle.width * 0.5;
	elixirBottle.pivotY = elixirBottle.height * 0.5;
	elixirBottle.scale = 2;
	elixirBottle.layout = new AnchorLayout();
	//elixirBottle.backgroundSkin = new Image (Assets.getTexture("elixir", "gui"));
	elixirBottle.layoutData = new AnchorLayoutData(NaN, NaN, padding, padding);
	addChild(elixirBottle);
	
	elixirCountDisplay = new BitmapFontTextRenderer();
	elixirCountDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 110)
	elixirCountDisplay.pixelSnapping = elixirCountDisplay.touchable = false;
	elixirCountDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -16);
	elixirBottle.addChild(elixirCountDisplay);
}

public function get value():Number
{
	return _value;
}
public function set value(newValue:Number):void
{
	var __v:Number = Math.max(0, Math.min( newValue, BattleField.POPULATION_MAX ));
	if( _value == __v )
		return;
	_value = __v;

	if( progressBar )
		Starling.juggler.tween(progressBar, 0.8, {value:_value, transition:Transitions.EASE_OUT_ELASTIC});
	
	if( elixirCountDisplay)
	{
		elixirCountDisplay.text = _value.toString();
		elixirBottle.scale = 1.4;
		Starling.juggler.tween(elixirBottle, 0.8, {scale:1, transition:Transitions.EASE_OUT_ELASTIC});
	}
}

override public function dispose():void
{
	Starling.juggler.removeTweens(progressBar);
	Starling.juggler.removeTweens(elixirBottle);
	super.dispose();
}
}
}