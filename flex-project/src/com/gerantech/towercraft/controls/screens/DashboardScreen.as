package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.controls.Toolbar;
	import com.gerantech.towercraft.controls.items.DashboardPageItemRenderer;
	import com.gerantech.towercraft.controls.items.DashboardTabItemRenderer;
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.constants.PageType;
	
	import flash.geom.Rectangle;
	
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
	import starling.events.Event;

	public class DashboardScreen extends BaseCustomScreen
	{
		private var pageList:List;
		private var tabsList:List;
		private var tabBorder:ImageLoader;
		private var tabSize:int;
		
		public function DashboardScreen(){}

		override protected function initialize():void
		{
			super.initialize();
			autoSizeMode = AutoSizeMode.STAGE; 
			layout = new AnchorLayout();
			
			var footerSize:int = 180 * appModel.scale;
			
			var pageLayout:HorizontalLayout = new HorizontalLayout();
			pageLayout.horizontalAlign = HorizontalAlign.CENTER;
			pageLayout.verticalAlign = VerticalAlign.JUSTIFY;
			pageLayout.useVirtualLayout = true;
			pageLayout.hasVariableItemDimensions = true;
			
			pageList = new List();
			pageList.layout = pageLayout;
			pageList.layoutData = new AnchorLayoutData(0, 0, footerSize, 0);
			pageList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
			pageList.snapToPages = true;
			pageList.addEventListener(FeathersEventType.FOCUS_IN, pageList_focusInHandler);
			pageList.addEventListener(FeathersEventType.ENTER, pageList_enterHandler);
			pageList.verticalScrollPolicy = ScrollPolicy.OFF;
			pageList.itemRendererFactory = function ():IListItemRenderer
			{
				return new DashboardPageItemRenderer();
			}
			pageList.dataProvider = new ListCollection(PageType.getAll()._list);
			addChild(pageList);
			
			tabSize = stage.stageWidth / 4;
			
			tabBorder = new ImageLoader();
			tabBorder.touchable = false;
			tabBorder.source = Assets.getTexture("tab-selected-border", "skin");
			tabBorder.width = tabSize*2;
			tabBorder.height = footerSize;
			tabBorder.layoutData = new AnchorLayoutData(NaN, NaN, 0, NaN);
			tabBorder.scale9Grid = new Rectangle(11,10,2,2);
			
			var tabLayout:HorizontalLayout = new HorizontalLayout();
			tabLayout.verticalAlign = VerticalAlign.JUSTIFY;
			tabLayout.useVirtualLayout = true;
			tabLayout.hasVariableItemDimensions = true;	
			
	
			tabsList = new List();
			tabsList.layout = tabLayout;
			tabsList.layoutData = new AnchorLayoutData(NaN, 0, 0, 0);
			tabsList.height = footerSize;
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
			
			var toolbar:Toolbar = new Toolbar();
			toolbar.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
			toolbar.addEventListener(Event.TRIGGERED, toolbar_triggerredHandler);
			addChild(toolbar);
			
			addChild(tabBorder);
		}
		
		private function pageList_enterHandler(event:Event):void
		{
			tabsList.selectedIndex = 0;
		}
		
		private function toolbar_triggerredHandler(event:Event):void
		{
			tabsList.selectedIndex = 0;
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
			Starling.juggler.tween(tabBorder, 0.3, {x:tabsList.selectedIndex * tabSize, transition:Transitions.EASE_OUT});
		}
		
	}
}