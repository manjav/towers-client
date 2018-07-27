package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.texts.RTLLabel;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

public class EventsListItemRenderer extends AbstractListItemRenderer
{
private var _firstCommit:Boolean = true;
private var titleDisplay:RTLLabel;
private var padding:Number;
public function EventsListItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
	padding = 12 * appModel.scale;
	layout = new AnchorLayout();
}

override protected function commitData():void
{
	if( _firstCommit )
	{
		_firstCommit = false;
	}
	
	super.commitData();
	
	if( _data == null )
		return;
	
	titleDisplay = new RTLLabel("چالش بیشترین پیروزی در نبردها", 1, "center");
	titleDisplay.layoutData = new AnchorLayoutData(padding, padding, padding);
	addChild(titleDisplay);
}
}
}