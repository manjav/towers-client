package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.items.DashboardTabLagacyItemRenderer;
import com.gerantech.towercraft.controls.items.SegmentsItemRenderer;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
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
import flash.desktop.NativeApplication;
import flash.geom.Rectangle;
import flash.utils.setTimeout;
import mx.resources.ResourceManager;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;
import starling.utils.Color;

public class DashboardScreen extends BaseCustomScreen
{
public static var tabIndex:int = 1;
protected var pageList:List;
protected var tabsList:List;
protected var tabSize:int;
protected var footerSize:int;
protected var segmentsCollection:ListCollection;

public function DashboardScreen()
{
	if( !Assets.animationAssetsLoaded )
		Assets.loadAnimationAssets(initialize);
}

override protected function initialize():void
{
	if( !Assets.animationAssetsLoaded )
		return;
	OpenBookOverlay.createFactory();
	FactionsScreen.createFactory();
	
	super.initialize();
	if( stage == null )
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	else
		addedToStageHandler(null);
}

protected function addedToStageHandler(event:Event):void
{
	removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	
	footerSize = 180 * appModel.scale;
	autoSizeMode = AutoSizeMode.STAGE; 
	layout = new AnchorLayout();
	visible = false;	

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
	pageList.verticalScrollPolicy = ScrollPolicy.OFF;
	pageList.itemRendererFactory = function ():IListItemRenderer { return new SegmentsItemRenderer(); }
	addChild(pageList);
	
	tabSize = stage.stageWidth / 5;
	
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
	addChild(tabsList);

	
	if( appModel.loadingManager.state < LoadingManager.STATE_LOADED )
		appModel.loadingManager.addEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
	else
		loadingManager_loadedHandler(null);
}

protected function loadingManager_loadedHandler(event:LoadingEvent):void
{
	appModel.loadingManager.removeEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
	// return to last open game
	if( appModel.loadingManager.serverData.getBool("inBattle") )
	{
		appModel.navigator.runBattle();
		return;
	}
	
	// tutorial mode
	if( player.inTutorial() )
	{
		if( player.tutorialMode == 0 )
			appModel.navigator.pushScreen(Main.QUESTS_SCREEN);
		else if( player.tutorialMode == 1 )
			appModel.navigator.runBattle();
		return;
	}
	
	segmentsCollection = getListData();

	pageList.dataProvider = segmentsCollection;
	pageList.horizontalScrollPolicy = player.inTutorial() ? ScrollPolicy.OFF : ScrollPolicy.AUTO
	pageList.addEventListener(Event.READY, pageList_readyHandler);
	pageList.addEventListener(FeathersEventType.SCROLL_COMPLETE, pageList_scrollCompleteHandler);
	tabsList.dataProvider = segmentsCollection;
	setTimeout(gotoPage, 10, tabIndex, 0.1);
	visible = true;
	
	appModel.sounds.addSound("main-theme", null,  themeLoaded, SoundManager.CATE_THEME);
	function themeLoaded():void { if( player.getTutorStep()>PrefsTypes.T_000_FIRST_RUN ) appModel.sounds.playSoundUnique("main-theme", 1, 100); }
	
	appModel.navigator.handleInvokes();
	appModel.navigator.addEventListener("bookOpened", navigator_bookOpenedHandler);
	
	SFSConnection.instance.lobbyManager.addEventListener(Event.UPDATE, lobbyManager_updateHandler);
}

private function pageList_readyHandler(event:Event):void
{
	tabsList.isEnabled = event.data;
	pageList.horizontalScrollPolicy = event.data ? ScrollPolicy.AUTO : ScrollPolicy.OFF;
}
protected function navigator_bookOpenedHandler(event:Event):void
{
	segmentsCollection = getListData();
	tabsList.dataProvider = segmentsCollection;
}
private function getListData():ListCollection
{
	var ret:ListCollection = new ListCollection();
	for each( var p:int in SegmentType.getDashboardsSegments()._list )
	{
		var pd:TabItemData = new TabItemData(p);
		if( !player.inTutorial() )
		{
			if( p == 0 )
			{
				for each(var e:ExchangeItem in exchanger.items.values())
				if( e.category == ExchangeType.C20_SPECIALS && e.numExchanges == 0 )
				{
					pd.newBadgeNumber ++;
					pd.badgeNumber ++;
				}
				
			}
			else if( p == 1 )
			{
				var bs:Vector.<Building> = player.buildings.values();
				for each(var b:Building in bs)
				{
					if( b == null )
						continue;
					
					//trace(b.type, b.upgradable() , player.buildings.get(b.type).get_level());
					if( b.upgradable() )
						pd.badgeNumber ++;
					
					if( player.buildings.get(b.type).get_level() == -1 )
						pd.newBadgeNumber ++;
				}
			}
			else if( p == 3 )
			{
				pd.badgeNumber = SFSConnection.instance.lobbyManager.numUnreads();
			}
		}
		ret.addItem(pd);
	}
	return ret;
}

private function pageList_scrollCompleteHandler(e:Event):void 
{
	if( !pageList.hasEventListener(FeathersEventType.FOCUS_IN) )
		pageList.addEventListener(FeathersEventType.FOCUS_IN, pageList_focusInHandler);
}

private function pageList_focusInHandler(event:Event):void
{
	tabsList.removeEventListeners(Event.SELECT);
	var focusIndex:int = event.data as int;
	if( tabsList.selectedIndex != focusIndex )
		gotoPage(focusIndex, 0.5, false);
	tabsList.addEventListener(Event.SELECT, tabsList_selectHandler);
}

private function tabsList_selectHandler(event:Event):void
{
	if( !player.dashboadTabEnabled(tabsList.selectedIndex) )
		return;
	pageList.removeEventListeners(FeathersEventType.FOCUS_IN);
	gotoPage(tabsList.selectedIndex);
}
public function gotoPage(pageIndex:int, animDuration:Number = 0.3, scrollPage:Boolean = true):void
{
	trace("gotoPage", tabIndex, pageIndex, ExchangeSegment.focusedCategory, pageList.selectedIndex, tabsList.selectedIndex)
	tabsList.selectedIndex = tabIndex = pageIndex;
	if( scrollPage )
		pageList.scrollToDisplayIndex(pageIndex, animDuration);
	if( animDuration > 0 )
		appModel.sounds.addAndPlaySound("tab");
	appModel.navigator.dispatchEventWith("dashboardTabChanged", false, animDuration);
}

private function lobbyManager_updateHandler(event:Event):void
{
	TabItemData(segmentsCollection.getItemAt(3)).badgeNumber = SFSConnection.instance.lobbyManager.numUnreads();
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
	if( appModel != null )
		appModel.loadingManager.removeEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
	super.dispose();
}
}
}