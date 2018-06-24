package com.gerantech.towercraft.controls.groups 
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.buttons.IconButton;
import com.gerantech.towercraft.controls.buttons.Indicator;
import com.gerantech.towercraft.controls.buttons.IndicatorXP;
import com.gerantech.towercraft.controls.buttons.NotifierButton;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.managers.InboxService;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.ResourceType;
import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.events.Event;

/**
* ...
* @author Mansour Djawadi
*/
public class Profile extends TowersLayout 
{
public function Profile() {	super(); }

override protected function initialize() : void
{
	super.initialize();
	layout = new AnchorLayout();
	
	var padding:int = height * 0.12;
	
	var skin:Image = new Image(Assets.getTexture("home/profile-sliced", "gui"));
	skin.scale9Grid = new Rectangle(140, 50, 54, 280);
	backgroundSkin = skin;
	
	var topLine:LayoutGroup = new LayoutGroup();
	topLine.height = height * 0.32;
	topLine.layoutData = new AnchorLayoutData(padding, padding * 3, NaN, padding * 3);
	topLine.layout = new HorizontalLayout();
	HorizontalLayout(topLine.layout).gap = padding * 0.5;
	HorizontalLayout(topLine.layout).verticalAlign = VerticalAlign.JUSTIFY;
	addChild(topLine);
	
	// player name in dept rect
	var scale9:Rectangle = new Rectangle(16, 16, 4, 4);
	var namePlace:LayoutGroup = new LayoutGroup();
	namePlace.layoutData = new HorizontalLayoutData(100);
	namePlace.layout = new AnchorLayout();
	namePlace.backgroundSkin = new Image(Assets.getTexture("home/profile-rect", "gui"));
	Image(namePlace.backgroundSkin).scale9Grid = scale9
	
	var nameDisplay:RTLLabel = new RTLLabel(player.nickName, 0xDCCAB4, "left", null, false, null, height * 0.22);
	nameDisplay.layoutData = new AnchorLayoutData(NaN, padding * 0.5, NaN, padding * 0.5, NaN, 0);
	namePlace.addChild(nameDisplay);
	
	// inbox button with notification badge
	var inboxButton:NotifierButton = new NotifierButton(Assets.getTexture("home/inbox", "gui"));
	inboxButton.name = "inboxButton";
	inboxButton.addEventListener(Event.TRIGGERED, buttons_eventsHandler);
	inboxButton.backgroundSkin = new Image(Assets.getTexture("theme/background-glass-skin", "gui"));
	Image(inboxButton.backgroundSkin).scale9Grid = scale9
	inboxButton.height = inboxButton.width = topLine.height;
	
	InboxService.instance.request();
	InboxService.instance.addEventListener(Event.UPDATE, inboxService_updateHandler);
	function inboxService_updateHandler():void
	{
		inboxButton.badgeLabel = InboxService.instance.numUnreads.toString();
	}
	
	// settings button
	var settingsButton:IconButton = new IconButton(Assets.getTexture("home/settings", "gui"));
	settingsButton.name = "settingsButton";
	settingsButton.backgroundSkin = new Image(Assets.getTexture("theme/background-glass-skin", "gui"));
	settingsButton.addEventListener(Event.TRIGGERED, buttons_eventsHandler);
	Image(settingsButton.backgroundSkin).scale9Grid = scale9
	settingsButton.height = settingsButton.width = topLine.height;
	
	var topLineElements:Array = [namePlace, inboxButton, settingsButton];
	if( appModel.isLTR )
		topLineElements.reverse();
	for each ( var e:DisplayObject in topLineElements )
		topLine.addChild(e);
	
	
	// bottom line
	var botLine:LayoutGroup = new LayoutGroup();
	botLine.height = height * 0.25;
	botLine.layout = new HorizontalLayout();
	botLine.layoutData = new AnchorLayoutData(NaN, padding * 3.2, padding * 2.2, padding * 3.0);
	HorizontalLayout(botLine.layout).verticalAlign = VerticalAlign.MIDDLE;
	HorizontalLayout(botLine.layout).gap = padding;
	HorizontalLayout(botLine.layout).firstGap = padding * 0.5;
	addChild(botLine);
	
	var clanIconDisplay:ImageLoader = new ImageLoader();
	clanIconDisplay.source = Assets.getTexture("emblems/emblem-" + StrUtils.getZeroNum(SFSConnection.instance.lobbyManager.emblem + ""), "gui");
	botLine.addChild(clanIconDisplay);
	
	var lobbyName:String = SFSConnection.instance.lobbyManager.lobby != null ? SFSConnection.instance.lobbyManager.lobby.name : loc("lobby_no");
	var clanNameDisplay:RTLLabel = new RTLLabel(lobbyName, 0xDCCAB4, "left", null, false, null, 0.8);
	clanNameDisplay.layoutData = new HorizontalLayoutData(100);
	botLine.addChild(clanNameDisplay);
	
	var indicators:Dictionary = appModel.navigator.toolbar.indicators;
	indicators[ResourceType.XP] = new IndicatorXP("ltr", ResourceType.XP, true, false);
	indicators[ResourceType.XP].name = "xpIndicator";
	indicators[ResourceType.XP].setData(8000, player.get_xp(), 12000);
	indicators[ResourceType.XP].width = padding * 6;
	indicators[ResourceType.XP].addEventListener(Event.SELECT, buttons_eventsHandler);
	indicators[ResourceType.XP].layoutData = new AnchorLayoutData(NaN, NaN, NaN, padding);
	botLine.addChild(indicators[ResourceType.XP]);
	
	indicators[ResourceType.POINT] = new Indicator("ltr", ResourceType.POINT, false, false);
	indicators[ResourceType.POINT].name = "pointIndicator";
	indicators[ResourceType.POINT].width = padding * 5;
	indicators[ResourceType.POINT].setData(0, player.get_point(), NaN);
	indicators[ResourceType.POINT].addEventListener(Event.SELECT, buttons_eventsHandler);
	indicators[ResourceType.POINT].layoutData = new AnchorLayoutData(NaN, NaN, NaN, padding);
	botLine.addChild(indicators[ResourceType.POINT]);
}

private function buttons_eventsHandler(event:Event):void 
{
	switch(DisplayObject(event.currentTarget).name)
	{
	case "inboxButton":		appModel.navigator.pushScreen(Main.INBOX_SCREEN);		break;
	case "settingsButton":	appModel.navigator.pushScreen(Main.SETTINGS_SCREEN);	break;
	case "pointIndicator":	break;
	case "xpIndicator":		break;
	}
}
}
}