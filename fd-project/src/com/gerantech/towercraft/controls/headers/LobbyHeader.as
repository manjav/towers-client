package com.gerantech.towercraft.controls.headers
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.popups.LobbyDetailsPopup;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.managers.net.sfs.LobbyManager;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.smartfoxserver.v2.core.SFSEvent;

import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.display.Quad;
import starling.events.Event;

public class LobbyHeader extends SimpleLayoutButton
{
private var usersDisplay:RTLLabel;
private var scoreDisplay:RTLLabel;
private var infoButton:CustomButton;
private var manager:LobbyManager;

public function LobbyHeader()
{
	super();
	manager = SFSConnection.instance.lobbyManager;
	//this.roomData = roomData;
	updateRoomVariables();
	SFSConnection.instance.addEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, sfsConnection_roomVariablesUpdateHandler);
	SFSConnection.instance.addEventListener(SFSEvent.USER_ENTER_ROOM, room_userChangeHandler);
	SFSConnection.instance.addEventListener(SFSEvent.USER_EXIT_ROOM, room_userChangeHandler);
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	var padding:int = 16 * appModel.scale;
	
	backgroundSkin = new Quad(1,1,0);
	backgroundSkin.alpha = 0.8;
	
	var nameDisplay:ShadowLabel = new ShadowLabel(manager.lobby.name, 1, 0);
	nameDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?NaN:padding*2, NaN, appModel.isLTR?padding*2:NaN );
	addChild(nameDisplay);
	
	scoreDisplay = new RTLLabel(loc("lobby_sum") + ": " + manager.point, 1, null, null, false, null, 0.7);
	scoreDisplay.layoutData = new AnchorLayoutData(padding*5, appModel.isLTR?NaN:padding*2, NaN, appModel.isLTR?padding*2:NaN );
	addChild(scoreDisplay);
	
	usersDisplay = new RTLLabel(loc("lobby_onlines", [manager.lobby.userCount, manager.members.size()]) , 0x97b81c, null, null, false, null, 0.8);
	usersDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?padding*9:NaN, NaN, appModel.isLTR?NaN:padding*9, NaN, -padding*0.5 );
	addChild(usersDisplay);
	
	infoButton = new CustomButton();
	infoButton.label = "i";
	infoButton.width = infoButton.height = 84 * appModel.scale;
	infoButton.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?padding*2:NaN, NaN, appModel.isLTR?NaN:padding*2 , NaN, -padding*0.5);
	addEventListener(Event.TRIGGERED, infoButton_triggeredHandler);
	addChild(infoButton);
}

protected function sfsConnection_roomVariablesUpdateHandler(event:SFSEvent):void
{
	updateRoomVariables();
}

private function updateRoomVariables():void
{
	if( usersDisplay )
		usersDisplay.text = loc("lobby_onlines", [manager.lobby.userCount, manager.members.size()]);
}

protected function room_userChangeHandler(event:SFSEvent):void
{
	updateRoomVariables();
}

protected function infoButton_triggeredHandler(event:Event):void
{
	var detailsPopup:LobbyDetailsPopup = new LobbyDetailsPopup({id:manager.lobby.id, name:manager.lobby.name, pic:manager.emblem, num:manager.members.size(), sum:manager.point, all:manager.members, max:manager.lobby.maxUsers});
	detailsPopup.addEventListener(Event.UPDATE, detailsPopup_updateHandler);
	appModel.navigator.addPopup(detailsPopup);
	function detailsPopup_updateHandler(ev:Event):void 
	{
		detailsPopup.removeEventListener(Event.UPDATE, detailsPopup_updateHandler);
		dispatchEventWith(Event.UPDATE, true, ev.data);
	}
}

override public function set isEnabled(value:Boolean):void
{
	super.isEnabled = value;
	infoButton.isEnabled = value;
}


override public function dispose():void
{
	SFSConnection.instance.addEventListener(SFSEvent.ROOM_VARIABLES_UPDATE, sfsConnection_roomVariablesUpdateHandler);
	SFSConnection.instance.removeEventListener(SFSEvent.USER_EXIT_ROOM, room_userChangeHandler);
	SFSConnection.instance.removeEventListener(SFSEvent.USER_ENTER_ROOM, room_userChangeHandler);
	super.dispose();
}
}
}