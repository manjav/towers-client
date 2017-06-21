package com.gerantech.towercraft.controls.segments
{
	import com.gerantech.towercraft.controls.FastList;
	import com.gerantech.towercraft.controls.items.exchange.ExchangeCategoryItemRenderer;
	import com.gerantech.towercraft.managers.net.LoadingManager;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.vo.ShopLine;
	import com.gt.towers.constants.ExchangeType;
	import com.gt.towers.constants.ResourceType;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.filesystem.File;
	
	import feathers.controls.ScrollBarDisplayMode;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalLayout;
	
	import starling.events.Event;

	public class ExchangeSegment extends Segment
	{
		private var itemslist:FastList;
		public function ExchangeSegment()
		{
			super();
			appModel.assetsManager.enqueue(File.applicationDirectory.resolvePath( "assets/images/shop"));
			appModel.assetsManager.loadQueue(appModel_loadCallback)
		}
	
		override protected function createElements():void
		{
			if(appModel.assetsManager.isLoading || appModel.loadingManager.state < LoadingManager.STATE_LOADED )
				return;
			
			layout = new AnchorLayout();
			/*var listLayout:TiledRowsLayout = new TiledRowsLayout();
			listLayout.padding = listLayout.gap = 10;
			listLayout.paddingBottom = listLayout.paddingTop = 50;
			listLayout.useSquareTiles = false;
			listLayout.requestedColumnCount = 3;
			listLayout.typicalItemWidth = (width -listLayout.gap*(listLayout.requestedColumnCount+1)) / listLayout.requestedColumnCount;
			listLayout.typicalItemHeight = listLayout.typicalItemWidth * 1.4;*/
			
			var listLayout:VerticalLayout = new VerticalLayout();
			listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
			listLayout.hasVariableItemDimensions = true;
			listLayout.paddingTop = 148 * appModel.scale;
			listLayout.useVirtualLayout = true;
			
			
			itemslist = new FastList();
			itemslist.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
			itemslist.layout = listLayout;
			itemslist.layoutData = new AnchorLayoutData(0,0,0,0);
			itemslist.itemRendererFactory = function():IListItemRenderer
			{
				return new ExchangeCategoryItemRenderer();
			}
			itemslist.dataProvider = new ListCollection(createShopData());
			itemslist.addEventListener(FeathersEventType.FOCUS_IN, list_changeHandler);
			addChild(itemslist);
		}
		
		private function appModel_loadCallback(ratio:Number):void
		{
			if(ratio >= 1)
				createElements();
		}
		
		private function createShopData():Array
		{
			var bundles:Vector.<int> = core.get_exchanger().bundlesMap.keys();
			var offers:ShopLine = new ShopLine(ExchangeType.S_20_BUILDING);
			var chests:ShopLine = new ShopLine(ExchangeType.S_30_CHEST);
			var hards:ShopLine = new ShopLine(ExchangeType.S_0_HARD);
			var softs:ShopLine = new ShopLine(ExchangeType.S_10_SOFT);

			for (var i:int=0; i<bundles.length; i++)
			{
				if ( ExchangeType.getCategory( bundles[i] ) == ExchangeType.S_0_HARD )
					hards.add(bundles[i]);
				else if ( ExchangeType.getCategory( bundles[i] ) == ExchangeType.S_10_SOFT )
					softs.add(bundles[i]);
				else if(ExchangeType.getCategory( bundles[i] ) == ExchangeType.S_20_BUILDING )
					offers.add(bundles[i]);
				else if( ExchangeType.getCategory( bundles[i] ) == ExchangeType.S_30_CHEST )
					chests.add(bundles[i]);
			}
			
			var categoreis:Array = new Array( offers, chests, hards, softs );
			for (i=0; i<categoreis.length; i++)
				categoreis[i].items.sort();
			return categoreis;
		}
		
		private function list_changeHandler(event:Event):void
		{
			var type:int = event.data as int;
			
			if(ExchangeType.getCategory(type) == ExchangeType.S_0_HARD)
			{
				trace("Go to Purchase Manager");
				return;
			}
			
			var params:SFSObject = new SFSObject();
			params.putInt("type", type );
			SFSConnection.instance.sendExtensionRequest(SFSCommands.EXCHANGE, params);
			
			if(ExchangeType.getCategory(type) != ExchangeType.S_30_CHEST)
				core.get_exchanger().exchange(event.data as int);
			else
				SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
		}
		
		protected function sfsConnection_extensionResponseHandler(event:SFSEvent):void
		{
			SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
			trace(event.params.params.getDump())
		}
		
	}
}