package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.extensions.NativeAbilities;
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
			listLayout.hasVariableItemDimensions = true;
			list.itemRendererFactory = function():IListItemRenderer { return new FriendItemRenderer(); }
			list.dataProvider = getFriendsData();
		}
		
		private function getFriendsData():ListCollection
		{
			var ret:ListCollection = new ListCollection();
			if( appModel.loadingManager.serverData.containsKey("friends") )
				ret.data = SFSArray(appModel.loadingManager.serverData.getSFSArray("friends")).toArray();
			ret.addItem( {name:"", point:-1} );
			return ret;
		}
		
		protected override function list_changeHandler(event:Event):void
		{
			var selectedItem:Object = list.selectedItem;
			if( selectedItem == null )
				return;
			
			if( selectedItem.name == "" && selectedItem.point == -1 )
			{
				var url:String = "http://towers.grantech.ir/invite?un="+player.nickName+"&ic="+appModel.loadingManager.serverData.getText("invitationCode").toUpperCase();
				NativeAbilities.instance.shareText(loc("invite_friend"), loc("invite_friend_message", [appModel.descriptor.name])+ "\n" + url);trace(url)
				return;
			}
		}
	}
}

