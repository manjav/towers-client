package com.gerantech.towercraft.controls.headers
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.popups.LobbyDetailsPopup;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.Room;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.display.Quad;
import starling.events.Event;

public class LobbyHeader extends SimpleLayoutButton
{
private var room:Room;
private var roomData:ISFSObject;
private var usersDisplay:RTLLabel;

private var scoreDisplay:RTLLabel;

private var infoButton:CustomButton;

public function LobbyHeader(room:Room, roomData:ISFSObject)
{
	super();
	this.room = room;
	this.roomData = roomData;
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
	
	var nameDisplay:ShadowLabel = new ShadowLabel(room.name, 1, 0);
	nameDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?NaN:padding*2, NaN, appModel.isLTR?padding*2:NaN );
	addChild(nameDisplay);
	
	scoreDisplay = new RTLLabel(loc("lobby_sum") + ": " + roomData.getInt("sum"), 1, null, null, false, null, 0.7);
	scoreDisplay.layoutData = new AnchorLayoutData(padding*5, appModel.isLTR?NaN:padding*2, NaN, appModel.isLTR?padding*2:NaN );
	addChild(scoreDisplay);
	
	usersDisplay = new RTLLabel(loc("lobby_onlines", [room.userCount, roomData.getInt("num")]) , 0x97b81c, null, null, false, null, 0.8);
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
	if( scoreDisplay )
		scoreDisplay.text = loc("lobby_sum") + ": " + roomData.getInt("sum");
	if( usersDisplay )
		usersDisplay.text = loc("lobby_onlines", [room.userCount, roomData.getInt("num")]);
}

protected function room_userChangeHandler(event:SFSEvent):void
{
	updateRoomVariables();
}

protected function infoButton_triggeredHandler(event:Event):void
{
	var detailsPopup:LobbyDetailsPopup = new LobbyDetailsPopup({id:room.id, name:room.name, pic:roomData.getInt("pic"), num:roomData.getInt("num"), sum:roomData.getInt("sum"), all:roomData.containsKey("all")?roomData.getSFSArray("all"):null, max:room.maxUsers});
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