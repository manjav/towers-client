package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.items.LobbyFeatureItemRenderer;
import com.gerantech.towercraft.controls.items.LobbyMemberItemRenderer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
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
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;
import feathers.skins.ImageSkin;

import starling.events.Event;

public class LobbyDetailsPopup extends BasePopup
{
private var responseCode:int;
private var params:SFSObject;
private var padding:int;
private var roomData:Object;

private var itsMyRoom:Boolean;

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
	closable = false;
	transitionOut.destinationBound = transitionOut.sourceBound = transitionIn.destinationBound = transitionIn.sourceBound = new Rectangle(stage.stageWidth*0.05, stage.stageHeight*0.05, stage.stageWidth*0.9, stage.stageHeight*0.9);
	rejustLayoutByTransitionData();
	
	var skin:ImageSkin = new ImageSkin(appModel.theme.popupBackgroundSkinTexture);
	skin.scale9Grid = BaseMetalWorksMobileTheme.POPUP_SCALE9_GRID;
	backgroundSkin = skin;
	
	padding = 36 * appModel.scale;
	layout = new AnchorLayout();
	
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
	var sfsData:SFSObject = event.params.params;
	
	var messageDisplay:RTLLabel = new RTLLabel(sfsData.getText("bio"), 1, "justify", null, true, null, 0.6);
	messageDisplay.layoutData = new AnchorLayoutData(padding*3, appModel.isLTR?padding:padding*6, NaN, appModel.isLTR?padding*6:padding);
	addChild(messageDisplay);

	var features:Array = new Array();
	features.push( {key:"min", value:sfsData.getInt("min")} );
	features.push( {key:"sum", value:roomData.sum} );
	
	//trace(sfsData.getDump())
	var featureList:List = new List();
	featureList.layoutData = new AnchorLayoutData(padding*7, padding*2, NaN, padding*2);
	featureList.horizontalScrollPolicy = featureList.verticalScrollPolicy = ScrollPolicy.OFF;
	featureList.itemRendererFactory = function ():IListItemRenderer { return new LobbyFeatureItemRenderer(); }
	featureList.dataProvider = new ListCollection(features);
	addChild(featureList);
	
	var membersList:FastList = new FastList();
	//membersList.backgroundSkin = new Quad(1,1);//Assets.getTexture("slider-background", "skin");
	membersList.layoutData = new AnchorLayoutData(padding*16, padding, padding, padding);
	membersList.itemRendererFactory = function():IListItemRenderer { return new LobbyMemberItemRenderer(); }
	membersList.dataProvider = new ListCollection(SFSArray(sfsData.getSFSArray("all")).toArray());
	addChild(membersList);
	
	var room:Room = SFSConnection.instance.lastJoinedRoom;
	itsMyRoom = room != null && room.id == roomData.id;
	
	var joinleaveButton:CustomButton = new CustomButton();
	joinleaveButton.height = 96 * appModel.scale;
	joinleaveButton.isEnabled = roomData.max > roomData.num || room != null;
	joinleaveButton.layoutData = new AnchorLayoutData(padding*12, NaN, NaN, padding);
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

private function joinleaveButton_triggeredHandler(event:Event):void
{
	var params:SFSObject = new SFSObject();
	params.putInt("id", roomData.id);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_roomJoinHandler);
	SFSConnection.instance.sendExtensionRequest(itsMyRoom?SFSCommands.LOBBY_LEAVE:SFSCommands.LOBBY_JOIN, params);
}

protected function sfsConnection_roomJoinHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.LOBBY_JOIN && event.params.cmd != SFSCommands.LOBBY_LEAVE )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_roomJoinHandler);
}

private function closeButton_triggeredHandler(event:Event):void
{
	close();
}
}
}
