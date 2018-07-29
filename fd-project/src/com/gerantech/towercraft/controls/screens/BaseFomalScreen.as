package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.headers.CloseFooter;
import com.gerantech.towercraft.controls.headers.ScreenHeader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.events.Event;

public class BaseFomalScreen extends BaseCustomScreen
{
public var title:String = "";
protected var header:ScreenHeader;
protected var footer:CloseFooter;
protected var headerSize:int = 0;

public function BaseFomalScreen(){super();}
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	headerSize = 150;
	
	header = new ScreenHeader(title);
	header.height = headerSize;
	header.layoutData = new AnchorLayoutData(NaN, 0, NaN, 0);
	addChild(header);
	
	footer = new CloseFooter();
	footer.layoutData = new AnchorLayoutData(NaN, 0,  0, 0);
	footer.addEventListener(Event.CLOSE, backButtonHandler);
	addChild(footer);
}
}
}