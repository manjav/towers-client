package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.controls.headers.TabsHeader;
import com.gerantech.towercraft.controls.items.RankItemRenderer;
import com.gerantech.towercraft.controls.items.lobby.LobbyItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.controls.Button;
import feathers.controls.ImageLoader;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;
import flash.geom.Rectangle;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class RankingPopup extends SimplePopup
{
private var rankType:String;
private var closeButton:Button;
private var titleDisplay:ShadowLabel;
private var playersCollection:ListCollection;
private var lobbiesCollection:ListCollection;
private var playersList:FastList;
private var lobbiesList:FastList;
private var list:FastList;

public function RankingPopup()
{
	transitionIn = new TransitionData();
	transitionOut = new TransitionData();
	transitionOut.transition = Transitions.EASE_IN;
	transitionOut.destinationAlpha = transitionIn.sourceAlpha = 0;
	transitionOut.destinationBound = transitionIn.sourceBound = new Rectangle(40, 130, stageWidth - 80, stageHeight - 260);
	transitionIn.destinationBound = transitionOut.sourceBound = new Rectangle(40, 150, stageWidth - 80, stageHeight - 300);

	sendCommand(SFSCommands.RANK);
}

private function sendCommand(rankType:String) : void 
{
	this.rankType = rankType;
	if( (rankType == SFSCommands.RANK && playersCollection != null) || (rankType == SFSCommands.LOBBY_DATA && lobbiesCollection != null) )
	{
		showElements();
		return;
	}
	
	var params:SFSObject = new SFSObject();
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
	if( rankType == SFSCommands.LOBBY_DATA )
	{
		params.putUtfString("name", "!@#$");
		params.putInt("mode", 1);
	}
	SFSConnection.instance.sendExtensionRequest(rankType, params);			
}

protected function sfsConnection_extensionResponseHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.RANK && event.params.cmd != SFSCommands.LOBBY_DATA )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
	if( event.params.cmd == SFSCommands.RANK )
		playersCollection = new ListCollection(SFSArray(event.params.params.getSFSArray("list")).toArray());
	else 
		lobbiesCollection = new ListCollection(SFSArray(event.params.params.getSFSArray("rooms")).toArray());
	
	showElements();
}


override protected function initialize():void
{
	super.initialize();
	skin.source = appModel.theme.popupBackgroundSkinTexture;
	skin.scale9Grid = MainTheme.POPUP_SCALE9_GRID;
	overlay.alpha = 0.8;
	
	titleDisplay = new ShadowLabel(loc("ranking_label", [""]), 1, 0, "center");
	titleDisplay.layoutData = new AnchorLayoutData(25, NaN, NaN, NaN, 0);
	titleDisplay.alpha = 0;
	
	closeButton = new Button();
	closeButton.styleName = MainTheme.STYLE_SMALL_DANGER_BUTTON;
	closeButton.defaultIcon = new Image(Assets.getTexture("theme/icon-cross", "gui"));
	closeButton.alpha = 0;
	closeButton.width = 88;
	closeButton.height = 74;
	closeButton.layoutData = new AnchorLayoutData(-10, -10);
	closeButton.addEventListener(Event.TRIGGERED, closeButton_triggeredHandler);
	addChild(closeButton);
}

override protected function transitionInCompleted():void
{
	super.transitionInCompleted();
	
	Starling.juggler.tween(titleDisplay, 0.2, {alpha:1});
	addChild(titleDisplay);
	showElements();
}

private function showElements():void
{
	if( transitionState < TransitionData.STATE_IN_COMPLETED || playersCollection == null )
		return;
	
	if( playersList == null )
	{
		var header:TabsHeader = new TabsHeader();
		header.height = 110;
		header.layoutData = new AnchorLayoutData(180, 80, NaN, 80);
		header.dataProvider = new ListCollection([ { label: loc("ranking_tab_0")}, { label: loc("ranking_tab_1")} ]);
		header.selectedIndex = 0;
		header.addEventListener(Event.CHANGE, header_changeHandler);
		addChild(header);
		
		var listBackground:ImageLoader = new ImageLoader();
		listBackground.source = appModel.theme.popupInsideBackgroundSkinTexture;
		listBackground.scale9Grid = MainTheme.POPUP_INSIDE_SCALE9_GRID;
		listBackground.layoutData = new AnchorLayoutData(280, 9, 26, 9);
		addChild(listBackground);
		
		var listLayout:VerticalLayout = new VerticalLayout();
		listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		listLayout.hasVariableItemDimensions = true;
		listLayout.useVirtualLayout = true;
		listLayout.gap = 10;
		
		playersList = new FastList();
		playersList.itemRendererFactory = function():IListItemRenderer { return new RankItemRenderer(); }
		playersList.dataProvider = playersCollection;
		playersList.layout = listLayout;
		playersList.layoutData = new AnchorLayoutData(295, 20, 37, 20);
		
		lobbiesList = new FastList();
		lobbiesList.itemRendererFactory = function():IListItemRenderer { return new LobbyItemRenderer(); }
		lobbiesList.layout = listLayout;
		lobbiesList.layoutData = new AnchorLayoutData(295, 20, 37, 20);
		
		Starling.juggler.tween(closeButton, 0.2, {delay:0.2, alpha:1});
	}

	if( list != null )
	{
		list.removeEventListener(Event.CHANGE, list_changeHandler);
		list.removeFromParent();
	}
	
	if( rankType == SFSCommands.RANK )
	{
		list = playersList;
		setTimeout(scrollToMe, 500);
	} 
	else
	{
		lobbiesList.dataProvider = lobbiesCollection;
		list = lobbiesList;
	}
	trace(rankType)
	addChild(list);
	list.alpha = 0;
	Starling.juggler.tween(list, 0.3, {delay:0.1, alpha:1});
	list.addEventListener(Event.CHANGE, list_changeHandler);
}

protected function header_changeHandler(event:Event) : void
{
	sendCommand(TabsHeader(event.currentTarget).selectedIndex == 0 ? SFSCommands.RANK : SFSCommands.LOBBY_DATA);
}

private function scrollToMe() : void
{
	var indexOfMe:int = findMe();
	if( indexOfMe > -1 )
		playersList.scrollToDisplayIndex(indexOfMe, 0.5);
}

protected function list_changeHandler(e:Event):void 
{
	list.removeEventListener(Event.CHANGE, list_changeHandler);
	if( rankType == SFSCommands.RANK )
		appModel.navigator.addPopup(new ProfilePopup({id:list.selectedItem.i, name:list.selectedItem.n}));
	else
		appModel.navigator.addPopup(new LobbyDetailsPopup({id:list.selectedItem.id, name:list.selectedItem.name, pic:list.selectedItem.pic, num:list.selectedItem.num, sum:list.selectedItem.sum, max:list.selectedItem.max}, true));

	list.selectedIndex = -1;
	list.addEventListener(Event.CHANGE, list_changeHandler);
}

private function findMe():int
{
	for (var i:int=0; i<playersCollection.length; i++)
		if( playersCollection.getItemAt(i).i == player.id)
			return i;
	return -1;
}


protected function closeButton_triggeredHandler():void
{
	closeButton.removeEventListener(Event.TRIGGERED, closeButton_triggeredHandler);
	close();
}

override public function dispose():void
{
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
	super.dispose();
}
}
}