package com.gerantech.towercraft.controls.groups 
{
import com.gerantech.towercraft.Game;
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.buttons.IconButton;
import com.gerantech.towercraft.controls.buttons.Indicator;
import com.gerantech.towercraft.controls.buttons.IndicatorXP;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.popups.ProfilePopup;
import com.gerantech.towercraft.controls.popups.SettingsPopup;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.constants.ResourceType;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
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
	height = 128;
	super.initialize();
	layout = new AnchorLayout();
	touchable = player.getTutorStep() >= PrefsTypes.T_047_WIN;
    var scale9:Rectangle = new Rectangle(16, 16, 4, 4);
	var padding:int = 16;
	
	var skin:Image = new Image(Assets.getTexture("background-round-skin"));
	skin.scale9Grid = MainTheme.ROUND_RECT_SCALE9_GRID;
	skin.color = 0;
	skin.alpha = 0.3;
	backgroundSkin = skin;

	var nameDisplay:ShadowLabel = new ShadowLabel(player.nickName, 1, 0, "left", null, false, null, 0.7);
	nameDisplay.layoutData = new AnchorLayoutData(10, NaN, NaN, padding);
	addEventListener("nameUpdate", function ():void { nameDisplay.text = player.nickName; });
	addChild(nameDisplay);
	
	var lobbyIconDisplay:ImageLoader = new ImageLoader();
	lobbyIconDisplay.width = lobbyIconDisplay.height = 50;
	lobbyIconDisplay.source = Assets.getTexture("emblems/emblem-" + StrUtils.getZeroNum(SFSConnection.instance.lobbyManager.emblem + ""), "gui");
	lobbyIconDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding, padding);
	addChild(lobbyIconDisplay);
	
	var lobbyName:String = SFSConnection.instance.lobbyManager.lobby != null ? SFSConnection.instance.lobbyManager.lobby.name : loc("lobby_no");
	var lobbyNameDisplay:RTLLabel = new RTLLabel(lobbyName, 0xDCCAB4, "left", null, false, null, 0.6);
	lobbyNameDisplay.layoutData = new AnchorLayoutData(NaN, NaN, 10, padding * 2 + lobbyIconDisplay.width);
	addChild(lobbyNameDisplay);
	
	var hitObject:SimpleLayoutButton = new SimpleLayoutButton();
	hitObject.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	hitObject.addEventListener(Event.TRIGGERED, function(event:Event):void { appModel.navigator.addPopup( new ProfilePopup({name:player.nickName, id:player.id}) ); });
	addChild(hitObject);

	var indicatorXP:IndicatorXP = new IndicatorXP("ltr");
	indicatorXP.name = "xpIndicator";
	indicatorXP.width = 200;
	indicatorXP.layoutData = new AnchorLayoutData(NaN, 380, NaN, NaN, NaN, 0);
	indicatorXP.addEventListener(Event.SELECT, buttons_eventsHandler);
	addChild(indicatorXP);
	
	var indicatorPoint:Indicator = new Indicator("ltr", ResourceType.R2_POINT, false, false);
	indicatorPoint.name = "pointIndicator";
	indicatorPoint.width = 200;
	indicatorPoint.layoutData = new AnchorLayoutData(NaN, 128, NaN, NaN, NaN, 0);
	indicatorPoint.addEventListener(Event.SELECT, buttons_eventsHandler);
	addChild(indicatorPoint);
	
	// settings button
	var settingsButton:IconButton = new IconButton(Assets.getTexture("home/settings"));
	settingsButton.name = "settingsButton";
	settingsButton.backgroundSkin = new Image(Assets.getTexture("theme/background-glass-skin"));
	settingsButton.addEventListener(Event.TRIGGERED, buttons_eventsHandler);
	Image(settingsButton.backgroundSkin).scale9Grid = scale9;
	settingsButton.width = settingsButton.height = height - padding * 2;
	settingsButton.layoutData = new AnchorLayoutData(padding, padding, padding);
	addChild(settingsButton);
}

private function buttons_eventsHandler(event:Event) : void 
{
	switch(DisplayObject(event.currentTarget).name)
	{
	case "inboxButton":		appModel.navigator.pushScreen(Game.INBOX_SCREEN);	break;
	case "settingsButton":	appModel.navigator.addPopup(new SettingsPopup());	break;
	}
}
}
}