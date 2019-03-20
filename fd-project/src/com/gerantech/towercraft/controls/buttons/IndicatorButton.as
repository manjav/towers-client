package com.gerantech.towercraft.controls.buttons
{
import com.gerantech.towercraft.controls.groups.Devider;
import feathers.controls.ButtonState;
import feathers.layout.AnchorLayoutData;

public class IndicatorButton extends CustomButton
{
public var fixed:Boolean;
public function IndicatorButton(defaultLabel:String = "+", defaulFontSize:Number=1.5)
{
	super();
	label = defaultLabel;
	fontsize = defaulFontSize;
}

override protected function initialize():void
{
	
	super.initialize();
	
	var padding:int = 16;
	var overlay:Devider = new Devider(0, 1);
	overlay.alpha = 0;
	overlay.layoutData = new AnchorLayoutData(-padding, -padding, -padding, -padding);
	addChild(overlay);
}

override public function set label(value:String):void
{
	if( fixed )
		super.label = "!";
	else
		super.label = value;
}
}
}