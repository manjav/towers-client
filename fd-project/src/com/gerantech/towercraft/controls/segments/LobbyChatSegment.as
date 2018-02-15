package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.buttons.LobbyTabButton;
import com.gerantech.towercraft.controls.headers.LobbyHeader;
import com.gerantech.towercraft.controls.items.LobbyChatItemRenderer;
import com.gerantech.towercraft.controls.overlays.BattleStartOverlay;
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
private var donateButton:CustomButton;

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
	
	headerSize = 132 * appModel.scale;
	header = new LobbyHeader();
	header.height = headerSize;
	header.layoutData = new AnchorLayoutData(NaN, 0, NaN, 0);
	addChild(header);
	
	inputText = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.DONE, 0xAAAAAA, false, appModel.align );
	inputText.textEditorProperties.autoCorrect = true;
	inputText.height = footerSize;
	inputText.layoutData = new AnchorLayoutData(NaN, footerSize*2 + padding*3, 0, padding);
	inputText.addEventListener(FeathersEventType.ENTER, sendButton_triggeredHandler);
	addChild(inputText);

	sendButton.layoutData = new AnchorLayoutData(NaN, footerSize+padding*2, 0, NaN);

	battleButton = new CustomButton();
	battleButton.style = "danger";
	battleButton.width = battleButton.height = footerSize;
	battleButton.icon = Assets.getTexture("tab-1", "gui");
	battleButton.iconLayout = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -4 * appModel.scale);
	battleButton.layoutData = new AnchorLayoutData(NaN, padding, 0, NaN);
	battleButton.addEventListener(Event.TRIGGERED, battleButton_triggeredHandler);
	addChild(battleButton);
	
	donateButton = new CustomButton();
	donateButton.width = donateButton.height * 2;
	donateButton.icon = Assets.getTexture("tab-1", "gui");
	donateButton.iconLayout = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -4 * appModel.scale);
	donateButton.layoutData = new AnchorLayoutData(NaN, NaN, 30, padding + 10);
	donateButton.addEventListener(Event.TRIGGERED, donateButton_triggeredHandler);
	addChild(donateButton);
	
	chatLayout.paddingTop = headerSize;
	chatList.addEventListener(Event.ROOT_CREATED, chatList_triggeredHandler);
	manager.addEventListener(Event.TRIGGERED, manager_triggerHandler);	

	UserData.instance.lastLobbeyMessageTime = timeManager.now;
	UserData.instance.save();
}

override protected function chatList_createCompleteHandler(event:Event):void
{
	super.chatList_createCompleteHandler(event);
	setTimeout(chatList.addEventListener, 1000, Event.SCROLL, chatList_scrollHandler);
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

protected function chatList_scrollHandler(event:Event):void
{
	var scrollPos:Number = Math.max(0,chatList.verticalScrollPosition);
	var changes:Number = startScrollBarIndicator-scrollPos;
	header.y = Math.max(-headerSize, Math.min(0, header.y+changes));
	startScrollBarIndicator = scrollPos;
}

protected function battleButton_triggeredHandler(event:Event):void
{
	setTimeout(function():void{ buttonsEnabled = false}, 1);
	var params:SFSObject = new SFSObject();
	params.putShort("m", MessageTypes.M30_FRIENDLY_BATTLE);
	params.putShort("st", 0);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_PUBLIC_MESSAGE, params, manager.lobby );
}
protected function donateButton_triggeredHandler(event:Event):void
{
	//setTimeout(function():void{ buttonsEnabled = false}, 1);
	//var readyBattleIndex:int = getMyRequestBattleIndex();
	var params:SFSObject = new SFSObject();
	params.putShort("m", MessageTypes.M20_DONATE);
	params.putShort("st", 0); 	// state = 0 means its a request for card not doanation
	params.putShort("ct", 401);
	params.putInt("n", 0);
	var now:Date = new Date();
	var epoch:Number = Date.UTC(now.fullYear, now.month, now.date, now.hours, now.minutes, now.seconds, now.milliseconds);
	epoch /= 1000;				// convert millisec to second
	params.putLong("dt", 30 + epoch);
	trace("now(epoch):", epoch, "| dueDate", params.getInt("dt"));
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_PUBLIC_MESSAGE, params, manager.lobby );
	trace("Request donate btn");
	trace(params.getDump());
}
protected function chatList_checkDonateTimer(event:Event):void
{
	trace("scroll event listener");
	var lb:LobbyManager = new LobbyManager();
	lb.checkDonateTimer();
}

private function gotoBattle():void
{
	buttonsEnabled = true;
	var item:StackScreenNavigatorItem = appModel.navigator.getScreen( Main.BATTLE_SCREEN );
	item.properties.isFriendly = true;
	item.properties.waitingOverlay = new BattleStartOverlay(-1, false);
	appModel.navigator.addOverlay(item.properties.waitingOverlay);	
	appModel.navigator.pushScreen( Main.BATTLE_SCREEN ) ;
}

protected function manager_triggerHandler(event:Event):void
{
	gotoBattle();
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