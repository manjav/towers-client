package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.controls.items.SettingsItemRenderer;
	import com.gerantech.towercraft.controls.popups.BugReportPopup;
	import com.gerantech.towercraft.controls.popups.LinkDevicePopup;
	import com.gerantech.towercraft.managers.BillingManager;
	import com.gerantech.towercraft.models.vo.SettingsData;
	import com.gerantech.towercraft.models.vo.UserData;
	import com.gt.towers.constants.PrefsTypes;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.resources.ResourceManager;
	
	import feathers.controls.ScrollPolicy;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	
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
		}
		
		private function list_focusInHandler(event:Event):void
		{
			var settingData:SettingsData = event.data as SettingsData;trace(event)
			if( settingData.type == SettingsData.TYPE_TOGGLE )
			{
				UserData.instance.prefs.setBool(settingData.key, settingData.value);//setSetting(settingData.key, settingData.value as int );
				list.dataProvider.updateItemAt(settingData.index);
				if( settingData.key == PrefsTypes.SETTINGS_1_MUSIC )
				{
					if( player.prefs.getAsBool(PrefsTypes.SETTINGS_1_MUSIC) )
						appModel.sounds.playSoundUnique("main-theme", 1, 100);
					else
						appModel.sounds.stopSound("main-theme");
				}
			}
			else if( settingData.type == SettingsData.TYPE_BUTTON )
			{
				if( settingData.key == SettingsData.LEGALS )
					navigateTo(settingData.key);
				else if( settingData.key == SettingsData.LINK_DEVICE )
					appModel.navigator.addPopup(new LinkDevicePopup());
			}
			else
			{
				switch(settingData.value)
				{
					case SettingsData.BUG_REPORT :
						var reportPopup:BugReportPopup = new BugReportPopup();
						reportPopup.addEventListener(Event.COMPLETE, reportPopup_completeHandler);
						appModel.navigator.addPopup(reportPopup);
						function reportPopup_completeHandler(event:Event):void {
							var reportPopup:BugReportPopup = new BugReportPopup();
							appModel.navigator.addLog(ResourceManager.getInstance().getString("loc", "popup_bugreport_fine"));
						}
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
		
		private function navigateTo(key:int):void
		{
			navigateToURL(new URLRequest(loc("setting_value_"+key)));		
		}
		
		private function getSettingsData():ListCollection
		{
			var source:Array = new Array();
			source.push( new SettingsData(PrefsTypes.SETTINGS_1_MUSIC,			SettingsData.TYPE_TOGGLE, player.prefs.getAsBool(PrefsTypes.SETTINGS_1_MUSIC)));//UserData.instance.get.getSetting(SettingsData.MUSIC)));
			source.push( new SettingsData(PrefsTypes.SETTINGS_2_SFX,			SettingsData.TYPE_TOGGLE, player.prefs.getAsBool(PrefsTypes.SETTINGS_2_SFX)));//UserData.instance.getSetting(SettingsData.SFX)));
			source.push( new SettingsData(PrefsTypes.SETTINGS_3_NOTIFICATION, 	SettingsData.TYPE_TOGGLE, player.prefs.getAsBool(PrefsTypes.SETTINGS_3_NOTIFICATION)));//UserData.instance.getSetting(SettingsData.NOTIFICATION)));
			source.push( new SettingsData(SettingsData.LINK_DEVICE, 			SettingsData.TYPE_BUTTON,			null));
			source.push( new SettingsData(SettingsData.LEGALS,	 				SettingsData.TYPE_BUTTON,			null));
			source.push( new SettingsData(SettingsData.TYPE_BUTTON, 			SettingsData.TYPE_LABEL_BUTTONS,	null));
			source.push( new SettingsData(SettingsData.TYPE_BUTTON, 			SettingsData.TYPE_ICON_BUTTONS,		null));
			return new ListCollection(source);
		}
	}
}