package com.gerantech.towercraft.controls.headers
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.display.Image;

public class ScreenHeader extends TowersLayout
{
private var labelDisplay:RTLLabel;
private var _label:String = "";

public function ScreenHeader(label:String)
{
	super();
	this.label = label;
}

public function get label():String
{
	return _label;
}
public function set label(value:String):void
{
	if( _label == value )
		return;
	
	_label = value;
	if( labelDisplay )
		labelDisplay.text = _label;
}

override protected function initialize():void
{
	super.initialize();
	
	backgroundSkin = new Image(appModel.theme.tabUpSkinTexture);
	Image(backgroundSkin).scale9Grid = BaseMetalWorksMobileTheme.TAB_SCALE9_GRID;
	backgroundSkin.alpha = 0.9;
	
	layout = new AnchorLayout();
	
	labelDisplay = new RTLLabel( _label, 1, "center" );
	labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
	addChild( labelDisplay );
}
}
}