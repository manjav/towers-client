package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.controls.items.lobby.LobbyChatItemRenderer;
import com.gerantech.towercraft.controls.popups.ConfirmPopup;
import com.gerantech.towercraft.controls.popups.ProfilePopup;
import com.gerantech.towercraft.controls.popups.SimpleListPopup;
import com.gerantech.towercraft.controls.toasts.EmoteToast;
import com.gerantech.towercraft.managers.net.sfs.LobbyManager;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.MessageTypes;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.controls.Button;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class LobbyBaseChatSegment extends ChatSegment
{
private var preText:String = "";
protected var emotesButton:Button;
public function LobbyBaseChatSegment(){ super(); }
public function get manager():LobbyManager
{
	if( SFSConnection.instance.publicLobbyManager == null )
		SFSConnection.instance.publicLobbyManager = new LobbyManager(true);
	return SFSConnection.instance.publicLobbyManager;
}

override protected function animation_loadCallback():void
{
	super.animation_loadCallback();
	loadData();
}

override public function init():void
{
	if( initializeStarted )
		return;
	
	super.init();
	layout = new AnchorLayout();
	loadData();
}

protected function loadData():void
{
	if( manager == null || !initializeStarted || initializeCompleted || ChatSegment.factory == null )
		return;
	
	if( manager.isReady )
	{
		showElements();
		return;
	}
	manager.addEventListener(Event.READY, manager_readyHandler);
	manager.joinToPublic();
}

protected function manager_readyHandler(event:Event) : void
{
	manager.removeEventListener(Event.READY, manager_readyHandler);
	showElements();
}

override protected function showElements() : void
{
	super.showElements();
	
    emotesButton = new Button();
	emotesButton.styleName = MainTheme.STYLE_SMALL_NEUTRAL_BUTTON;
    emotesButton.width = emotesButton.height = footerSize;
    emotesButton.defaultIcon = new Image(Assets.getTexture("socials/icon-emote", "gui"));
    emotesButton.layoutData = new AnchorLayoutData(NaN, padding * 2 + footerSize, padding * 2, NaN);
    emotesButton.addEventListener(Event.TRIGGERED, emotesButton_triggeredHandler);
    addChild(emotesButton);
	
	var params:SFSObject = new SFSObject();
	params.putInt("i", 12179);
	params.putInt("e", 0);
	params.putUtfString("s", "sdfsdf");
	params.putShort("m", MessageTypes.M51_EMOTE);
	manager.messages.addItem(params);
	params = new SFSObject();
	params.putInt("i", 10004);
	params.putInt("e", 1);
	params.putUtfString("s", "ManJav");
	params.putShort("m", MessageTypes.M51_EMOTE);
	manager.messages.addItem(params);
	params = new SFSObject();
	params.putInt("i", 12179);
	params.putInt("e", 2);
	params.putUtfString("s", "ManJav");
	params.putShort("m", MessageTypes.M51_EMOTE);
	manager.messages.addItem(params);
	params = new SFSObject();
	params.putInt("i", 10004);
	params.putInt("e", 3);
	params.putUtfString("s", "ManJav");
	params.putShort("m", MessageTypes.M51_EMOTE);
	manager.messages.addItem(params);
	params = new SFSObject();
	params.putInt("i", 12179);
	params.putInt("e", 4);
	params.putUtfString("s", "ManJav");
	params.putShort("m", MessageTypes.M51_EMOTE);
	manager.messages.addItem(params);
	chatList.dataProvider = manager.messages;
	manager.addEventListener(Event.UPDATE, manager_updateHandler);
}

override protected function chatList_changeHandler(event:Event) : void
{
	if( chatList.selectedItem == null )
		return;
	var msgPack:ISFSObject = chatList.selectedItem as SFSObject;
	if( msgPack.getShort("m") == MessageTypes.M30_FRIENDLY_BATTLE  )
	{
		var myBattleId:int = manager.getMyRequestBattleId();
		if( myBattleId > -1 && msgPack.getInt("bid") != myBattleId )
			return;
		
		if( msgPack.getShort("st") > 1 )
			return;
		
		var params:SFSObject = new SFSObject();
		params.putShort("m", MessageTypes.M30_FRIENDLY_BATTLE);
		params.putInt("bid", msgPack.getInt("bid"));
		params.putShort("st", msgPack.getShort("st"));
		SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_PUBLIC_MESSAGE, params, manager.lobby );
	}
}

override protected function chatList_focusInHandler(event:Event):void
{
    if( !_buttonsEnabled )
        return;
	var selectedItem:LobbyChatItemRenderer = event.data as LobbyChatItemRenderer;
	if( selectedItem == null )
		return;
	
	var msgPack:ISFSObject = selectedItem.data as ISFSObject;
	// prevent hints for my messages
	if( msgPack.getInt("i") != player.id && msgPack.getShort("m") == MessageTypes.M0_TEXT )
		showSimpleListPopup(msgPack, selectedItem, buttonsPopup_selectHandler, buttonsPopup_selectHandler, "lobby_report", "lobby_profile", "lobby_reply");
}

override protected function buttonsPopup_selectHandler(event:Event):void
{
	var buttonsPopup:SimpleListPopup = event.currentTarget as SimpleListPopup;
	buttonsPopup.removeEventListener(Event.SELECT, buttonsPopup_selectHandler);
	buttonsPopup.removeEventListener(Event.CLOSE, buttonsPopup_selectHandler);
	
	if( event.type == Event.CLOSE )
		return;
	
	var msgPack:ISFSObject = buttonsPopup.data as ISFSObject;
	switch( event.data )
	{
		case "lobby_profile":
            var user:Object = {name:msgPack.getUtfString("s"), id:int(msgPack.getInt("i"))};
            if( !manager.isPublic )
            {
                user.ln = manager.lobby.name;
                user.lp = manager.emblem;
            }
            appModel.navigator.addPopup( new ProfilePopup(user) );
			break;
		
		case "lobby_report":
			var confirm:ConfirmPopup = new ConfirmPopup(loc("popup_sure_label"), loc("popup_yes_label"));
			confirm.acceptStyle = "danger";
			confirm.addEventListener(Event.SELECT, confirm_selectHandler);
			appModel.navigator.addPopup(confirm);
			break;
		
		case "lobby_reply":
			chatButton_triggeredHandler(null);
			var msg:String = msgPack.getUtfString("t");
			preText = "@" + msgPack.getUtfString("s") + ": " + msg.substr(msg.lastIndexOf("\n") + 1, 20) + "... :\n";
			break;
	}
	function confirm_selectHandler(evet:Event):void
	{
		var sfsReport:ISFSObject = new SFSObject();
		sfsReport.putUtfString("t", msgPack.getUtfString("t"));
		sfsReport.putInt("i", msgPack.getInt("i"));
		sfsReport.putInt("u", msgPack.getInt("u"));
		SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_reportResponseHandler);
		SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_REPORT, sfsReport, manager.lobby);
	}
	function sfs_reportResponseHandler(e:SFSEvent):void
	{
		if( e.params.cmd != SFSCommands.LOBBY_REPORT )
			return;
		SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_reportResponseHandler);
		appModel.navigator.addLog(loc("lobby_report_response_" + e.params.params.getInt("response")) );
	}
}

protected function manager_updateHandler(event:Event):void
{
	if( Starling.current.nativeStage.frameRate < 1 )
		return;
	UserData.instance.lastLobbeyMessageTime = timeManager.now;
	buttonsEnabled = manager.getMyRequestBattleIndex() == -1;
	chatList.validate();
    if( autoScroll )
        scrollToEnd();
}

override protected function chatButton_triggeredHandler(event:Event):void
{
    super.chatButton_triggeredHandler(event);
	preText = "";
}

protected function emotesButton_triggeredHandler(event:Event) : void 
{
	scrollToEnd();
	appModel.navigator.addToast(new EmoteToast());
}

override protected function sendButton_triggeredHandler(event:Event):void
{
	if( chatTextInput.text == "" )
		return;
	if( areUVerbose() )
	{
		appModel.navigator.addLog(loc("lobby_message_limit"));
		return;
	}
	var params:SFSObject = new SFSObject();
	params.putUtfString("t", preText + StrUtils.getSimpleString(chatTextInput.text));
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_PUBLIC_MESSAGE, params, manager.lobby );
	chatTextInput.text = preText = "";
}

private function areUVerbose():Boolean 
{
	var last:ISFSObject = manager.messages.getItemAt(manager.messages.length - 1) as SFSObject;
	if ( last != null && last.getInt("i") == player.id && last.containsKey("t") )
		return (last.getText("t").split("\n").length > 5 );
	return false;
}

override public function dispose():void
{
	if( manager != null )
		manager.removeEventListener(Event.UPDATE, manager_updateHandler);
	super.dispose();
}
}
}