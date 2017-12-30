package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.items.DashboardTabItemRenderer;
import com.gerantech.towercraft.controls.items.SegmentsItemRenderer;
import com.gerantech.towercraft.controls.popups.ConfirmPopup;
import com.gerantech.towercraft.controls.segments.ExchangeSegment;
import com.gerantech.towercraft.events.LoadingEvent;
import com.gerantech.towercraft.managers.SoundManager;
import com.gerantech.towercraft.managers.net.LoadingManager;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.TabItemData;
import com.gt.towers.buildings.Building;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.constants.SegmentType;
import com.gt.towers.exchanges.ExchangeItem;

import flash.desktop.NativeApplication;
import flash.geom.Rectangle;

import mx.resources.ResourceManager;

import feathers.controls.AutoSizeMode;
import feathers.controls.ImageLoader;
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

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class DashboardScreen extends BaseCustomScreen
{
public static var tabIndex:int = 2;
	
private var pageList:List;
private var tabsList:List;
private var tabBorder:ImageLoader;
private var tabSize:int;
private var segmentsCollection:ListCollection;

public function DashboardScreen(){}

override protected function initialize():void
{
	super.initialize();
	var footerSize:int = 180 * appModel.scale;
	autoSizeMode = AutoSizeMode.STAGE; 
	layout = new AnchorLayout();
	visible = false;	
	
	var tiledBG:Image = new Image(Assets.getTexture("main-map-tile", "gui"));
	tiledBG.tileGrid = new Rectangle(appModel.scale, appModel.scale, 256*appModel.scale, 256*appModel.scale);
	backgroundSkin = tiledBG;
	
	var shadow:Image = new Image(Assets.getTexture("bg-shadow", "gui"));
	shadow.width = stage.stageWidth;
	shadow.height = stage.stageHeight-footerSize;
	addChildAt(shadow, 0);

	var pageLayout:HorizontalLayout = new HorizontalLayout();
	pageLayout.horizontalAlign = HorizontalAlign.CENTER;
	pageLayout.verticalAlign = VerticalAlign.JUSTIFY;
	pageLayout.useVirtualLayout = false;
	
	pageList = new List();
	pageList.layout = pageLayout;
	pageList.layoutData = new AnchorLayoutData(0, 0, footerSize, 0);
	pageList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	pageList.snapToPages = true;
	pageList.addEventListener(FeathersEventType.FOCUS_IN, pageList_focusInHandler);
	pageList.addEventListener("scrollPolicy", pageList_scrollPolicyHandler);
	pageList.verticalScrollPolicy = ScrollPolicy.OFF;
	pageList.itemRendererFactory = function ():IListItemRenderer { return new SegmentsItemRenderer(); }
	addChild(pageList);
	
	tabSize = stage.stageWidth / 6;
	
	var tabLayout:HorizontalLayout = new HorizontalLayout();
	tabLayout.verticalAlign = VerticalAlign.JUSTIFY;
	tabLayout.useVirtualLayout = false;
	tabLayout.hasVariableItemDimensions = true;	
	
	tabsList = new List();
	tabsList.layout = tabLayout;
	tabsList.layoutData = new AnchorLayoutData(NaN, 0, 0, 0);
	tabsList.height = footerSize;
	tabsList.clipContent = false;
	tabsList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
    tabsList.verticalScrollPolicy = ScrollPolicy.OFF;
	tabsList.addEventListener(Event.SELECT, tabsList_selectHandler);
	tabsList.itemRendererFactory = function ():IListItemRenderer { return new DashboardTabItemRenderer(tabSize); }
	addChild(tabsList);
	
	tabBorder = new ImageLoader();
	tabBorder.touchable = false;
	tabBorder.source = Assets.getTexture("theme/tab-selected-border", "gui");
	tabBorder.width = tabSize * 2;
	tabBorder.height = footerSize;
	tabBorder.layoutData = new AnchorLayoutData(NaN, NaN, 0, NaN);
	tabBorder.scale9Grid = new Rectangle(11,10,2,2);
	addChild(tabBorder);
	
	if( appModel.loadingManager.state < LoadingManager.STATE_LOADED )
		appModel.loadingManager.addEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
	else
		loadingManager_loadedHandler(null);
}

private function pageList_scrollPolicyHandler(event:Event):void
{
	pageList.horizontalScrollPolicy = event.data ? ScrollPolicy.AUTO : ScrollPolicy.OFF;
}

protected function loadingManager_loadedHandler(event:LoadingEvent):void
{
	appModel.loadingManager.removeEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
	// tutorial mode
	var tuteStep:int = player.prefs.getAsInt(PrefsTypes.TUTE_STEP_101);
	if( player.get_questIndex() < 3 && tuteStep != PrefsTypes.TUTE_111_SELECT_EXCHANGE && tuteStep != PrefsTypes.TUTE_113_SELECT_DECK )
	{
		appModel.navigator.pushScreen(Main.QUESTS_SCREEN);
		return;
	}
	
	segmentsCollection = getListData();
	pageList.dataProvider = segmentsCollection;
	pageList.horizontalScrollPolicy = player.inTutorial() ? ScrollPolicy.OFF : ScrollPolicy.AUTO
	tabsList.dataProvider = segmentsCollection;
	gotoPage(tabIndex, 0.1);
	visible = true;
	
	appModel.sounds.addSound("main-theme", null,  themeLoaded, SoundManager.CATE_THEME);
	function themeLoaded():void { if( player.prefs.getAsInt(PrefsTypes.TUTE_STEP_101)>PrefsTypes.TUTE_101_START ) appModel.sounds.playSoundUnique("main-theme", 1, 100); }
	
	appModel.navigator.handleInvokes();
	appModel.navigator.toolbar.addEventListener(Event.SELECT, toolbar_selectHandler);
	
	SFSConnection.instance.lobbyManager.addEventListener(Event.UPDATE, lobbyManager_updateHandler);
}

private function getListData():ListCollection
{
	var ret:ListCollection = new ListCollection();
	for each(var p:int in SegmentType.getDashboardsSegments()._list)
	{
		var pd:TabItemData = new TabItemData(p);
		if( !player.inTutorial() )
		{
			if( p == SegmentType.S0_SHOP )
			{
				for each(var e:ExchangeItem in exchanger.items.values())
				if( e.category == ExchangeType.CHEST_CATE_110_BATTLES && e.getState(timeManager.now) == ExchangeItem.CHEST_STATE_READY )
					pd.badgeNumber ++;
			}
			else if( p == SegmentType.S1_DECK )
			{
				var bs:Vector.<Building> = player.buildings.values();
				for each(var b:Building in bs)
				{
					if( b == null )
						continue;
					
					if( b.upgradable() )
						pd.badgeNumber ++;
					
					if( player.newBuildings.exists(b.type) )
						pd.newBadgeNumber ++;
				}
			}
			else if( p == SegmentType.S3_SOCIALS )
			{
				pd.badgeNumber = SFSConnection.instance.lobbyManager.numUnreads();
			}
		}
		ret.addItem(pd);
	}
	return ret;
}

private function pageList_focusInHandler(event:Event):void
{
	var focusIndex:int = event.data as int;
	if( tabsList.selectedIndex != focusIndex )
		gotoPage(focusIndex, 0.5, false);
}

private function tabsList_selectHandler(event:Event):void
{
	if( player.dashboadTabEnabled(tabsList.selectedIndex) )
		gotoPage(tabsList.selectedIndex);
}
private function gotoPage(pageIndex:int, animDuration:Number = 0.3, scrollPage:Boolean = true):void
{
	//trace("gotoPage", tabIndex, pageIndex, ExchangeSegment.focusedCategory, pageList.selectedIndex, tabsList.selectedIndex)
	tabsList.selectedIndex = tabIndex = pageIndex;
	if( scrollPage )
		pageList.scrollToDisplayIndex(pageIndex, animDuration);
	if( animDuration > 0 )
		appModel.sounds.addAndPlaySound("tab");
	Starling.juggler.tween(tabBorder, animDuration, {x:pageIndex * tabSize, transition:Transitions.EASE_OUT});
}

private function lobbyManager_updateHandler(event:Event):void
{
	TabItemData(segmentsCollection.getItemAt(3)).badgeNumber = SFSConnection.instance.lobbyManager.numUnreads();
}
private function toolbar_selectHandler(event:Event):void
{
	if( player.inTutorial() || tabIndex == 0 )
		return;
	
	if( event.data.resourceType == ResourceType.CURRENCY_SOFT )
	{
		ExchangeSegment.focusedCategory = 3;
		gotoPage(0);
	}
	else if( event.data.resourceType == ResourceType.CURRENCY_HARD )
	{
		ExchangeSegment.focusedCategory = 2;
		gotoPage(0);
	}
}

override protected function backButtonFunction():void
{
	var confirm:ConfirmPopup = new ConfirmPopup(ResourceManager.getInstance().getString("loc", "popup_exit_message"), loc("popup_exit_label"));
	confirm.acceptStyle = "danger";
	confirm.addEventListener(Event.SELECT, confirm_selectHandler);
	appModel.navigator.addPopup(confirm);
	function confirm_selectHandler ( event:Event ) : void
	{
		confirm.removeEventListener(Event.SELECT, confirm_selectHandler);
		NativeApplication.nativeApplication.exit();
	}
}

override public function dispose():void
{
	tabIndex = 2;
	appModel.navigator.toolbar.removeEventListener(Event.SELECT, toolbar_selectHandler);
	super.dispose();
}
}
}