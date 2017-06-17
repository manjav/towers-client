package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.controls.items.DashboardPageItemRenderer;
	import com.gerantech.towercraft.controls.items.DashboardTabItemRenderer;
	import com.gt.towers.constants.PageType;
	
	import feathers.controls.AutoSizeMode;
	import feathers.controls.List;
	import feathers.controls.ScrollBarDisplayMode;
	import feathers.controls.ScrollPolicy;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalAlign;
	import feathers.layout.VerticalLayout;
	import feathers.layout.VerticalLayoutData;
	
	import starling.events.Event;

	public class DashboardScreen extends BaseCustomScreen
	{
		private var pageList:List;
		private var tabsList:List;
		
		public function DashboardScreen(){}
		
		override protected function initialize():void
		{
			super.initialize();
			autoSizeMode = AutoSizeMode.STAGE; 
			layout = new VerticalLayout();
			
			var pageLayout:HorizontalLayout = new HorizontalLayout();
			pageLayout.horizontalAlign = HorizontalAlign.CENTER;
			pageLayout.verticalAlign = VerticalAlign.JUSTIFY;
			pageLayout.useVirtualLayout = true;
			pageLayout.hasVariableItemDimensions = true;
			
			pageList = new List();
			pageList.layout = pageLayout;
			pageList.layoutData = new VerticalLayoutData(100, 88);
			pageList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
			//pageList.pageWidth = stage.stageWidth;
			pageList.snapToPages = true;
			pageList.addEventListener(FeathersEventType.FOCUS_IN, pageList_focusInHandler);
			pageList.verticalScrollPolicy = ScrollPolicy.OFF;
			pageList.itemRendererFactory = function ():IListItemRenderer
			{
				return new DashboardPageItemRenderer();
			}
			pageList.dataProvider = new ListCollection(PageType.getAll()._list);
			addChild(pageList);
			
			
			var tabSize:Number = stage.stageWidth / 4;
			
			var tabLayout:HorizontalLayout = new HorizontalLayout();
			tabLayout.verticalAlign = VerticalAlign.JUSTIFY;
			tabLayout.useVirtualLayout = true;
			tabLayout.hasVariableItemDimensions = true;	
			
			tabsList = new List();
			tabsList.layout = tabLayout;
			tabsList.layoutData = new VerticalLayoutData(100, 12);
			tabsList.dataProvider = new ListCollection(PageType.getAll()._list);
			tabsList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
            tabsList.verticalScrollPolicy = ScrollPolicy.OFF;
            tabsList.itemRendererFactory = function ():IListItemRenderer
			{
				return new DashboardTabItemRenderer(tabSize);
			}
			tabsList.addEventListener(Event.CHANGE, tabsList_changeHandler);
			tabsList.selectedIndex = 1;
			addChild(tabsList);
		}
		
		private function pageList_focusInHandler(event:Event):void
		{
			var focusIndex:int = event.data as int;
			if(tabsList.selectedIndex != focusIndex)
				tabsList.selectedIndex = focusIndex;
			//trace(tabsList.selectedIndex, pageList.selectedIndex, focusIndex)
		}
		
		private function tabsList_changeHandler(event:Event):void
		{
			pageList.selectedIndex = tabsList.selectedIndex;
			pageList.scrollToDisplayIndex(tabsList.selectedIndex, 0.5);
		}
		
	}
}