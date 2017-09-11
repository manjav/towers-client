package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.items.LobbyFeatureItemRenderer;
import com.gerantech.towercraft.controls.items.LobbyMemberItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.Room;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;

import flash.geom.Rectangle;

import feathers.controls.LayoutGroup;
import feathers.controls.List;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;

import starling.animation.Transitions;
import starling.events.Event;

public class LobbyDetailsPopup extends SimplePopup
{
private var responseCode:int;
private var params:SFSObject;
private var roomData:Object;

private var itsMyRoom:Boolean;

private var memberCollection:ListCollection;
private var buttonsPopup:SimpleListPopup;
private var roomServerData:*;

public function LobbyDetailsPopup(roomData:Object)
{
	this.roomData = roomData;
	
	var params:SFSObject = new SFSObject();
	params.putInt("id", roomData.id);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_roomGetHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_DATA, params);
}

override protected function initialize():void
{
	super.initialize();
	transitionOut.destinationBound = transitionIn.sourceBound = new Rectangle(stage.stageWidth*0.1, stage.stageHeight*0.1, stage.stageWidth*0.8, stage.stageHeight*0.8);
	transitionOut.sourceBound = transitionIn.destinationBound = new Rectangle(stage.stageWidth*0.05, stage.stageHeight*0.05, stage.stageWidth*0.9, stage.stageHeight*0.9);
	rejustLayoutByTransitionData();
	
	/*var buildingIcon:BuildingCard = new BuildingCard();
	buildingIcon.layoutData = new AnchorLayoutData(padding, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN);
	buildingIcon.width = padding * 4;
	buildingIcon.height = padding * 6;
	addChild(buildingIcon);*/

	var textLayout:VerticalLayout = new VerticalLayout();
	textLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	textLayout.gap = padding;
	
	var textsContainer:LayoutGroup = new LayoutGroup();
	textsContainer.layout = textLayout;
	addChild(textsContainer);
	
	var titleDisplay:RTLLabel = new RTLLabel(roomData.name);
	titleDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?padding:padding*6, NaN, appModel.isLTR?padding*6:padding);
	addChild(titleDisplay);
}

protected function sfsConnection_roomGetHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.LOBBY_DATA )
		return;
	
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_roomGetHandler);
	roomServerData = event.params.params as SFSObject;
	if( transitionState >= TransitionData.STATE_IN_FINISHED )
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
	var messageDisplay:RTLLabel = new RTLLabel(roomServerData.getText("bio"), 1, "justify", null, true, null, 0.6);
	messageDisplay.layoutData = new AnchorLayoutData(padding*3, appModel.isLTR?padding:padding*6, NaN, appModel.isLTR?padding*6:padding);
	addChild(messageDisplay);
	
	var features:Array = new Array();
	features.push( {key:"min", value:roomServerData.getInt("min")} );
	features.push( {key:"sum", value:Math.floor(roomData.sum/roomData.num)} );
	features.push( {key:"max", value:roomData.max} );
	
	//trace(sfsData.getDump())
	var featureList:List = new List();
	featureList.layoutData = new AnchorLayoutData(padding*7, padding*2, NaN, padding*2);
	featureList.horizontalScrollPolicy = featureList.verticalScrollPolicy = ScrollPolicy.OFF;
	featureList.itemRendererFactory = function ():IListItemRenderer { return new LobbyFeatureItemRenderer(); }
	featureList.dataProvider = new ListCollection(features);
	addChild(featureList);
	
	var ms:Array = SFSArray(roomServerData.getSFSArray("all")).toArray();
	ms.sortOn("po", Array.NUMERIC|Array.DESCENDING);
	memberCollection = new ListCollection(ms);
	
	var membersList:FastList = new FastList();
	//membersList.backgroundSkin = new Quad(1,1);//Assets.getTexture("slider-background", "skin");
	membersList.layoutData = new AnchorLayoutData(padding*16, padding, padding, padding);
	membersList.itemRendererFactory = function():IListItemRenderer { return new LobbyMemberItemRenderer(); }
	membersList.addEventListener(FeathersEventType.FOCUS_IN, membersList_focusInHandler);
	membersList.dataProvider = memberCollection;
	addChild(membersList);
	
	var room:Room = SFSConnection.instance.myLobby;
	itsMyRoom = room != null && room.id == roomData.id;
	
	var joinleaveButton:CustomButton = new CustomButton();
	joinleaveButton.height = 96 * appModel.scale;
	joinleaveButton.isEnabled = roomData.max > roomData.num || room != null;
	joinleaveButton.layoutData = new AnchorLayoutData(padding*12.5, NaN, NaN, padding);
	joinleaveButton.label = loc(itsMyRoom ? "lobby_leave_label" : "lobby_join_label");
	joinleaveButton.style = itsMyRoom ? "danger" : "neutral";
	joinleaveButton.addEventListener(Event.TRIGGERED, joinleaveButton_triggeredHandler);
	addChild(joinleaveButton);
	
	var closeButton:CustomButton = new CustomButton();
	closeButton.style = "danger";
	closeButton.label = "X";
	closeButton.layoutData = new AnchorLayoutData(padding/2, NaN, NaN, padding/2);
	closeButton.width = closeButton.height = 96 * appModel.scale;
	closeButton.addEventListener(Event.TRIGGERED, closeButton_triggeredHandler);
	addChild(closeButton);	
}

private function membersList_focusInHandler(event:Event):void
{
	var selectedItem:LobbyMemberItemRenderer = event.data as LobbyMemberItemRenderer;
	if( selectedItem == null )
		return;
	
	var selectedData:Object = selectedItem.data;

	var btns:Array = ["lobby_profile"];//trace(findUser(player.id).pr , selectedData.pr)
	if( selectedData.id != player.id )
	{
		var user:Object = findUser(player.id);
		if( user != null && user.pr != null && user.pr > selectedData.pr )
			btns.push( "lobby_kick" );
	}
	buttonsPopup = new SimpleListPopup();
	buttonsPopup.buttons = btns;
	buttonsPopup.data = selectedData;
	buttonsPopup.addEventListener(Event.SELECT, buttonsPopup_selectHandler);
	buttonsPopup.paddind = 24 * appModel.scale;
	buttonsPopup.buttonsWidth = 320 * appModel.scale;
	buttonsPopup.buttonHeight = 120 * appModel.scale;
	var floatingW:int = buttonsPopup.buttonsWidth + buttonsPopup.paddind * 2;
	var floatingH:int = buttonsPopup.buttonHeight * buttonsPopup.buttons.length + buttonsPopup.paddind * 2;
	var floatingY:int = selectedItem.getBounds(stage).y
	var ti:TransitionData = new TransitionData(0.2);
	ti.transition = Transitions.EASE_OUT_BACK;
	var to:TransitionData = new TransitionData(0.2);
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
	if( event.data == "lobby_profile" )
	{
		var profilePopup:ProfilePopup = new ProfilePopup(buttonsPopup.data.na, buttonsPopup.data.id);
		//profilePopup.addEventListener(Event.SELECT, profilePopup_eventsHandler);
		//profilePopup.addEventListener(Event.CANCEL, profilePopup_eventsHandler);
		//profilePopup.declineStyle = "danger";
		appModel.navigator.addPopup( profilePopup );
	}
	else if( event.data == "lobby_kick" )
	{
		var confirm:ConfirmPopup = new ConfirmPopup(loc("popup_sure_label"), loc("popup_yes_label"));
		confirm.acceptStyle = "danger";
		confirm.addEventListener(Event.SELECT, confirm_selectHandler);
		appModel.navigator.addPopup(confirm);
		function confirm_selectHandler(evet:Event):void
		{
			confirm.removeEventListener(Event.SELECT, confirm_selectHandler);
			var params:SFSObject = new SFSObject();
			params.putInt("id", buttonsPopup.data.id);
			params.putUtfString("name", buttonsPopup.data.na);
			SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_KICK, params, SFSConnection.instance.myLobby);
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
private function joinleaveButton_triggeredHandler(event:Event):void
{
	var params:SFSObject = new SFSObject();
	params.putInt("id", roomData.id);
	if( itsMyRoom )
	{
		var confirm:ConfirmPopup = new ConfirmPopup(loc(memberCollection.length<=1?"lobby_leave_warning_message":"popup_sure_label"), loc("popup_yes_label"));
		confirm.acceptStyle = "danger";
		confirm.addEventListener(Event.SELECT, confirm_selectHandler);
		appModel.navigator.addPopup(confirm);
		function confirm_selectHandler(evet:Event):void
		{
			confirm.removeEventListener(Event.SELECT, confirm_selectHandler);
			SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_LEAVE, params);
			SFSConnection.instance.lastJoinedRoom = null;
			updateLobbyLayout(false);
		}
		return;
	}
	//SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_roomJoinHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_JOIN, params);
	updateLobbyLayout(true);
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
private function closeButton_triggeredHandler(event:Event):void
{
	close();
}
}
}
