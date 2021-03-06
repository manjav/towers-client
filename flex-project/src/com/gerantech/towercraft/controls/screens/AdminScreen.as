package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.popups.BroadcastMessagePopup;
import com.gerantech.towercraft.controls.popups.RestorePopup;

import feathers.controls.StackScreenNavigatorItem;
import feathers.data.ListCollection;

import starling.events.Event;

public class AdminScreen extends ListScreen
{
override protected function initialize():void
{
	title = "Admin Screen";
	super.initialize();
	
	listLayout.gap = 0;	
//	list.itemRendererFactory = function():IListItemRenderer { return new SettingsItemRenderer(); }
	list.dataProvider = new ListCollection(["Players", "Track Issues", "Push Message", "Restore", "Quests", "Battles"])
}

override protected function list_changeHandler(event:Event):void
{
	super.list_changeHandler(event);
	switch(list.selectedItem)
	{
		case "Players":
			appModel.navigator.pushScreen(Main.PLAYERS_SCREEN);
			break;
		case "Track Issues":
			appModel.navigator.pushScreen(Main.ISSUES_SCREEN);
			break;
		case "Restore":
			appModel.navigator.addPopup(new RestorePopup());
			break;
		case "Push Message":
			appModel.navigator.addPopup(new BroadcastMessagePopup());
			break;
		case "Quests":
		case "Battles":
			var item:StackScreenNavigatorItem = appModel.navigator.getScreen( Main.SPECTATE_SCREEN );
			item.properties.cmd = String(list.selectedItem).toLowerCase() ;
			appModel.navigator.pushScreen( Main.SPECTATE_SCREEN ) ;
	}
}
}
}