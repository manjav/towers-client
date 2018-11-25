package com.gerantech.towercraft.controls.sliders
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gt.towers.battle.BattleField;
import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.controls.text.BitmapFontTextRenderer;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.text.BitmapFontTextFormat;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.BlendMode;

public class ElixirBar extends TowersLayout
{
private var progressBar:Slider;
private var elixirBottle:LayoutGroup;
private var realtimeDisplay:ImageLoader;
private var elixirCountDisplay:BitmapFontTextRenderer;
private var _value:Number;

public function ElixirBar()
{
	super();
	this.touchable = false;
	this.pivotX = this.width * 0.5;
	this.layout = new AnchorLayout();
	this.value = appModel.battleFieldView.battleData.getAlliseEllixir();
}

override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	//width = 280;
	height = 72;
	var padding:int = 12;
	
	progressBar = new Slider();
	progressBar.maximum = BattleField.POPULATION_MAX;
	progressBar.value = value;
	progressBar.isEnabled = false;
	progressBar.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChild(progressBar);
	
	realtimeDisplay = new ImageLoader();
	realtimeDisplay.blendMode = BlendMode.ADD;
	realtimeDisplay.alpha = 0.4;
	realtimeDisplay.source = Assets.getTexture("theme/slider-background", "gui");
	realtimeDisplay.scale9Grid = MainTheme.SLIDER_SCALE9_GRID;
	realtimeDisplay.layoutData = new AnchorLayoutData(0, NaN, 0, 0);
	addChild(realtimeDisplay);
	
	elixirBottle = new LayoutGroup();
	elixirBottle.touchable = false;
	elixirBottle.pivotX = elixirBottle.width * 0.5;
	elixirBottle.pivotY = elixirBottle.height * 0.5;
	elixirBottle.layout = new AnchorLayout();
	//elixirBottle.backgroundSkin = new Image (Assets.getTexture("elixir", "gui"));
	elixirBottle.layoutData = new AnchorLayoutData(NaN, NaN, padding, padding);
	addChild(elixirBottle);
	
	elixirCountDisplay = new BitmapFontTextRenderer();
	elixirCountDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 110)
	elixirCountDisplay.pixelSnapping = elixirCountDisplay.touchable = false;
	elixirCountDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
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

	if( progressBar != null )
		Starling.juggler.tween(progressBar, 0.8, {value:_value, transition:Transitions.EASE_OUT_ELASTIC});
	
	if( elixirCountDisplay != null )
	{
		elixirCountDisplay.text = _value.toString();
		elixirBottle.scale = 1.4;
		Starling.juggler.tween(elixirBottle, 0.8, {scale:1, transition:Transitions.EASE_OUT_ELASTIC});
	}
	
	if( realtimeDisplay != null )
	{
		var last:Number = (_value + 0) / BattleField.POPULATION_MAX * this.width;
		var next:Number = (_value + 1) / BattleField.POPULATION_MAX * this.width;
		var time:Number = 1 / appModel.battleFieldView.battleData.battleField.getElixirIncreaseSpeed() / 1000;
		realtimeDisplay.width = last;
		Starling.juggler.removeTweens(realtimeDisplay);
		Starling.juggler.tween(realtimeDisplay, time, {width:next, transition:Transitions.LINEAR});
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