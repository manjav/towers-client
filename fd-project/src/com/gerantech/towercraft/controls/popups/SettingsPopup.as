package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.Game;
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.controls.items.SettingsItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.segments.InboxSegment;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.managers.BillingManager;
import com.gerantech.towercraft.managers.SoundManager;
import com.gerantech.towercraft.managers.oauth.OAuthManager;
import com.gerantech.towercraft.models.vo.SettingsData;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.PrefsTypes;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;
import flash.net.navigateToURL;
import starling.animation.Transitions;
import starling.events.Event;
import flash.geom.Rectangle;
import flash.net.URLRequest;

public class SettingsPopup extends SimpleHeaderPopup
{
private var list:FastList;
public function SettingsPopup()
{
	transitionIn = new TransitionData();
	transitionOut = new TransitionData();
	transitionOut.transition = Transitions.EASE_IN;
	transitionOut.destinationAlpha = transitionIn.sourceAlpha = 0;
	transitionOut.destinationBound = transitionIn.sourceBound = new Rectangle(60, 300, stageWidth - 120, stageHeight - 600);
	transitionIn.destinationBound = transitionOut.sourceBound = new Rectangle(60, 250, stageWidth - 120, stageHeight - 500);
	title = loc("settings_page");
}

override protected function showElements():void
{
	if( transitionState < TransitionData.STATE_IN_COMPLETED )
		return;
	
	super.showElements();
	
	list = new FastList();
	list.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	list.layoutData = new AnchorLayoutData(160, 0, 0, 0);
	list.itemRendererFactory = function():IListItemRenderer { return new SettingsItemRenderer(); }
	list.dataProvider = getSettingsData();
	list.addEventListener(FeathersEventType.FOCUS_IN, list_focusInHandler);
	addChild(list);
	
	var versionLabel:RTLLabel = new RTLLabel("v. " + appModel.descriptor.versionNumber + " for " + appModel.descriptor.market + ", User: " + (player.id * 2) , 0.6, null, "ltr", false, null, 0.6);
	versionLabel.layoutData = new AnchorLayoutData(NaN, 10,  10);
	versionLabel.touchable = false;
	addChild(versionLabel);
}

private function list_focusInHandler(event:Event):void
{
	var settingData:SettingsData = event.data as SettingsData;trace(event)
	if( settingData.type == SettingsData.TYPE_TOGGLE )
	{
		if( settingData.key == PrefsTypes.AUTH_41_GOOGLE )
		{
			if( player.prefs.getAsBool(PrefsTypes.AUTH_41_GOOGLE) )
			{
				OAuthManager.instance.signout();
				list.dataProvider.updateItemAt(settingData.index);
				return;
			}
			OAuthManager.instance.addEventListener(OAuthManager.AUTHENTICATE, socialManager_eventsHandler);
			OAuthManager.instance.signin();
			return;
		}
		
		UserData.instance.prefs.setBool(settingData.key, settingData.value);//setSetting(settingData.key, settingData.value as int );
		list.dataProvider.updateItemAt(settingData.index);
		if( settingData.key == PrefsTypes.SETTINGS_1_MUSIC )
		{
			if( player.prefs.getAsBool(PrefsTypes.SETTINGS_1_MUSIC) )
				appModel.sounds.play("main-theme", 1, 100, 0, SoundManager.SINGLE_FORCE_THIS);
			else
				appModel.sounds.stopAll();
		}
	}
	else if( settingData.type == SettingsData.TYPE_BUTTON )
	{
		if( settingData.key == SettingsData.LEGALS )
			navigateTo(settingData.key);
		else if( settingData.key == SettingsData.LINK_DEVICE )
			appModel.navigator.addPopup(new LinkDevicePopup());
		else if( settingData.key == SettingsData.RENAME )
			appModel.navigator.addPopup(new SelectNamePopup());
		else if( settingData.key == SettingsData.TYPE_LOCALES )
			showLocalePopup();
	}
	else
	{
		switch( int(settingData.value) )
		{
			case SettingsData.BUG_REPORT :
				InboxSegment.openThread();
				break;
			case SettingsData.RATING :
				BillingManager.instance.rate();
				break;
			default:
				navigateTo(settingData.value as int);
				break;
		}
		close();
	}
}

private function showLocalePopup():void 
{
	var buttonsPopup:SimpleListPopup = new SimpleListPopup();
	buttonsPopup.buttons = StrUtils.getLocalesByMarket(appModel.descriptor.market);
	buttonsPopup.buttonsWidth = 160;
	buttonsPopup.buttonHeight = 120;
	buttonsPopup.addEventListener(Event.SELECT, buttonsPopup_selectHandler);
	appModel.navigator.addPopup(buttonsPopup);
	function buttonsPopup_selectHandler(event:Event) : void
	{
		buttonsPopup.removeEventListener(Event.SELECT, buttonsPopup_selectHandler);
		if( UserData.instance.prefs.changeLocale(event.data as String) )
		{
			UserData.instance.prefs.setString(PrefsTypes.SETTINGS_4_LOCALE, event.data as String);
			titleDisplay.text = title = loc("settings_page");
			list.dataProvider.updateAll();
			appModel.navigator.rootScreenID = Game.DASHBOARD_SCREEN
		}
	}
}

protected function socialManager_eventsHandler(event:Event):void
{
	OAuthManager.instance.removeEventListener(OAuthManager.AUTHENTICATE, socialManager_eventsHandler);
	list.dataProvider.updateItemAt(3);
}

private function navigateTo(key:int):void
{
	navigateToURL(new URLRequest(loc("setting_value_" + key)));	
}

private function getSettingsData():ListCollection
{
	var source:Array = new Array();
	source.push( new SettingsData(PrefsTypes.SETTINGS_1_MUSIC,			SettingsData.TYPE_TOGGLE, player.prefs.getAsBool(PrefsTypes.SETTINGS_1_MUSIC)));
	source.push( new SettingsData(PrefsTypes.SETTINGS_2_SFX,			SettingsData.TYPE_TOGGLE, player.prefs.getAsBool(PrefsTypes.SETTINGS_2_SFX)));
	source.push( new SettingsData(PrefsTypes.SETTINGS_3_NOTIFICATION, 	SettingsData.TYPE_TOGGLE, player.prefs.getAsBool(PrefsTypes.SETTINGS_3_NOTIFICATION)));
	source.push( new SettingsData(PrefsTypes.SETTINGS_5_REMOVE_ADS, 	SettingsData.TYPE_TOGGLE, player.prefs.getAsBool(PrefsTypes.SETTINGS_5_REMOVE_ADS)));
	source.push( new SettingsData(PrefsTypes.AUTH_41_GOOGLE,            SettingsData.TYPE_TOGGLE, player.prefs.getAsBool(PrefsTypes.AUTH_41_GOOGLE)));
	
	source.push( new SettingsData(PrefsTypes.SETTINGS_4_LOCALE, 		SettingsData.TYPE_BUTTON,           null));
	source.push( new SettingsData(SettingsData.RENAME,                  SettingsData.TYPE_BUTTON,           null));
	source.push( new SettingsData(SettingsData.LINK_DEVICE, 			SettingsData.TYPE_BUTTON,			null));
	source.push( new SettingsData(SettingsData.LEGALS,	 				SettingsData.TYPE_BUTTON,			null));
	source.push( new SettingsData(SettingsData.TYPE_BUTTON, 			SettingsData.TYPE_LABEL_BUTTONS,	null));
	source.push( new SettingsData(SettingsData.TYPE_BUTTON, 			SettingsData.TYPE_ICON_BUTTONS,		null));
	return new ListCollection(source);
}
}
}