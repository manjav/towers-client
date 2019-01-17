package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.items.SettingsItemRenderer;
import com.gerantech.towercraft.controls.popups.IssueReportPopup;
import com.gerantech.towercraft.controls.popups.LinkDevicePopup;
import com.gerantech.towercraft.controls.popups.SelectNamePopup;
import com.gerantech.towercraft.controls.popups.SimpleListPopup;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.managers.BillingManager;
import com.gerantech.towercraft.managers.SoundManager;
import com.gerantech.towercraft.managers.oauth.OAuthManager;
import com.gerantech.towercraft.models.vo.SettingsData;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.PrefsTypes;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import starling.events.Event;

public class SettingsScreen extends ListScreen
{
override protected function initialize():void
{
	title = loc("settings_page");
	super.initialize();
	
	listLayout.gap = 0;	
	
	list.verticalScrollPolicy = player.inTutorial() ? ScrollPolicy.OFF : ScrollPolicy.AUTO;
	list.itemRendererFactory = function():IListItemRenderer { return new SettingsItemRenderer(); }
	list.dataProvider = getSettingsData();
	list.addEventListener(FeathersEventType.FOCUS_IN, list_focusInHandler);
	
	var versionLabel:RTLLabel = new RTLLabel(appModel.descriptor.versionNumber + " for " + appModel.descriptor.market, 1, "left", "ltr", false, null, 0.8);
	versionLabel.touchable = false;
	versionLabel.layoutData = new AnchorLayoutData(NaN, headerSize * 0.06,  headerSize, headerSize * 0.06);
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
		switch( settingData.value )
		{
			case SettingsData.BUG_REPORT :
				appModel.navigator.addPopup(new IssueReportPopup());
				break;
			case SettingsData.RATING :
				BillingManager.instance.rate();
				break;
			default:
				navigateTo(settingData.value as int);
				break;
		}
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
			header.label = title = loc("settings_page");
			footer.label = loc("close_button");
			list.dataProvider.updateAll();
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
	source.push( new SettingsData(PrefsTypes.SETTINGS_4_LOCALE, 		SettingsData.TYPE_BUTTON,           null));
	source.push( new SettingsData(PrefsTypes.SETTINGS_5_REMOVE_ADS, 	SettingsData.TYPE_TOGGLE, player.prefs.getAsBool(PrefsTypes.SETTINGS_5_REMOVE_ADS)));
	
	source.push( new SettingsData(SettingsData.RENAME,                  SettingsData.TYPE_BUTTON,           null));
	source.push( new SettingsData(PrefsTypes.AUTH_41_GOOGLE,            SettingsData.TYPE_TOGGLE, player.prefs.getAsBool(PrefsTypes.AUTH_41_GOOGLE)));
	source.push( new SettingsData(SettingsData.LINK_DEVICE, 			SettingsData.TYPE_BUTTON,			null));
	source.push( new SettingsData(SettingsData.LEGALS,	 				SettingsData.TYPE_BUTTON,			null));
	source.push( new SettingsData(SettingsData.TYPE_BUTTON, 			SettingsData.TYPE_LABEL_BUTTONS,	null));
	source.push( new SettingsData(SettingsData.TYPE_BUTTON, 			SettingsData.TYPE_ICON_BUTTONS,		null));
	return new ListCollection(source);
}
}
}