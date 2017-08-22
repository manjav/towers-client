package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.extensions.NativeAbilities;
	import com.gerantech.towercraft.controls.items.FriendItemRenderer;
	import com.gerantech.towercraft.controls.overlays.TransitionData;
	import com.gerantech.towercraft.controls.popups.ConfirmPopup;
	import com.gerantech.towercraft.controls.popups.ProfilePopup;
	import com.gerantech.towercraft.controls.popups.SimpleListPopup;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.geom.Rectangle;
	import flash.net.navigateToURL;
	
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	
	import starling.animation.Transitions;
	import starling.events.Event;
	
	public class VillageScreen extends ListScreen
	{

		private var buttonsPopup:SimpleListPopup;

		override protected function initialize():void
		{
			title = loc("map-dragon-cross");
			super.initialize();
			listLayout.hasVariableItemDimensions = true;
			list.addEventListener(FeathersEventType.FOCUS_IN, list_focusInHandler);
			list.itemRendererFactory = function():IListItemRenderer { return new FriendItemRenderer(); }
			list.dataProvider = getFriendsData();
		}

		private function getFriendsData():ListCollection
		{
			var ret:ListCollection = new ListCollection();
			if( appModel.loadingManager.serverData.containsKey("friends") )
				ret.data = SFSArray(appModel.loadingManager.serverData.getSFSArray("friends")).toArray();
			ret.addItem( {name:"", count:-1} );
			return ret;
		}
		
		protected function list_focusInHandler(event:Event):void
		{
			var selectedItem:FriendItemRenderer = event.data as FriendItemRenderer;
			if( selectedItem == null )
				return;
			
			var selectedData:Object = selectedItem.data;
			if( selectedData.id == player.id )
				return;
			
			if( selectedData.name == "" && selectedData.count == -1 )
			{
				var url:String = "http://towers.grantech.ir/invite?un="+player.nickName+"&ic="+appModel.loadingManager.serverData.getText("invitationCode").toLowerCase();
				NativeAbilities.instance.shareText(loc("invite_friend"), loc("invite_friend_message", [appModel.descriptor.name])+ "\n" + url);trace(url)
				return;
			}
			
			buttonsPopup = new SimpleListPopup("friendship_profile", "friendship_remove_friend", "friendship_friendly_battle");
			buttonsPopup.data = selectedData;
			buttonsPopup.addEventListener(Event.SELECT, buttonsPopup_selectHandler);
			buttonsPopup.addEventListener(Event.CLOSE, buttonsPopup_selectHandler);
			buttonsPopup.paddind = 24 * appModel.scale;
			buttonsPopup.buttonsWidth = 320 * appModel.scale;
			buttonsPopup.buttonHeight = 120 * appModel.scale;
			var floatingW:int = buttonsPopup.buttonsWidth + buttonsPopup.paddind * 2;
			var floatingH:int = buttonsPopup.buttonHeight * buttonsPopup.buttons.length + buttonsPopup.paddind * 2;
			
			var ti:TransitionData = new TransitionData(0.1);
			ti.transition = Transitions.EASE_IN_OUT_BACK;
			ti.sourceBound = new Rectangle(stage.stageWidth/3, selectedItem.getBounds(stage).y-floatingH/8, floatingW/2, floatingH/2);
			ti.destinationBound = new Rectangle(stage.stageWidth/3-floatingW/2, selectedItem.getBounds(stage).y-floatingH/4, floatingW, floatingH);
			
			var to:TransitionData = new TransitionData(0.1);
			to.sourceAlpha = 1;
			to.destinationAlpha = 0;
			to.sourceBound = ti.destinationBound;
			to.destinationBound = ti.destinationBound;

			buttonsPopup.transitionIn = ti;
			buttonsPopup.transitionOut = to;
			addChild(buttonsPopup);
		}		
		
		private function buttonsPopup_selectHandler(event:Event):void
		{
			event.currentTarget.removeEventListener(Event.SELECT, buttonsPopup_selectHandler);
			event.currentTarget.removeEventListener(Event.CLOSE, buttonsPopup_selectHandler);
			
			if( event.type == Event.CLOSE )
				return;

			var buttonsPopup:SimpleListPopup = event.currentTarget as SimpleListPopup;
			switch( event.data )
			{
				case "friendship_profile":
					var profilePopup:ProfilePopup = new ProfilePopup(buttonsPopup.data.name, buttonsPopup.data.id);
					profilePopup.addEventListener(Event.SELECT, profilePopup_eventsHandler);
					profilePopup.addEventListener(Event.CANCEL, profilePopup_eventsHandler);
					profilePopup.declineStyle = "danger";
					appModel.navigator.addPopup( profilePopup );
					break;
				case "friendship_friendly_battle":
					appModel.navigator.addLog(loc("navailable_messeage"));
					break;
				case "friendship_remove_friend":
					removeFriend(buttonsPopup.data);
					break;
			}
			function profilePopup_eventsHandler ( event:Event ):void {
				event.currentTarget.removeEventListener(Event.SELECT, profilePopup_eventsHandler);
				event.currentTarget.removeEventListener(Event.CANCEL, profilePopup_eventsHandler);
				if( event.type == Event.SELECT )
					appModel.navigator.addLog(loc("navailable_messeage"));
				else if ( event.type == Event.CANCEL )
					removeFriend(buttonsPopup.data);
			}

		}
		
		private function removeFriend(playerData:Object):void
		{
			var confirm:ConfirmPopup = new ConfirmPopup(loc("friendship_remove_confirm"), loc("popup_yes_label"));
			confirm.addEventListener(Event.SELECT, confirm_selectHandler);
			confirm.acceptStyle = "danger";
			appModel.navigator.addPopup(confirm);
			function confirm_selectHandler ( event:Event ):void {
				confirm.removeEventListener(Event.SELECT, confirm_selectHandler);
				var params:SFSObject = new SFSObject();
				params.putInt("inviteeId", player.id);
				params.putInt("inviterId", playerData.id);
				SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_responseHandler);
				SFSConnection.instance.sendExtensionRequest(SFSCommands.REMOVE_FRIEND, params);
			}
		}
		
		protected function sfsConnection_responseHandler(event:SFSEvent):void
		{
			if( event.params.cmd != SFSCommands.REMOVE_FRIEND )
				return;
			
			SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_responseHandler);
			appModel.navigator.addLog(loc("friendship_remove_message"));
		}
		
		override protected function list_scrollHandler(event:Event):void
		{
			super.list_scrollHandler(event);
			if( buttonsPopup != null && buttonsPopup.parent == this )
				buttonsPopup.close();
		}
	}
}