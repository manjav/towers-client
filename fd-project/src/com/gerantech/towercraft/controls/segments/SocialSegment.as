package com.gerantech.towercraft.controls.segments
{
import com.gerantech.extensions.NativeAbilities;
import com.gerantech.towercraft.controls.items.SegmentsItemRenderer;
import com.gerantech.towercraft.controls.items.SocialTabItemRenderer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.vo.TabItemData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.battle.fieldes.ImageData;
import com.gt.towers.constants.SegmentType;
import com.smartfoxserver.v2.entities.data.ISFSObject;
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
import starling.display.Image;
import starling.events.Event;

public class SocialSegment extends Segment
{
public static var TAB_INDEX:int = 0;
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
	
	function showLabel(message:String) : void
	{
		var labelDisplay:ShadowLabel = new ShadowLabel(message, 1, 0, "center");
		labelDisplay.width = width;
		labelDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, NaN, 0);
		addChild(labelDisplay);
	}

	if( player.get_arena(0) < 1 )
	{
		showLabel(loc("availableat_messeage", [loc("tab-3"), loc("arena_text") + " " + loc("num_2")]));
		return;
	}
	
	if( appModel.loadingManager.serverData.containsKey("forbidenApps") )
	{
	var filter:Array = appModel.loadingManager.serverData.getText("forbidenApps").split(",");
	var installed:Array = NativeAbilities.instance.getInstalled();
	for each(var f:String in filter)
	{
		for each(var app:String in installed)
		{
			if( app.search(f) > -1 )
			{
				showLabel(loc("lobby_illigeal_app"));
				return;
			}
		}
	}}
	
	var ban:ISFSObject = appModel.loadingManager.serverData.containsKey("ban") ? appModel.loadingManager.serverData.getSFSObject("ban") : null;
    if( ban != null && ban.getInt("mode") > 1 )// banned user
    {
		backgroundSkin = new Image(appModel.theme.backgroundDisabledSkinTexture);
		Image(backgroundSkin).scale9Grid = MainTheme.DEFAULT_BACKGROUND_SCALE9_GRID;
		backgroundSkin.alpha = 0.6;
		
		showLabel(loc("lobby_banned", [StrUtils.toTimeFormat(ban.getLong("until"))]));
		
		var descDisplay:RTLLabel = new RTLLabel(ban.getUtfString("message"), 1, null, null, true, null, 0.6);
		descDisplay.layoutData = new AnchorLayoutData(NaN, 20, NaN, 20, NaN, 0);
		addChild(descDisplay);
		return;
    }
	
	var tabsSize:int = 120;
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
	tabsList.selectedIndex = TAB_INDEX;
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
	pageList.selectedIndex = TAB_INDEX = tabsList.selectedIndex;
	pageList.scrollToDisplayIndex(tabsList.selectedIndex, scrollTime);
	scrollTime = 0.5;
	
	appModel.sounds.addAndPlay("tab");
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