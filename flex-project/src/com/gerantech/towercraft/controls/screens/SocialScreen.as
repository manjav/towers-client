package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.items.SegmentsItemRenderer;
import com.gerantech.towercraft.controls.items.SocialTabItemRenderer;
import com.gerantech.towercraft.models.vo.TabItemData;
import com.gt.towers.buildings.Building;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.SegmentType;
import com.gt.towers.exchanges.ExchangeItem;

import feathers.controls.AutoSizeMode;
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

import starling.events.Event;

public class SocialScreen extends BaseCustomScreen
{
private var pageList:List;
private var tabsList:List;
private var scrollTime:Number = 0.01;

private var tabSize:int;

override protected function initialize():void
{
	super.initialize();
	
	autoSizeMode = AutoSizeMode.STAGE; 
	layout = new AnchorLayout();

	var footerSize:int = 100 * appModel.scale;
	
	var pageLayout:HorizontalLayout = new HorizontalLayout();
	pageLayout.horizontalAlign = HorizontalAlign.CENTER;
	pageLayout.verticalAlign = VerticalAlign.JUSTIFY;
	pageLayout.useVirtualLayout = false;
	pageLayout.hasVariableItemDimensions = true;
	
	var listData:Array = getListData();
	
	pageList = new List();
	pageList.layout = pageLayout;
	pageList.layoutData = new AnchorLayoutData(footerSize, 0, 0, 0);
	pageList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	pageList.snapToPages = true;
	pageList.addEventListener(FeathersEventType.FOCUS_IN, pageList_focusInHandler);
	pageList.verticalScrollPolicy = ScrollPolicy.OFF;
	pageList.itemRendererFactory = function ():IListItemRenderer { return new SegmentsItemRenderer(); }
	pageList.dataProvider = new ListCollection(listData);
	addChild(pageList);
	
	tabSize = stage.stageWidth / listData.length;

	var tabLayout:HorizontalLayout = new HorizontalLayout();
	tabLayout.verticalAlign = VerticalAlign.JUSTIFY;
	tabLayout.useVirtualLayout = true;
	tabLayout.hasVariableItemDimensions = true;	
	
	tabsList = new List();
	tabsList.layout = tabLayout;
	tabsList.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
	tabsList.height = footerSize;
	tabsList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	tabsList.verticalScrollPolicy = ScrollPolicy.OFF;
	tabsList.addEventListener(Event.CHANGE, tabsList_changeHandler);
	tabsList.itemRendererFactory = function ():IListItemRenderer { return new SocialTabItemRenderer(tabSize); }
	tabsList.dataProvider = new ListCollection(listData);
	addChild(tabsList);
	
	tabsList.selectedIndex = 1;
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


private function getListData():Array
{
	var ret:Array = new Array();
	for each(var p:int in SegmentType.getSocialSegments()._list)
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
	return ret;
}
}
}