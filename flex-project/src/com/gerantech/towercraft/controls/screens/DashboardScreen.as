package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.controls.headers.Toolbar;
	import com.gerantech.towercraft.controls.items.DashboardPageItemRenderer;
	import com.gerantech.towercraft.controls.items.DashboardTabItemRenderer;
	import com.gerantech.towercraft.controls.popups.ConfirmPopup;
	import com.gerantech.towercraft.events.LoadingEvent;
	import com.gerantech.towercraft.managers.net.LoadingManager;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.models.vo.DashboardItemData;
	import com.gt.towers.buildings.Building;
	import com.gt.towers.constants.ExchangeType;
	import com.gt.towers.constants.PageType;
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
		private var scrollTime:Number = 0.01;
		
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
			pageLayout.useVirtualLayout = false;
			pageLayout.hasVariableItemDimensions = true;
			
			pageList = new List();
			pageList.layout = pageLayout;
			pageList.layoutData = new AnchorLayoutData(0, 0, footerSize, 0);
			pageList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
			pageList.snapToPages = true;
			pageList.addEventListener(FeathersEventType.FOCUS_IN, pageList_focusInHandler);
			//pageList.addEventListener(FeathersEventType.ENTER, pageList_enterHandler);
			pageList.verticalScrollPolicy = ScrollPolicy.OFF;
			pageList.itemRendererFactory = function ():IListItemRenderer { return new DashboardPageItemRenderer(); }
			addChild(pageList);
			
			tabSize = stage.stageWidth / 4;
			
			tabBorder = new ImageLoader();
			tabBorder.touchable = false;
			tabBorder.source = Assets.getTexture("tab-selected-border", "skin");
			tabBorder.width = tabSize * 2;
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
			tabsList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
            tabsList.verticalScrollPolicy = ScrollPolicy.OFF;
			tabsList.addEventListener(Event.CHANGE, tabsList_changeHandler);
			tabsList.itemRendererFactory = function ():IListItemRenderer { return new DashboardTabItemRenderer(tabSize); }
			addChild(tabsList);
			
			
		/*	var txt:String = "Hello word سلام بچه ها 123  ٠١٢ Hello word سلام بچه ها 123  ٠١٢ Hello word سلام بچه ها 123  ٠١٢ Hello word سلام بچه ها 123  ٠١٢ Hello word سلام بچه ها 123  ٠١٢ Hello word سلام بچه ها 123  ٠١٢ Hello word سلام بچه ها 123  ٠١٢ ";
			var text1:RTLLabel = new RTLLabel(txt, 1, null, null, true);
			text1.width = stage.stageWidth/2
			text1.layoutData = new AnchorLayoutData(0,NaN,NaN,0);
			addChild(text1);	
			var text2:RTLLabel = new RTLLabel(txt, 1, null, null, true, null, 0, "lalezarsupercell");
			text2.width = stage.stageWidth/2
			text2.layoutData = new AnchorLayoutData(0,0,NaN,NaN);
			addChild(text2);
			*/
			var toolbar:Toolbar = new Toolbar();
			toolbar.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
			toolbar.addEventListener(Event.TRIGGERED, toolbar_triggerredHandler);
			addChild(toolbar);
			
			addChild(tabBorder);
			
			if( appModel.loadingManager.state < LoadingManager.STATE_LOADED )
				appModel.loadingManager.addEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
			else
				loadingManager_loadedHandler(null);
		}
		
		protected function loadingManager_loadedHandler(event:LoadingEvent):void
		{
			var dashboardData:Array = getDashboardData();
			pageList.dataProvider = new ListCollection(dashboardData);
			pageList.horizontalScrollPolicy = player.inTutorial() ? ScrollPolicy.OFF : ScrollPolicy.AUTO
			tabsList.dataProvider = new ListCollection(dashboardData);
			tabsList.touchable = !player.inTutorial();
			tabsList.selectedIndex = 1;
			
			appModel.loadingManager.removeEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
			appModel.sounds.addSound("main-theme", null,  themeLoaded);
			function themeLoaded():void { appModel.sounds.playSoundUnique("main-theme", 1, 100); }
		}
		
		private function getDashboardData():Array
		{
			var ret:Array = new Array();
			for each(var p:int in PageType.getAll()._list)
			{
				var pd:DashboardItemData = new DashboardItemData(p);
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
							if( e.type> ExchangeType.S_20_BUILDING && e.expiredAt < timeManager.now )
								pd.badgeNumber ++;
					}
				}
				ret.push(pd);
			}
			
			return ret;
		}
		
		private function toolbar_triggerredHandler(event:Event):void
		{
			if( !player.inTutorial())
				tabsList.selectedIndex = 0;
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
			Starling.juggler.tween(tabBorder, 0.3, {x:tabsList.selectedIndex * tabSize, transition:Transitions.EASE_OUT});
			scrollTime = 0.5;
			
			appModel.sounds.addAndPlaySound("tab");
		}
		
		override protected function backButtonFunction():void
		{
			var confirm:ConfirmPopup = new ConfirmPopup(ResourceManager.getInstance().getString("loc", "popup_exit_message"));
			confirm.addEventListener(Event.SELECT, confirm_selectHandler);
			AppModel.instance.navigator.addPopup(confirm);
			function confirm_selectHandler ( event:Event ) : void
			{
				confirm.removeEventListener(Event.SELECT, confirm_selectHandler);
				NativeApplication.nativeApplication.exit();
			}
		}
	}
}