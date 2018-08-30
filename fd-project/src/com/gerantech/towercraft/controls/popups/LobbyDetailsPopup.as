package com.gerantech.towercraft.controls.popups
{
import com.gerantech.extensions.NativeAbilities;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.buttons.EmblemButton;
import com.gerantech.towercraft.controls.buttons.LobbyTabButton;
import com.gerantech.towercraft.controls.items.lobby.LobbyFeatureItemRenderer;
import com.gerantech.towercraft.controls.items.lobby.LobbyMemberItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gt.towers.constants.MessageTypes;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.Room;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.events.Event;

public class LobbyDetailsPopup extends SimplePopup
{
private var responseCode:int;
private var roomData:Object;
private var roomServerData:ISFSObject;
private var itsMyRoom:Boolean;
private var buttonsPopup:SimpleListPopup;
private var memberList:Array;
private var memberCollection:ListCollection;
private var tabs:Vector.<LobbyTabButton>;

public function LobbyDetailsPopup(roomData:Object)
{
	this.roomData = roomData;
	
	var params:SFSObject = new SFSObject();
	params.putInt("id", roomData.id);
	if( roomData.name == null )
		params.putBool("data", true);
	//if( roomData.all == null )
		params.putBool("all", true);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_roomDataHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_DATA, params);
}

override protected function initialize():void
{
	super.initialize();
	transitionOut.destinationBound = transitionIn.sourceBound = new Rectangle(stage.stageWidth * 0.05, stage.stageHeight * 0.06, stage.stageWidth * 0.9, stage.stageHeight * 0.88);
	transitionOut.sourceBound = transitionIn.destinationBound = new Rectangle(stage.stageWidth * 0.05, stage.stageHeight * 0.04, stage.stageWidth * 0.9, stage.stageHeight * 0.92);
	rejustLayoutByTransitionData();
	
	var iconDisplay:EmblemButton = new EmblemButton(roomData.pic);
	iconDisplay.touchable = false;
	iconDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN);
	iconDisplay.width = padding * 4.0;
	iconDisplay.height = padding * 4.2
	addChild(iconDisplay);

	var titleDisplay:RTLLabel = new RTLLabel(roomData.name);
	titleDisplay.layoutData = new AnchorLayoutData(padding * 0.8, appModel.isLTR?padding:padding * 6, NaN, appModel.isLTR?padding * 6:padding);
	addChild(titleDisplay);
}

protected function sfsConnection_roomDataHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.LOBBY_DATA )
		return;
	
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_roomDataHandler);
	roomServerData = event.params.params as SFSObject;
	
	if( roomServerData.containsKey("name") )
		roomData.name = roomServerData.getText("name");
	if( roomServerData.containsKey("max") )
		roomData.name = roomServerData.getInt("max");
	if( roomServerData.containsKey("num") )
		roomData.name = roomServerData.getInt("num");
	if( roomServerData.containsKey("sum") )
		roomData.name = roomServerData.getInt("sum");
	if( roomServerData.containsKey("pic") )
		roomData.name = roomServerData.getInt("pic");
	if( roomServerData.containsKey("act") )
		roomData.name = roomServerData.getInt("act");
	if( roomServerData.containsKey("all") )
		roomData.all = roomServerData.getSFSArray("all");
	
	roomData.bio = roomServerData.getText("bio");
	roomData.min = roomServerData.getInt("min")
	roomData.pri = roomServerData.getInt("pri");
	if( transitionState >= TransitionData.STATE_IN_COMPLETED )
		showDetails();
}
protected override function transitionInCompleted():void
{
	super.transitionInCompleted();
	if( roomServerData != null )
		showDetails();
}

private function showDetails():void
{
	var bioDisplay:RTLLabel = new RTLLabel(roomData.bio, 1, "justify", null, true, null, 0.6);
	bioDisplay.layoutData = new AnchorLayoutData(padding * 3.4, appModel.isLTR?padding:padding * 6, NaN, appModel.isLTR?padding * 6 : padding);
	addChild(bioDisplay);
	
	var features:Array = new Array();
	features.push( {key:"min", value:roomData.min} );
	features.push( {key:"sum", value:roomData.sum} );
	features.push( {key:"max", value:roomData.max} );
	features.push( {key:"pri", value:roomData.pri} );
	
	//trace(sfsData.getDump())
	var featureList:List = new List();
	featureList.layoutData = new AnchorLayoutData(padding * 7, padding * 2, NaN, padding * 2);
	featureList.horizontalScrollPolicy = featureList.verticalScrollPolicy = ScrollPolicy.OFF;
	featureList.itemRendererFactory = function ():IListItemRenderer { return new LobbyFeatureItemRenderer(); }
	featureList.dataProvider = new ListCollection(features);
	addChild(featureList);
	
	tabs = new Vector.<LobbyTabButton>();
	tabs[0] = new LobbyTabButton(loc("lobby_point"), true);
	tabs[0].addEventListener(Event.TRIGGERED, tabs_triggeredHandler);
	tabs[0].layoutData = new AnchorLayoutData( padding * 16, appModel.isLTR?padding * 2.5:NaN, NaN, appModel.isLTR?NaN:padding * 2.5);
	addChild(tabs[0]);
	tabs[1] = new LobbyTabButton(loc("lobby_activeness"), true);
	tabs[1].addEventListener(Event.TRIGGERED, tabs_triggeredHandler);
	tabs[1].layoutData = new AnchorLayoutData( padding * 16, appModel.isLTR?padding * 7.5:NaN, NaN, appModel.isLTR?NaN:padding * 7.5);
	tabs[1].isEnabled = false;
	addChild(tabs[1]);
	
	memberList = SFSArray(roomData.all).toArray();
	memberCollection = new ListCollection(memberList);
	
	var membersList:List = new List();
	membersList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	membersList.layoutData = new AnchorLayoutData(padding * 18.5, padding, padding, padding);
	membersList.itemRendererFactory = function():IListItemRenderer { return new LobbyMemberItemRenderer(); }
	membersList.addEventListener(FeathersEventType.FOCUS_IN, membersList_focusInHandler);
	membersList.dataProvider = memberCollection;
	addChild(membersList);
	
	var lobby:Room = SFSConnection.instance.lobbyManager.lobby;
	itsMyRoom = lobby != null && lobby.id == roomData.id;
	
	var joinleaveButton:CustomButton = new CustomButton();
	joinleaveButton.disableSelectDispatching = true;
	joinleaveButton.width = (roomServerData.getInt("pri") == 0 || itsMyRoom?240:370) * appModel.scale;
	joinleaveButton.height = 96 * appModel.scale;
	joinleaveButton.visible = roomServerData.getInt("pri") < 2 || itsMyRoom;
	joinleaveButton.isEnabled = (roomData.num < roomData.max && player.get_point() >= roomData.min) || itsMyRoom || player.admin;
	joinleaveButton.layoutData = new AnchorLayoutData(padding * 13.2, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding);
	joinleaveButton.label = loc(itsMyRoom ? "lobby_leave_label" : (roomServerData.getInt("pri") == 0?"lobby_join_label":"lobby_request_label"));
	joinleaveButton.style = itsMyRoom ? "danger" : "neutral";
	joinleaveButton.addEventListener(Event.TRIGGERED, joinleaveButton_triggeredHandler);
	joinleaveButton.addEventListener(Event.SELECT, joinleaveButton_selectHandler);
	addChild(joinleaveButton);
	
	if( player.admin )
	{
		var removeButton:CustomButton = new CustomButton();
		removeButton.style = "danger";
		removeButton.label = "X";
		removeButton.layoutData = new AnchorLayoutData(padding * 13.2, appModel.isLTR?padding + 350:NaN, NaN, appModel.isLTR?NaN:padding + 350);
		removeButton.width = removeButton.height = 96 * appModel.scale;
		removeButton.addEventListener(Event.TRIGGERED, removeButton_triggeredHandler);
		addChild(removeButton);
	}
	
	var closeButton:CustomButton = new CustomButton();
	closeButton.style = "danger";
	closeButton.label = "X";
	closeButton.layoutData = new AnchorLayoutData(padding * 0.5, appModel.isLTR?padding * 0.5:NaN, NaN,  appModel.isLTR?NaN:padding * 0.5);
	closeButton.width = closeButton.height = 96 * appModel.scale;
	closeButton.addEventListener(Event.TRIGGERED, closeButton_triggeredHandler);
	addChild(closeButton);
	
	if( !itsMyRoom )
		return;
	
	var shareButton:CustomButton = new CustomButton();
	shareButton.layoutData = new AnchorLayoutData(padding * 0.5, appModel.isLTR?128:NaN, NaN, appModel.isLTR?NaN:128);
	shareButton.label = loc("lobby_invite");
	shareButton.width = 170 * appModel.scale;
	shareButton.height = 96 * appModel.scale;
	shareButton.addEventListener(Event.TRIGGERED, shareButton_triggeredHandler);
	addChild(shareButton);
	
	var u:Object = findUser(player.id);
	if( (u == null || u.permission <= 1) && !player.admin )
		return;
	
	var editButton:CustomButton = new CustomButton();
	editButton.layoutData = new AnchorLayoutData(padding * 0.5, appModel.isLTR?300:NaN, NaN, appModel.isLTR?NaN:300);
	editButton.label = loc("lobby_edit");
	editButton.width = 160 * appModel.scale;
	editButton.height = 96 * appModel.scale;
	editButton.addEventListener(Event.TRIGGERED, editButton_triggeredHandler);
	addChild(editButton);
}

private function removeButton_triggeredHandler(e:Event):void 
{
	var confirm:ConfirmPopup = new ConfirmPopup(loc("lobby_remove_confirm"));
	confirm.acceptStyle = "danger";
	confirm.addEventListener(Event.SELECT, confirm_selectHandler);
	appModel.navigator.addPopup(confirm);
	function confirm_selectHandler(event:Event):void
	{
		confirm.removeEventListener(Event.SELECT, confirm_selectHandler);
		var params:SFSObject = new SFSObject();
		params.putInt("id", roomData.id);
		SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_REMOVE, params);
		SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_lobbyRemoveHandler);
	}
	function sfs_lobbyRemoveHandler(event:SFSEvent):void
	{
		if( event.params.cmd != SFSCommands.LOBBY_REMOVE )
			return;
		SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_lobbyRemoveHandler);
		appModel.navigator.addLog(event.params.params.getInt("response"));
		trace(event.params.params.getDump());
	}
}

private function shareButton_triggeredHandler():void
{
	NativeAbilities.instance.shareText(loc("lobby_invite"), loc("lobby_invite_message")+ "\n" + loc("lobby_invite_url", [roomData.id, player.invitationCode]));
	trace(loc("lobby_invite_url", [roomData.id, player.invitationCode]))
}

private function tabs_triggeredHandler(event:Event):void
{
	setTimeout(function(sb:LobbyTabButton):void{
		for each ( var b:LobbyTabButton in tabs )
		b.isEnabled = b != sb;
	}, 10, event.currentTarget);
	
	var searchMode:int = tabs.indexOf(event.currentTarget as LobbyTabButton);
	memberList.sortOn(searchMode == 0?"point":"activity", Array.NUMERIC | Array.DESCENDING);
	memberCollection.data = memberList;
	memberCollection.updateAll()
}

private function membersList_focusInHandler(event:Event):void
{
	var selectedItem:LobbyMemberItemRenderer = event.data as LobbyMemberItemRenderer;
	if( selectedItem == null )
		return;
	
	var selectedData:Object = selectedItem.data;
	selectedData.index = selectedItem.index;

	var btns:Array = ["lobby_profile"];//trace(findUser(player.id).pr , selectedData.pr)
	if( selectedData.id != player.id )
	{
		var user:Object = findUser(player.id);
		if( user != null && user.permission != null && user.permission > selectedData.permission )
		{
			if( user.permission > selectedData.permission )
			{
				if( user.permission > selectedData.permission + 1 )
					btns.push( "lobby_promote" );
				if( selectedData.permission > 0 )
					btns.push( "lobby_demote" );
				if( user.permission > 1 )
					btns.push( "lobby_kick" );
			}
		}
	}
	buttonsPopup = new SimpleListPopup();
	buttonsPopup.buttons = btns;
	buttonsPopup.data = selectedData;
	buttonsPopup.addEventListener(Event.SELECT, buttonsPopup_selectHandler);
	buttonsPopup.padding = 24 * appModel.scale;
	buttonsPopup.buttonsWidth = 320 * appModel.scale;
	buttonsPopup.buttonHeight = 120 * appModel.scale;
	var floatingW:int = buttonsPopup.buttonsWidth + buttonsPopup.padding * 2;
	var floatingH:int = buttonsPopup.buttonHeight * buttonsPopup.buttons.length + buttonsPopup.padding * 2;
	var floatingY:int = selectedItem.getBounds(stage).y
	var ti:TransitionData = new TransitionData(0.2);
	var to:TransitionData = new TransitionData(0.2);
	to.sourceConstrain = ti.destinationConstrain = stage.getBounds(stage);
	ti.transition = Transitions.EASE_OUT_BACK;
	to.sourceAlpha = 1;
	to.destinationAlpha = 0;
	to.destinationBound = ti.sourceBound = new Rectangle(selectedItem.getTouch().globalX-floatingW/2, floatingY+buttonsPopup.buttonHeight/2-floatingH*0.4, floatingW, floatingH*0.8);
	to.sourceBound = ti.destinationBound = new Rectangle(selectedItem.getTouch().globalX-floatingW/2, floatingY+buttonsPopup.buttonHeight/2-floatingH*0.5, floatingW, floatingH);
	buttonsPopup.transitionIn = ti;
	buttonsPopup.transitionOut = to;
	appModel.navigator.addPopup(buttonsPopup);
}		

private function buttonsPopup_selectHandler(event:Event):void
{
	event.currentTarget.removeEventListener(Event.SELECT, buttonsPopup_selectHandler);
	var buttonsPopup:SimpleListPopup = event.currentTarget as SimpleListPopup;
    var pdata:Object = buttonsPopup.data;
    pdata.ln = roomData.name;
    pdata.lp = roomData.pic;
	if( event.data == "lobby_profile" )
	{
        var profilePopup:ProfilePopup = new ProfilePopup( pdata );
		//profilePopup.addEventListener(Event.SELECT, profilePopup_eventsHandler);
		//profilePopup.addEventListener(Event.CANCEL, profilePopup_eventsHandler);
		//profilePopup.declineStyle = "danger";
		appModel.navigator.addPopup( profilePopup );
	}
	else if( event.data == "lobby_kick" || event.data == "lobby_promote" || event.data == "lobby_demote" )
	{
		var confirm:ConfirmPopup = new ConfirmPopup(loc("popup_sure_label"), loc("popup_yes_label"));
		confirm.acceptStyle = "danger";
		confirm.data = event.data;
		confirm.addEventListener(Event.SELECT, confirm_selectHandler);
		appModel.navigator.addPopup(confirm);
		function confirm_selectHandler(evet:Event):void
		{
			confirm.removeEventListener(Event.SELECT, confirm_selectHandler);
			var params:SFSObject = new SFSObject();
			params.putInt("id", buttonsPopup.data.id);
			params.putUtfString("name", buttonsPopup.data.name);
			if ( confirm.data == "lobby_promote" )
			{
				params.putShort("pr", MessageTypes.M13_COMMENT_PROMOTE);
				buttonsPopup.data.permission ++;
				memberCollection.updateItemAt(buttonsPopup.data.index);
			}
			else if ( confirm.data == "lobby_demote" )
			{
				params.putShort("pr", MessageTypes.M14_COMMENT_DEMOTE);
				buttonsPopup.data.permission --;
				memberCollection.updateItemAt(buttonsPopup.data.index);
			}
			else
			{
				params.putShort("pr", MessageTypes.M12_COMMENT_KICK);
				memberCollection.removeItemAt(buttonsPopup.data.index);
			}
			SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_MODERATION, params, SFSConnection.instance.lobbyManager.lobby);
			//SFSConnection.instance.lobbyManager.requestData(true, true);
		}
	}
	/*function profilePopup_eventsHandler ( event:Event ):void {
		event.currentTarget.removeEventListener(Event.SELECT, profilePopup_eventsHandler);
		event.currentTarget.removeEventListener(Event.CANCEL, profilePopup_eventsHandler);
		if( event.type == Event.SELECT )
			appModel.navigator.addLog(loc("navailable_messeage"));
		else if ( event.type == Event.CANCEL )
			removeFriend(buttonsPopup.data);
	}*/
	
}

private function joinleaveButton_selectHandler():void
{
	if( roomData.num >= roomData.max )
		appModel.navigator.addLog(loc("lobby_join_error_full"));
	else
		appModel.navigator.addLog(loc("lobby_join_error_min"));
}
private function joinleaveButton_triggeredHandler(event:Event):void
{
	if( itsMyRoom )
	{
		var confirm:ConfirmPopup = new ConfirmPopup(loc(memberCollection.length<=1?"lobby_leave_warning_message":"popup_sure_label"), loc("popup_yes_label"));
		confirm.acceptStyle = "danger";
		confirm.addEventListener(Event.SELECT, confirm_selectHandler);
		appModel.navigator.addPopup(confirm);
		function confirm_selectHandler(evet:Event):void
		{
			confirm.removeEventListener(Event.SELECT, confirm_selectHandler);
			SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_LEAVE);
			SFSConnection.instance.lastJoinedRoom = null;
			SFSConnection.instance.lobbyManager.lobby = null;
			updateLobbyLayout(false);
		}
		return;
	}
	
    if( SFSConnection.instance.lobbyManager.lobby != null && !player.admin )
	{
		appModel.navigator.addLog(loc("lobby_join_error_joined", [SFSConnection.instance.lobbyManager.lobby.name]));
		return;
	}

	var params:SFSObject = new SFSObject();
	params.putInt("id", roomData.id);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_JOIN, params);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_joinHandler);
	SFSConnection.instance.lobbyManager.lobby = null;
}

protected function sfs_joinHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.LOBBY_JOIN )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_joinHandler);
	var response:int = event.params.params.getInt("response")
    if( response == MessageTypes.RESPONSE_SUCCEED ) 
		updateLobbyLayout(true);
    else
        appModel.navigator.addLog(loc("lobby_join_request_" + response));
}

private function updateLobbyLayout(isJoin:Boolean):void
{
	dispatchEventWith(Event.UPDATE, false, isJoin);
	close();
}

protected function sfsConnection_roomJoinHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.LOBBY_JOIN && event.params.cmd != SFSCommands.LOBBY_LEAVE )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_roomJoinHandler);
}

private function findUser(id:int):Object
{
	for (var i:int=0; i<memberCollection.length; i++)
		if( memberCollection.getItemAt(i).id == id )
			return memberCollection.getItemAt(i);
	return null;
}

override protected function transitionOutStarted():void
{
	removeChildren(2);
	super.transitionOutStarted();
}
private function editButton_triggeredHandler(event:Event):void
{
	appModel.navigator.addPopup(new LobbyEditPopup(roomData));
	close();
}
private function closeButton_triggeredHandler(event:Event):void
{
	close();
}
}
}
