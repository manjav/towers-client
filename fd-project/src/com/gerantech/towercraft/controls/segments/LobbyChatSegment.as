package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.headers.LobbyHeader;
import com.gerantech.towercraft.controls.items.lobby.LobbyChatItemRenderer;
import com.gerantech.towercraft.controls.overlays.BattleStartOverlay;
import com.gerantech.towercraft.controls.overlays.BattleWaitingOverlay;
import com.gerantech.towercraft.controls.texts.CustomTextInput;
import com.gerantech.towercraft.managers.net.sfs.LobbyManager;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.UserData;
import com.gt.towers.constants.MessageTypes;
import com.smartfoxserver.v2.entities.data.SFSObject;

import flash.text.ReturnKeyLabel;
import flash.text.SoftKeyboardType;
import flash.utils.setTimeout;

import feathers.controls.StackScreenNavigatorItem;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;

import starling.events.Event;

public class LobbyChatSegment extends LobbyBaseChatSegment
{
private var headerSize:int;
private var startScrollBarIndicator:Number = 0;
private var battleButton:CustomButton;
private var header:LobbyHeader;

public function LobbyChatSegment(){}

override public function get manager():LobbyManager
{
	return SFSConnection.instance.lobbyManager;
}

override protected function loadData():void
{
	if( manager.isReady )
		showElements();
	else
		manager.addEventListener(Event.READY, manager_readyHandler);
}

override protected function showElements():void
{
	super.showElements();
	
	headerSize = 132;
	header = new LobbyHeader();
	header.height = headerSize;
	header.layoutData = new AnchorLayoutData(NaN, 0, NaN, 0);
	addChild(header);
	
	battleButton = new CustomButton();
	battleButton.style = "danger";
	battleButton.width = battleButton.height = footerSize;
	battleButton.icon = Assets.getTexture("home/tab-2", "gui");
	battleButton.iconLayout = new AnchorLayoutData(-padding, -padding, -padding, -padding);
    battleButton.layoutData = new AnchorLayoutData(NaN, NaN, padding * 2, padding);
	battleButton.addEventListener(Event.TRIGGERED, battleButton_triggeredHandler);
	addChild(battleButton);
	
	chatLayout.paddingTop = headerSize;
	chatList.addEventListener(Event.ROOT_CREATED, chatList_triggeredHandler);
	manager.addEventListener(Event.TRIGGERED, manager_triggerHandler);	

	UserData.instance.lastLobbeyMessageTime = timeManager.now;
	UserData.instance.save();
}

protected function chatList_triggeredHandler(event:Event):void
{
	var selectedItem:LobbyChatItemRenderer = event.data[0] as LobbyChatItemRenderer;
	var params:SFSObject = event.data[1] as SFSObject;
	// show info
	if( params.getShort("pr") == MessageTypes.M10_COMMENT_JOINT )
	{
		var sfs:SFSObject = new SFSObject();
		sfs.putInt("i", params.getInt("o"));
		sfs.putUtfString("s", params.getUtfString("on"));
		showSimpleListPopup(sfs, selectedItem, "lobby_profile");
		return;
	}
	// accept or reject
	if( MessageTypes.isConfirm(params.getShort("m")) )
		SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_PUBLIC_MESSAGE, params, manager.lobby );
}

override protected function scrollChatList(changes:Number) : void
{
    super.scrollChatList(changes);
    header.y = Math.max(-headerSize, Math.min(0, header.y+changes));
}

protected function battleButton_triggeredHandler(event:Event):void
{
	setTimeout(function():void{ buttonsEnabled = false}, 1);
	var params:SFSObject = new SFSObject();
	params.putShort("m", MessageTypes.M30_FRIENDLY_BATTLE);
	params.putShort("st", 0);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_PUBLIC_MESSAGE, params, manager.lobby );
    scrollToEnd();
}

protected function manager_triggerHandler(event:Event):void
{
	buttonsEnabled = true;
	appModel.navigator.runBattle(false, null, null, true);
}

override public function enabledChatting(value:Boolean):void
{
    super.enabledChatting(value);
    battleButton.visible = !value;
}

override public function set buttonsEnabled(value:Boolean):void
{
	super.buttonsEnabled = value;
	header.isEnabled = _buttonsEnabled;
	battleButton.isEnabled = _buttonsEnabled;
}

override public function dispose():void
{
	if( manager != null )
		manager.removeEventListener(Event.TRIGGERED, manager_triggerHandler);
	super.dispose();
}
}
}