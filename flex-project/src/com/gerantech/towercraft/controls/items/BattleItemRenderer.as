package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;

import starling.events.Event;

public class BattleItemRenderer extends AbstractTouchableListItemRenderer
{
private static const DEFAULT_TEXT_COLOR:uint = 0xDDFFFF;

private var allisNameDisplay:RTLLabel;
private var axisNameDisplay:RTLLabel;
private var allisLobbyNameDisplay:RTLLabel;
private var axisLobbyNameDisplay:RTLLabel;
private var allisLobbyIconDisplay:ImageLoader;
private var axisLobbyIconDisplay:ImageLoader;
private var timeDisplay:RTLLabel;

private var room:SFSObject;
private var spectateButton:CustomButton;

override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	height = 260 * appModel.scale;
	var padding:int = 20 * appModel.scale;
	
	var mySkin:ImageSkin = new ImageSkin(appModel.theme.itemRendererDisabledSkinTexture);
	mySkin.scale9Grid = BaseMetalWorksMobileTheme.ITEM_RENDERER_SCALE9_GRID
	backgroundSkin = mySkin;
	
	allisLobbyIconDisplay = new ImageLoader();
	allisLobbyIconDisplay.width = 90 * appModel.scale;
	allisLobbyIconDisplay.layoutData = new AnchorLayoutData(padding, padding, NaN, NaN);
	addChild(allisLobbyIconDisplay);
	
	axisLobbyIconDisplay = new ImageLoader();
	axisLobbyIconDisplay.width = 90 * appModel.scale;
	axisLobbyIconDisplay.layoutData = new AnchorLayoutData(padding, NaN, NaN, padding);
	addChild(axisLobbyIconDisplay);
		
	spectateButton = new CustomButton();
	spectateButton.height = padding * 6;
	spectateButton.label = loc("lobby_battle_spectate");
	spectateButton.layoutData = new AnchorLayoutData(NaN, padding, padding, NaN);
	addChild(spectateButton);

	allisNameDisplay = new RTLLabel("", 0x007AFF, null, null, false, null, 0.8);
	allisNameDisplay.pixelSnapping = false;
	allisNameDisplay.layoutData = new AnchorLayoutData(padding, padding * 7);
	addChild(allisNameDisplay);
	
	allisLobbyNameDisplay = new RTLLabel("", 0, null, null, false, null, 0.7);
	allisLobbyNameDisplay.pixelSnapping = false;
	allisLobbyNameDisplay.layoutData = new AnchorLayoutData(padding * 4, padding * 7);
	addChild(allisLobbyNameDisplay);
	
	axisNameDisplay = new RTLLabel("", 0xF20C1A, null, null, false, null, 0.8);
	axisNameDisplay.pixelSnapping = false;
	axisNameDisplay.layoutData = new AnchorLayoutData(padding, NaN, NaN, padding * 7);
	addChild(axisNameDisplay);
	
	axisLobbyNameDisplay = new RTLLabel("", 0, null, null, false, null, 0.7);
	axisLobbyNameDisplay.pixelSnapping = false;
	axisLobbyNameDisplay.layoutData = new AnchorLayoutData(padding * 4, NaN, NaN, padding * 7);
	addChild(axisLobbyNameDisplay);
	
	timeDisplay = new RTLLabel("", 1, appModel.isLTR?"right":"left", null, false, null, 0.9);
	timeDisplay.pixelSnapping = false;
	timeDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding, padding);
	addChild(timeDisplay);
	
	//addEventListener(Event.TRIGGERED, item_triggeredHandler);
}

override protected function commitData():void
{
	super.commitData();
	if( _data ==null || _owner==null )
		return;
	
	timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
	timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
	room = _data as SFSObject;
	
	var allis:ISFSObject = room.getSFSArray("players").getSFSObject(0);
	allisNameDisplay.text = allis.getText("n");
	allisLobbyNameDisplay.text = allis.containsKey("ln") ? allis.getText("ln") : "???";
	allisLobbyIconDisplay.source = allis.containsKey("lp") ? Assets.getTexture("emblems/emblem-"+StrUtils.getZeroNum(allis.getInt("lp")+""), "gui") : null;
	
	if( room.getSFSArray("players").size() > 1 )
	{
	var axis:ISFSObject = room.getSFSArray("players").getSFSObject(1);
	axisNameDisplay.text = axis.getText("n");
	axisLobbyNameDisplay.text = axis.containsKey("ln") ? axis.getText("ln") : "???";
	axisLobbyIconDisplay.source = axis.containsKey("lp") ? Assets.getTexture("emblems/emblem-"+StrUtils.getZeroNum(axis.getInt("lp")+""), "gui") : null;
	}
	
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


