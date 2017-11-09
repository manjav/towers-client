package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.items.SegmentsItemRenderer;
import com.gerantech.towercraft.controls.items.SocialTabItemRenderer;
import com.gerantech.towercraft.managers.net.sfs.LobbyManager;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.vo.TabItemData;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
import com.gt.towers.constants.SegmentType;

import flash.utils.setTimeout;

import feathers.controls.AutoSizeMode;
import feathers.controls.LayoutGroup;
import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import starling.display.Image;
import starling.events.Event;

public class SocialScreen extends BaseCustomScreen
{
public var selectedTab:int = 0;
	
private var pageList:List;
private var tabsList:List;
private var scrollTime:Number = 0.01;
private var listCollection:ListCollection;
private var tabSize:int;

private var closeButton:CustomButton;

override protected function initialize():void
{
	super.initialize();
	
	autoSizeMode = AutoSizeMode.STAGE; 
	layout = new AnchorLayout();

	var tabsSize:int = 120 * appModel.scale;
	var footerSize:int = 160 * appModel.scale;
	
	var pageLayout:HorizontalLayout = new HorizontalLayout();
	pageLayout.horizontalAlign = HorizontalAlign.CENTER;
	pageLayout.verticalAlign = VerticalAlign.JUSTIFY;
	pageLayout.useVirtualLayout = true;
	
	refreshListData();
	
	pageList = new List();
	pageList.layout = pageLayout;
	pageList.layoutData = new AnchorLayoutData(tabsSize, 0, footerSize, 0);
	pageList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	pageList.snapToPages = true;
	pageList.addEventListener(FeathersEventType.FOCUS_IN, pageList_focusInHandler);
	pageList.verticalScrollPolicy = ScrollPolicy.OFF;
	pageList.itemRendererFactory = function ():IListItemRenderer { return new SegmentsItemRenderer(); }
	pageList.dataProvider = listCollection;
	addChild(pageList);
	
	tabSize = stage.stageWidth / listCollection.length;

	var tabLayout:HorizontalLayout = new HorizontalLayout();
	tabLayout.verticalAlign = VerticalAlign.JUSTIFY;
	tabLayout.useVirtualLayout = true;
	tabLayout.hasVariableItemDimensions = true;	
	
	tabsList = new List();
	tabsList.layout = tabLayout;
	tabsList.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
	tabsList.height = tabsSize;
	tabsList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	tabsList.horizontalScrollPolicy = tabsList.verticalScrollPolicy = ScrollPolicy.OFF;
	tabsList.addEventListener(Event.CHANGE, tabsList_changeHandler);
	tabsList.itemRendererFactory = function ():IListItemRenderer { return new SocialTabItemRenderer(tabSize); }
	tabsList.dataProvider = listCollection;
	tabsList.selectedIndex = selectedTab;
	addChild(tabsList);
		
	var footer:LayoutGroup = new LayoutGroup();
	footer.backgroundSkin = new Image(appModel.theme.tabUpSkinTexture);
	Image(footer.backgroundSkin).scale9Grid = BaseMetalWorksMobileTheme.TAB_SCALE9_GRID;
	footer.height = footerSize;
	footer.layoutData = new AnchorLayoutData(NaN,0,0,0);
	addChild(footer);
	
	closeButton = new CustomButton();
	closeButton.height = footerSize * 0.8;
	closeButton.layoutData = new AnchorLayoutData(NaN, NaN, footerSize*0.1, NaN, 0);
	closeButton.addEventListener(Event.TRIGGERED, backButtonHandler);
	closeButton.label = loc("close_button");
	addChild(closeButton);
	
	pageList.addEventListener(Event.UPDATE, pageList_updateHandler);
	pageList.addEventListener(Event.READY, pageList_readyHandler);
}

private function pageList_readyHandler(event:Event):void
{
	closeButton.isEnabled = event.data;
	tabsList.isEnabled = event.data;
	pageList.horizontalScrollPolicy = event.data ? ScrollPolicy.AUTO : ScrollPolicy.OFF;
}

private function pageList_updateHandler(event:Event):void
{
	listCollection.removeAll();
	setTimeout(refreshListData, 1000);
}

private function pageList_focusInHandler(event:Event):void
{
	var focusIndex:int = event.data as int;
	if(tabsList.selectedIndex != focusIndex)
		tabsList.selectedIndex = focusIndex;
}

private function tabsList_changeHandler(event:Event):void
{
	if(player.inTutorial() && tabsList.selectedIndex != 1)
		return;
	pageList.selectedIndex = tabsList.selectedIndex;
	pageList.scrollToDisplayIndex(tabsList.selectedIndex, scrollTime);
	scrollTime = 0.5;
	
	appModel.sounds.addAndPlaySound("tab");
}


private function refreshListData(): void
{
	SFSConnection.instance.lobbyManager.initialize();
	
	if( listCollection == null )
		listCollection = new ListCollection();
	else
		listCollection.removeAll();
	
	var ret:Array = new Array();
	for each(var p:int in SegmentType.getSocialSegments(SFSConnection.instance.lobbyManager.lobby != null)._list)
	{
		var pd:TabItemData = new TabItemData(p);
		/*if( !player.inTutorial() )
		{
			if( p == 2 )
			{
				var bs:Vector.<Building> = player.buildings.values();
				for each(var b:Building in bs)
				{
					if(b.upgradable())
						pd.badgeNumber ++;
					
					if( game.loginData.buildingsLevel.exists(b.type) )
						pd.newBadgeNumber ++;
				}
			}
			else if( p == 0 )
			{
				for each(var e:ExchangeItem in exchanger.items.values())
				if( e.type> ExchangeType.S_20_SPECIALS && e.expiredAt < timeManager.now )
					pd.badgeNumber ++;
			}
		}*/
		ret.push(pd);
	}
	listCollection.data = ret;
}

override protected function backButtonFunction():void
{
	if( !closeButton.isEnabled )
		return;
	super.backButtonFunction();
}

override public function dispose():void
{
	if( pageList != null )
		pageList.removeEventListener(Event.UPDATE, pageList_updateHandler);
	super.dispose();
}


}
}