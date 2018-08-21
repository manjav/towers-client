package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.controls.items.SegmentsItemRenderer;
import com.gerantech.towercraft.controls.items.SocialTabItemRenderer;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.vo.TabItemData;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.SegmentType;
import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import flash.utils.setTimeout;
import starling.events.Event;

public class SocialSegment extends Segment
{
public static var tabIndex:int = 0;
private var pageList:List;
private var tabsList:List;
private var scrollTime:Number = 0.01;
private var listCollection:ListCollection;
private var tabSize:int;
public function SocialSegment() { super(); }
override public function init():void
{
	if( initializeCompleted )
		return;
	super.init();
	layout = new AnchorLayout();
	
	var labelDisplay:ShadowLabel;
	if( player.get_arena(0) < 1 )
	{
		labelDisplay = new ShadowLabel(loc("availableat_messeage", [loc("tab-3"), loc("arena_text") + " " + loc("num_2")]));
		labelDisplay.width = width;
		labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
		addChild(labelDisplay);
		return;
	}
	
    if( appModel.loadingManager.serverData.containsKey("ban") && appModel.loadingManager.serverData.getSFSObject("ban").getInt("mode") > 1 )// banned user
    {
		labelDisplay = new ShadowLabel(loc("lobby_banned", [StrUtils.toTimeFormat(appModel.loadingManager.serverData.getSFSObject("ban").getLong("until"))]), 1, 0, "center", null, true);
		labelDisplay.width = width;
		labelDisplay.layoutData = new AnchorLayoutData(NaN, 20, NaN, 20, NaN, 0);
		addChild(labelDisplay);
		return;
    }
	
	var tabsSize:int = 120 * appModel.scale;
	var pageLayout:HorizontalLayout = new HorizontalLayout();
	pageLayout.horizontalAlign = HorizontalAlign.CENTER;
	pageLayout.verticalAlign = VerticalAlign.JUSTIFY;
	pageLayout.useVirtualLayout = true;
	
	refreshListData();
	
	pageList = new List();
	pageList.layout = pageLayout;
	pageList.layoutData = new AnchorLayoutData(tabsSize*2, 0, 0, 0);
	pageList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	pageList.snapToPages = true;
	pageList.horizontalScrollPolicy = pageList.verticalScrollPolicy = ScrollPolicy.OFF;
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
	tabsList.layoutData = new AnchorLayoutData(tabsSize, 0, NaN, 0);
	tabsList.height = tabsSize;
	tabsList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	tabsList.horizontalScrollPolicy = tabsList.verticalScrollPolicy = ScrollPolicy.OFF;
	tabsList.addEventListener(Event.CHANGE, tabsList_changeHandler);
	tabsList.itemRendererFactory = function ():IListItemRenderer { return new SocialTabItemRenderer(tabSize); }
	tabsList.dataProvider = listCollection;
	tabsList.selectedIndex = tabIndex;
	addChild(tabsList);
	
	pageList.addEventListener(Event.UPDATE, pageList_updateHandler);
	pageList.addEventListener(Event.READY, pageList_readyHandler);
	initializeCompleted = true;
}

private function pageList_readyHandler(event:Event):void
{
	tabsList.isEnabled = event.data;
	pageList.horizontalScrollPolicy = event.data ? ScrollPolicy.AUTO : ScrollPolicy.OFF;
}

private function pageList_updateHandler(event:Event):void
{
	listCollection.removeAll();
	setTimeout(refreshListData, 1000);
}

private function tabsList_changeHandler(event:Event):void
{
	if( player.inTutorial() && tabsList.selectedIndex != 1 )
		return;
	pageList.selectedIndex = tabIndex = tabsList.selectedIndex;
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
		ret.push(new TabItemData(p));
	listCollection.data = ret;
}
override public function dispose():void
{
	if( pageList != null )
		pageList.removeEventListener(Event.UPDATE, pageList_updateHandler);
	super.dispose();
}
}
}