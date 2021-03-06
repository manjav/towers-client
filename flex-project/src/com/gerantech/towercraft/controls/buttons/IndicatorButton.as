package com.gerantech.towercraft.controls.buttons
{
import com.gerantech.towercraft.controls.groups.Devider;

import feathers.layout.AnchorLayoutData;

public class IndicatorButton extends CustomButton
{
public function IndicatorButton(defaultLabel:String = "+", defaulFontSize:Number=1.6)
{
	super();
	label = defaultLabel;
	fontsize = defaulFontSize;
}

override protected function initialize():void
{
	
	super.initialize();
	
	var padding:int = 16 * appModel.scale;
	var overlay:Devider = new Devider(0, 1);
	overlay.alpha = 0;
	overlay.layoutData = new AnchorLayoutData(-padding, -padding, -padding, -padding);
	addChild(overlay);
}
}
}