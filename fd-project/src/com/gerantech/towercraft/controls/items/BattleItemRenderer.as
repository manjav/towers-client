package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	import com.gerantech.towercraft.utils.StrUtils;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.skins.ImageSkin;
	
	import starling.events.Event;

public class BattleItemRenderer extends AbstractTouchableListItemRenderer
{
private static const DEFAULT_TEXT_COLOR:uint = 0xDDFFFF;

private var nameDisplay:RTLLabel;
private var timeDisplay:RTLLabel;
private var pointIconDisplay:ImageLoader;
private var usersDisplay:RTLLabel;

private var room:SFSObject;

override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	var padding:int = 36 * appModel.scale;
	
	var mySkin:ImageSkin = new ImageSkin(appModel.theme.itemRendererUpSkinTexture);
	mySkin.scale9Grid = BaseMetalWorksMobileTheme.ITEM_RENDERER_SCALE9_GRID
	backgroundSkin = mySkin;

	nameDisplay = new RTLLabel("", DEFAULT_TEXT_COLOR, null, null, false, null, 0.8);
	nameDisplay.pixelSnapping = false;
	nameDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN, NaN, -padding*0.7);
	addChild(nameDisplay);
	
	usersDisplay = new RTLLabel("", 0, null, null, false, null, 0.7);
	usersDisplay.pixelSnapping = false;
	usersDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN, NaN, padding*0.5);
	addChild(usersDisplay);
	
/*	activityDisplay = new RTLLabel("", 1, "center", null, false, null, 0.9);
	activityDisplay.width = padding * 3
	activityDisplay.pixelSnapping = false;
	activityDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?padding*8:NaN, NaN, appModel.isLTR?NaN:padding*8, NaN, 0);
	addChild(activityDisplay);*/
	
	timeDisplay = new RTLLabel("", 1, appModel.isLTR?"right":"left", null, false, null, 0.9);
	timeDisplay.pixelSnapping = false;
	timeDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding, NaN, 0);
	addChild(timeDisplay);
	//addEventListener(Event.TRIGGERED, item_triggeredHandler);
}

override protected function commitData():void
{
	super.commitData();
	if(_data ==null || _owner==null)
		return;
	
	timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
	timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
	height = 120 * appModel.scale;
	room = _data as SFSObject;
	nameDisplay.text = room.getText("name") ;
	usersDisplay.text = room.getText("users").substr(0, room.getText("users").length-1);
	timeDisplay.text =  StrUtils.toTimeFormat(timeManager.now - room.getInt("startAt")) ;
}

private function timeManager_changeHandler(event:Event):void
{
	timeDisplay.text =  StrUtils.toTimeFormat(timeManager.now - room.getInt("startAt")) ;
}

override public function dispose():void
{
	timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
	super.dispose();
}


}
}


