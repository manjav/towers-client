package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.overlays.WaitingOverlay;
import com.gerantech.towercraft.controls.popups.RestorePopup;

import feathers.controls.ScrollPolicy;
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
	list.dataProvider = new ListCollection(["Restore", "Quests", "Battles"])
}

override protected function list_changeHandler(event:Event):void
{
	super.list_changeHandler(event);
	switch(list.selectedItem)
	{
		case "Restore":
			appModel.navigator.addPopup(new RestorePopup());
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