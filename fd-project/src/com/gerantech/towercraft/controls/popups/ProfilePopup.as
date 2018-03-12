package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.buttons.EmblemButton;
import com.gerantech.towercraft.controls.headers.BattleHeader;
import com.gerantech.towercraft.controls.items.BuildingItemRenderer;
import com.gerantech.towercraft.controls.items.ProfileFeatureItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;

import flash.geom.Rectangle;

import feathers.controls.ImageLoader;
import feathers.controls.List;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayoutData;
import feathers.layout.TiledRowsLayout;

import starling.core.Starling;
import starling.events.Event;

public class ProfilePopup extends SimplePopup 
{
private var user:Object;
private var playerData:ISFSObject;

public function ProfilePopup(user:Object, adminMode:Boolean=false)
{
	this.user = user;
	
	var params:SFSObject = new SFSObject();
	params.putInt("id", user.id);
	if( adminMode )
		params.putBool("am", true);
	if( user.ln == null )
		params.putInt("lp", 0);
    
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_responceHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.PROFILE, params);
}

override protected function initialize():void
{
	super.initialize();
	transitionOut.destinationBound = transitionIn.sourceBound = new Rectangle(stage.stageWidth*0.05, stage.stageHeight*0.25, stage.stageWidth*0.9, stage.stageHeight*0.5);
	transitionIn.destinationBound = transitionOut.sourceBound = new Rectangle(stage.stageWidth*0.05, stage.stageHeight*0.20, stage.stageWidth*0.9, stage.stageHeight*0.6);
	rejustLayoutByTransitionData();
}
protected override function transitionInCompleted():void
{
	super.transitionInCompleted();
	if( playerData != null )
		showProfile();
}
protected function sfsConnection_responceHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.PROFILE )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_responceHandler);
	playerData = event.params.params as SFSObject;

	if( playerData.containsKey("ln") )
		user.ln = playerData.getText("ln");
	else if( user.ln == null )
		user.ln = loc("lobby_no");
	
	if( playerData.containsKey("lp") )
		user.lp = playerData.getInt("lp");
	else if( user.lp == null )
		user.lp = 110;
	
	if( transitionState >= TransitionData.STATE_IN_FINISHED )
		showProfile();
}

private function showProfile():void
{
	var lobbyIconDisplay:EmblemButton = new EmblemButton(user.lp);
	lobbyIconDisplay.touchable = false;
	lobbyIconDisplay.width = padding * 5.3;
	lobbyIconDisplay.height = padding * 5.6;
	lobbyIconDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN);
	addChild(lobbyIconDisplay);
	
	var nameDisplay:ShadowLabel = new ShadowLabel(user.name, 1, 0, null, null, true, "center", 1);
	nameDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?NaN:padding*7, NaN, appModel.isLTR?padding*7:NaN);
	addChild(nameDisplay);
	
	var tagDisplay:RTLLabel = new RTLLabel("#"+playerData.getText("tag"), 0xAABBBB, null, "ltr", true, null, 0.8);
	tagDisplay.layoutData = new AnchorLayoutData(padding*2.6, appModel.isLTR?NaN:padding*7, NaN, appModel.isLTR?padding*7:NaN);
	addChild(tagDisplay);
	
	var lobbyNameDisplay:RTLLabel = new RTLLabel(user.ln, 0xAABBBB, null, "ltr", true, null, 0.8);
	lobbyNameDisplay.layoutData = new AnchorLayoutData(padding*5, appModel.isLTR?NaN:padding*7, NaN, appModel.isLTR?padding*7:NaN);
	addChild(lobbyNameDisplay);
	
	var closeButton:CustomButton = new CustomButton();
	closeButton.label = "";
	closeButton.addEventListener(Event.TRIGGERED, close_triggeredHandler);
	closeButton.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0);
	addChild(closeButton);
	closeButton.y = height - closeButton.height - padding*1.6;
	closeButton.alpha = 0;
	closeButton.height = 110 * appModel.scale;
	closeButton.label = loc("close_button");
	Starling.juggler.tween(closeButton, 0.2, {delay:0.5, alpha:1, y:height - closeButton.height - padding});

	// features
	var featureList:List = new List();
	featureList.horizontalScrollPolicy = featureList.verticalScrollPolicy = ScrollPolicy.OFF;
	featureList.itemRendererFactory = function ():IListItemRenderer { return new ProfileFeatureItemRenderer(); }
	featureList.dataProvider = new ListCollection(SFSArray(playerData.getSFSArray("features")).toArray());
	featureList.layoutData = new AnchorLayoutData(padding*7, padding*2, NaN, padding*2);
	addChild(featureList);
	
	// deck
	var deckHeader:BattleHeader = new BattleHeader(loc("deck_label"), true, 0.6);
	deckHeader.width = transitionIn.destinationBound.width * 0.8;
	deckHeader.layoutData = new AnchorLayoutData(padding*7 + featureList.dataProvider.length*padding*2, NaN, NaN, NaN, 0);
	addChild(deckHeader);
	
	var deckLayout:TiledRowsLayout = new TiledRowsLayout();
	deckLayout.gap = padding * 0.5;
	deckLayout.useSquareTiles = false;
	deckLayout.useVirtualLayout = false;
	deckLayout.requestedColumnCount = 4;
	deckLayout.typicalItemWidth = (width - deckLayout.gap*(deckLayout.requestedColumnCount-1) - padding*2) / deckLayout.requestedColumnCount;
	deckLayout.typicalItemHeight = deckLayout.typicalItemWidth * 1.3;
	
	var deckList:List = new List();
	deckList.layout = deckLayout;
	deckList.height = deckLayout.typicalItemHeight;
	deckList.verticalScrollPolicy = deckList.horizontalScrollPolicy = ScrollPolicy.OFF;
	deckList.layoutData = new AnchorLayoutData(padding*10.5 + featureList.dataProvider.length*padding*2, 0, NaN, 0);
	deckList.itemRendererFactory = function():IListItemRenderer { return new BuildingItemRenderer(true, false); }
	deckList.dataProvider = getDeckData();
	addChild(deckList);
	deckList.alpha = 0;
	Starling.juggler.tween(deckList, 0.2, {delay:0.3, alpha:1});
}

public function getDeckData():ListCollection
{
	var decks:ISFSArray = playerData.getSFSArray("decks");
	var ret:ListCollection = new ListCollection();
	for (var i:int = 0; i < decks.size(); i++) 
		ret.addItem({type:decks.getSFSObject(i).getInt("type"), level:decks.getSFSObject(i).getInt("level")});
	return ret;
}

private function close_triggeredHandler(event:Event):void
{
	close();
}
}
}