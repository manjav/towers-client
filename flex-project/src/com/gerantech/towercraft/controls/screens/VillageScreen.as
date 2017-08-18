package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.controls.items.FriendItemRenderer;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	
	import starling.events.Event;
	
	public class VillageScreen extends ListScreen
	{
		override protected function initialize():void
		{
			title = loc("map-dragon-cross");
			super.initialize();
			list.itemRendererFactory = function():IListItemRenderer { return new FriendItemRenderer(); }
			list.dataProvider = new ListCollection(SFSArray(appModel.loadingManager.serverData.getSFSArray("friends")).toArray());
		}
		
		protected override function list_changeHandler(event:Event):void
		{
		}
	}
}

