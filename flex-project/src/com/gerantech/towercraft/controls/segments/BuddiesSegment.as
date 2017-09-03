package com.gerantech.towercraft.controls.segments
{
import com.gerantech.extensions.NativeAbilities;
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.controls.items.BuddyItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.overlays.WaitingOverlay;
import com.gerantech.towercraft.controls.popups.ConfirmPopup;
import com.gerantech.towercraft.controls.popups.ProfilePopup;
import com.gerantech.towercraft.controls.popups.SimpleListPopup;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gt.towers.battle.fieldes.FieldData;
import com.smartfoxserver.v2.core.SFSBuddyEvent;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.Buddy;
import com.smartfoxserver.v2.entities.SFSBuddy;
import com.smartfoxserver.v2.entities.data.SFSObject;
import com.smartfoxserver.v2.entities.variables.SFSBuddyVariable;

import flash.geom.Rectangle;
import flash.utils.setTimeout;

import feathers.controls.StackScreenNavigatorItem;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;

import starling.animation.Transitions;
import starling.events.Event;

public class BuddiesSegment extends Segment
{
private var list:FastList;
private var buttonsPopup:SimpleListPopup;
private var buddyCollection:ListCollection;
public function BuddiesSegment()
{
	SFSConnection.instance.buddyManager.setInited(true);
	SFSConnection.instance.addEventListener(SFSBuddyEvent.BUDDY_VARIABLES_UPDATE,		sfs_buddyVariablesUpdateHandler); 
	SFSConnection.instance.addEventListener(SFSBuddyEvent.BUDDY_ONLINE_STATE_UPDATE,	sfs_buddyVariablesUpdateHandler); 
	SFSConnection.instance.addEventListener(SFSBuddyEvent.BUDDY_ADD,					sfs_buddyChangeHandler); 
	SFSConnection.instance.addEventListener(SFSBuddyEvent.BUDDY_REMOVE,					sfs_buddyChangeHandler); 
}

override public function updateData():void
{
	super.updateData();
}
override public function init():void
{
	super.init();
	layout = new AnchorLayout();
	
	var listLayout:VerticalLayout = new VerticalLayout();
	listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	listLayout.padding = 24 * appModel.scale;	
	listLayout.paddingTop = listLayout.padding;
	listLayout.useVirtualLayout = true;
	listLayout.typicalItemHeight = 164 * appModel.scale;;
	listLayout.gap = 12 * appModel.scale;	
	
	list = new FastList();
	list.layout = listLayout;
	list.layoutData = new AnchorLayoutData(0,0,0,0);
	setTimeout(list.addEventListener, 100, Event.SCROLL, list_scrollHandler);
	addChild(list);
	
	buddyCollection = new ListCollection(SFSConnection.instance.buddyManager.buddyList);
	var me:SFSBuddy = new SFSBuddy(0, player.id+"");
	me.setVariable( new SFSBuddyVariable("$__BV_NICKNAME__", player.nickName));
	me.setVariable( new SFSBuddyVariable("$__BV_STATE__", "Available"));
	me.setVariable( new SFSBuddyVariable("$point", player.get_point()));
	//me.setVariable( new SFSBuddyVariable("$room", SFSConnection.instance.myLobby.name));
	buddyCollection.addItem( me );
	buddyCollection.addItem( 0 );
	listLayout.hasVariableItemDimensions = true;
	list.addEventListener(FeathersEventType.FOCUS_IN, list_focusInHandler);
	list.itemRendererFactory = function():IListItemRenderer { return new BuddyItemRenderer(); }
	list.dataProvider = buddyCollection;
}

protected function sfs_buddyVariablesUpdateHandler(event:SFSBuddyEvent):void
{
	if( buddyCollection == null || buddyCollection.length == 0 )
		return;
	
	var buddy:Buddy = event.params.buddy as Buddy;
	var buddyIndex:int = buddyCollection.getItemIndex(buddy);
	buddyCollection.data[buddyIndex] = buddy;
	buddyCollection.updateItemAt(buddyIndex);
}
protected function sfs_buddyChangeHandler(event:SFSBuddyEvent):void
{
	if( buddyCollection == null || buddyCollection.length == 0 )
		return;
	
	var buddy:Buddy = event.params.buddy as Buddy;
	if( event.type == SFSBuddyEvent.BUDDY_ADD )
		buddyCollection.addItemAt(buddy, buddyCollection.length-2);
	else if( event.type == SFSBuddyEvent.BUDDY_REMOVE )
		buddyCollection.removeItemAt(buddyCollection.getItemIndex(buddy))
}


protected function list_scrollHandler(event:Event):void
{
	super.list_scrollHandler(event);
	if( buttonsPopup != null && buttonsPopup.parent == this )
		buttonsPopup.close();
}
protected function list_focusInHandler(event:Event):void
{
	var selectedItem:BuddyItemRenderer = event.data as BuddyItemRenderer;
	if( selectedItem == null )
		return;
	
	var buddy:Buddy = selectedItem.data as Buddy;
	if( buddy == null )
	{
		var url:String = "http://towers.grantech.ir/invite?un="+player.nickName+"&ic="+appModel.loadingManager.serverData.getText("invitationCode").toLowerCase();
		NativeAbilities.instance.shareText(loc("invite_friend"), loc("invite_friend_message", [appModel.descriptor.name])+ "\n" + url);trace(url)
		return;
	}
	
	if( buddy.nickName == player.nickName )
		buttonsPopup = new SimpleListPopup("buddy_profile");
	else
		buttonsPopup = new SimpleListPopup("buddy_profile","buddy_remove",buddy.state=="Occupied"?"buddy_spectate$":"buddy_battle");
	buttonsPopup.data = buddy;
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
	var buddy:Buddy = buttonsPopup.data as Buddy;
	switch( event.data )
	{
		case "buddy_profile":
			appModel.navigator.addPopup( new ProfilePopup(buddy.nickName, int(buddy.name)) );
			break;
		case "buddy_battle":
			appModel.navigator.addLog(loc("unavailable_messeage"));
			break;
		case "buddy_remove":
			removeFriend(buddy);
			break;
		case "buddy_spectate$":
			spectate(buddy);
			break;
	}
}

private function spectate(buddy:Buddy):void
{
	if( !buddy.containsVariable("br") )
		return;
	
	var item:StackScreenNavigatorItem = appModel.navigator.getScreen( Main.BATTLE_SCREEN );
	item.properties.requestField = new FieldData(100000 + buddy.getVariable("br").getIntValue(), "quest_100000") ;
	item.properties.spectatedUser = buddy.name;
	item.properties.waitingOverlay = new WaitingOverlay() ;
	appModel.navigator.pushScreen( Main.BATTLE_SCREEN ) ;
	appModel.navigator.addOverlay(item.properties.waitingOverlay);
}

private function removeFriend( buddy:Buddy ):void
{
	var confirm:ConfirmPopup = new ConfirmPopup(loc("buddy_remove_confirm"), loc("popup_yes_label"));
	confirm.addEventListener(Event.SELECT, confirm_selectHandler);
	confirm.acceptStyle = "danger";
	appModel.navigator.addPopup(confirm);
	function confirm_selectHandler ( event:Event ):void {
		confirm.removeEventListener(Event.SELECT, confirm_selectHandler);
		var params:SFSObject = new SFSObject();
		params.putText("buddyId", buddy.name);
		SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_responseHandler);
		SFSConnection.instance.sendExtensionRequest(SFSCommands.BUDDY_REMOVE, params);
	}
}

protected function sfsConnection_responseHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.BUDDY_REMOVE )
		return;
	
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_responseHandler);
	appModel.navigator.addLog(loc("buddy_remove_message"));
}

override public function dispose():void
{
	SFSConnection.instance.removeEventListener(SFSBuddyEvent.BUDDY_VARIABLES_UPDATE,	sfs_buddyVariablesUpdateHandler); 
	SFSConnection.instance.removeEventListener(SFSBuddyEvent.BUDDY_ONLINE_STATE_UPDATE,	sfs_buddyVariablesUpdateHandler); 
	SFSConnection.instance.removeEventListener(SFSBuddyEvent.BUDDY_ADD,					sfs_buddyChangeHandler); 
	SFSConnection.instance.removeEventListener(SFSBuddyEvent.BUDDY_REMOVE,				sfs_buddyChangeHandler); 
	super.dispose();
}


}
}