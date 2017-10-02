package com.gerantech.towercraft.controls.toasts
{
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.display.Quad;

public class SimpleToast extends BaseToast
{
private var message:String;

public function SimpleToast(message:String)
{
	this.message = message;
	super();
}
override protected function initialize():void
{
	toastHeight = 120;
	var padding:int = 16 * appModel.scale;
	layout = new AnchorLayout();
	super.initialize();
	
	backgroundSkin = new Quad(1,1);
	
	var messageDisplay:RTLLabel = new RTLLabel(message, 1, "center", null, true, null, 0.8);
	messageDisplay.layoutData = new AnchorLayoutData(padding, padding, padding, padding);
	addChild(messageDisplay);
}
}
}