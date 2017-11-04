package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.controls.items.DashboardTabItemRenderer;
	import com.gerantech.towercraft.controls.items.SegmentsItemRenderer;
	import com.gerantech.towercraft.controls.popups.ConfirmPopup;
	import com.gerantech.towercraft.controls.popups.KeysPopup;
	import com.gerantech.towercraft.events.LoadingEvent;
	import com.gerantech.towercraft.managers.SoundManager;
	import com.gerantech.towercraft.managers.net.LoadingManager;
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
			visible = false;
			
			var footerSize:int = 180 * appModel.scale;
			
			var pageLayout:HorizontalLayout = new HorizontalLayout();
			pageLayout.horizontalAlign = HorizontalAlign.CENTER;
			pageLayout.verticalAlign = VerticalAlign.JUSTIFY;
			pageLayout.useVirtualLayout = false;
			//pageLayout.hasVariableItemDimensions = true;
			
			pageList = new List();
			pageList.layout = pageLayout;
			pageList.layoutData = new AnchorLayoutData(0, 0, footerSize, 0);
			pageList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
			pageList.snapToPages = true;
			pageList.addEventListener(FeathersEventType.FOCUS_IN, pageList_focusInHandler);
			//pageList.addEventListener(FeathersEventType.ENTER, pageList_enterHandler);
			pageList.verticalScrollPolicy = ScrollPolicy.OFF;
			pageList.itemRendererFactory = function ():IListItemRenderer { return new SegmentsItemRenderer(); }
			addChild(pageList);
			
			tabSize = stage.stageWidth / 4;
			
			var tabLayout:HorizontalLayout = new HorizontalLayout();
			tabLayout.verticalAlign = VerticalAlign.JUSTIFY;
			tabLayout.useVirtualLayout = false;
			tabLayout.hasVariableItemDimensions = true;	
			
			tabsList = new List();
			tabsList.layout = tabLayout;
			tabsList.layoutData = new AnchorLayoutData(NaN, 0, 0, 0);
			tabsList.height = footerSize;
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
		
		protected function loadingManager_loadedHandler(event:LoadingEvent):void
		{
			var listsData:Array = getListData();
			visible = true;
			pageList.dataProvider = new ListCollection(listsData);
			pageList.horizontalScrollPolicy = player.inTutorial() ? ScrollPolicy.OFF : ScrollPolicy.AUTO
			tabsList.dataProvider = new ListCollection(listsData);
			//tabsList.touchable = !player.inTutorial();
			gotoPage(1, 0.1);
			
			appModel.loadingManager.removeEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
			
			appModel.sounds.addSound("main-theme", null,  themeLoaded, SoundManager.CATE_THEME);
			function themeLoaded():void { if( player.prefs.getAsInt(PrefsTypes.TUTE_STEP_101)>PrefsTypes.TUTE_101_START ) appModel.sounds.playSoundUnique("main-theme", 1, 100); }
			
			appModel.navigator.handleInvokes();
			appModel.navigator.toolbar.addEventListener(Event.TRIGGERED, toolbar_triggerredHandler);
		}

		private function toolbar_triggerredHandler(event:Event):void
		{
			if( player.inTutorial())
				return;
			switch(event.data.resourceType)
			{
				case ResourceType.CURRENCY_SOFT:
				case ResourceType.CURRENCY_HARD:
					gotoPage(0);
					break;
				case ResourceType.POINT:
					ArenaScreen.showRanking( player.get_arena(0) );
					break;
				case ResourceType.KEY:
					appModel.navigator.addPopup(new KeysPopup());
					break;
			}
		}		
		private function getListData():Array
		{
			var ret:Array = new Array();
			for each(var p:int in SegmentType.getDashboardsSegments()._list)
			{
				var pd:TabItemData = new TabItemData(p);
				if( !player.inTutorial() )
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
							if( e.category == ExchangeType.CHEST_CATE_110_BATTLES && e.getState(timeManager.now) == ExchangeItem.CHEST_STATE_READY )
								pd.badgeNumber ++;
					}
				}
				ret.push(pd);
			}
			return ret;
		}

		private function pageList_focusInHandler(event:Event):void
		{
			var focusIndex:int = event.data as int;
			if( tabsList.selectedIndex != focusIndex )
				gotoPage(focusIndex);
		}
		
		private function tabsList_selectHandler(event:Event):void
		{trace(tabsList.selectedIndex, player.dashboadTabEnabled(tabsList.selectedIndex))
			if( player.dashboadTabEnabled(tabsList.selectedIndex) )
				gotoPage(tabsList.selectedIndex);
		}
		private function gotoPage(pageIndex:int, animDuration:Number = 0.3):void
		{
			pageList.selectedIndex = tabsList.selectedIndex = pageIndex;
			pageList.scrollToDisplayIndex(pageIndex, animDuration);
			Starling.juggler.tween(tabBorder, animDuration, {x:pageIndex * tabSize, transition:Transitions.EASE_OUT});
			if( animDuration > 0 )
				appModel.sounds.addAndPlaySound("tab");
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
	}
}