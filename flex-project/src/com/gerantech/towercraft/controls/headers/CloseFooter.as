package com.gerantech.towercraft.controls.headers
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;

import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.display.Image;
import starling.events.Event;

public class CloseFooter extends TowersLayout
{
	private var size:int = 0;
public function CloseFooter(size:int=0)
{
	super();
	this.size = size == 0 ? 150 * appModel.scale : size;
}
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	backgroundSkin = new Image(appModel.theme.tabUpSkinTexture);
	Image(backgroundSkin).scale9Grid = BaseMetalWorksMobileTheme.TAB_SCALE9_GRID;
	height = size;
	
	var closeButton:CustomButton = new CustomButton();
	closeButton.layoutData = new AnchorLayoutData(16*appModel.scale, NaN, 12*appModel.scale, NaN, 0);
	closeButton.addEventListener(Event.TRIGGERED, backButtonHandler);
	closeButton.label = loc("close_button");
	addChild(closeButton);
}
private function backButtonHandler(event:Event):void
{
	dispatchEventWith(Event.CLOSE);
	
}
}
}