package com.gerantech.towercraft.controls.segments
{
	import com.gerantech.towercraft.controls.FastList;
	import com.gerantech.towercraft.controls.GameLog;
	import com.gerantech.towercraft.controls.items.exchange.ExchangeCategoryItemRenderer;
	import com.gerantech.towercraft.controls.overlays.BattleOutcomeOverlay;
	import com.gerantech.towercraft.controls.overlays.OpenChestOverlay;
	import com.gerantech.towercraft.controls.popups.RequirementConfirmPopup;
	import com.gerantech.towercraft.managers.net.LoadingManager;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.vo.ShopLine;
	import com.gt.towers.constants.ExchangeType;
	import com.gt.towers.constants.ResourceType;
	import com.gt.towers.exchanges.ExchangeItem;
	import com.gt.towers.utils.maps.IntIntMap;
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
			//appModel.assetsManager.verbose = true;
			if( appModel.assetsManager.getTexture("shop-line-header") != null )
				return;
			appModel.assetsManager.enqueue(File.applicationDirectory.resolvePath( "assets/images/shop"));
			appModel.assetsManager.loadQueue(appModel_loadCallback)
		}
	
		override protected function initialize():void
		{
			if(appModel.assetsManager.isLoading )
				return;
			
			super.initialize()
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
				initialize();
		}
		
		private function createShopData():Array
		{
			var itemKeys:Vector.<int> = exchanger.items.keys();
			var offers:ShopLine = new ShopLine(ExchangeType.S_20_BUILDING);
			var chests:ShopLine = new ShopLine(ExchangeType.S_30_CHEST);
			var hards:ShopLine = new ShopLine(ExchangeType.S_0_HARD);
			var softs:ShopLine = new ShopLine(ExchangeType.S_10_SOFT);

			for (var i:int=0; i<itemKeys.length; i++)
			{
				if ( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.S_0_HARD )
					hards.add(itemKeys[i]);
				else if ( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.S_10_SOFT )
					softs.add(itemKeys[i]);
				else if(ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.S_20_BUILDING )
					offers.add(itemKeys[i]);
				else if( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.S_30_CHEST )
					chests.add(itemKeys[i]);
			}
			
			var categoreis:Array = new Array( offers, chests, hards, softs );
			for (i=0; i<categoreis.length; i++)
			{
				categoreis[i].items.sort();
				if(!appModel.isLTR)
					categoreis[i].items.reverse();

			}
			return categoreis;
		}
		
		private function list_changeHandler(event:Event):void
		{
			var item:ExchangeItem = event.data as ExchangeItem;
			if(ExchangeType.getCategory(item.type) == ExchangeType.S_0_HARD)
			{
				trace("Go to Purchase Manager");
				return;
			}
			
			var params:SFSObject = new SFSObject();
			params.putInt("type", item.type );
			
			if(ExchangeType.getCategory(item.type) == ExchangeType.S_30_CHEST)
			{
				if(item.expiredAt > timeManager.now )
				{
					var req:IntIntMap = new IntIntMap();
					req.set(ResourceType.CURRENCY_HARD, exchanger.timeToHard(item.expiredAt-timeManager.now));
					var confirm:RequirementConfirmPopup = new RequirementConfirmPopup(loc("popup_timetogem_message"), req);
					confirm.data = item;
					confirm.addEventListener(FeathersEventType.ERROR, confirms_errorHandler);
					confirm.addEventListener(Event.SELECT, confirms_selectHandler);
					confirm.addEventListener(Event.CANCEL, confirms_cancelHandler);
					appModel.navigator.addChild(confirm);
					return;
				}
				SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
				SFSConnection.instance.sendExtensionRequest(SFSCommands.EXCHANGE, params);
			}
			else if( !player.has(item.requirements) )
			{
				confirm = new RequirementConfirmPopup(loc("popup_resourcetogem_message"), item.requirements);
				confirm.data = item;
				confirm.addEventListener(FeathersEventType.ERROR, confirms_errorHandler);
				confirm.addEventListener(Event.SELECT, confirms_selectHandler);
				confirm.addEventListener(Event.CANCEL, confirms_cancelHandler);
				appModel.navigator.addChild(confirm);
				return;
			}
			else
			{
				exchanger.exchange(item, 0);
				SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
				SFSConnection.instance.sendExtensionRequest(SFSCommands.EXCHANGE, params);
			}
		}
		
		private function openChestOverlay_closeHandler():void
		{
			// TODO Auto Generated method stub
			
		}
		
		private function confirms_cancelHandler(event:Event):void
		{
			var item:ExchangeItem = RequirementConfirmPopup(event.currentTarget).data as ExchangeItem;
			item.enabled = true;
		}
		private function confirms_errorHandler(event:Event):void
		{
			appModel.navigator.addLog(loc("log_not_enough", [2]));
		}
		private function confirms_selectHandler(event:Event):void
		{
			var item:ExchangeItem = RequirementConfirmPopup(event.currentTarget).data as ExchangeItem;
			var params:SFSObject = new SFSObject();
			params.putInt("type", item.type );
			params.putInt("hards", RequirementConfirmPopup(event.currentTarget).numHards );
			SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
			SFSConnection.instance.sendExtensionRequest(SFSCommands.EXCHANGE, params);
		}

		protected function sfsConnection_extensionResponseHandler(event:SFSEvent):void
		{
			//trace(event.params.params.getDump());
			SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
			var data:SFSObject = event.params.params;
			var item:ExchangeItem = exchanger.items.get(data.getInt("type"));
			if( data.getBool("succeed") )
			{
				switch(ExchangeType.getCategory(item.type))
				{
					case ExchangeType.S_20_BUILDING:
						itemslist.dataProvider.updateItemAt(0);
						break;
					
					case ExchangeType.S_30_CHEST:
						var openChestOverlay:OpenChestOverlay = new OpenChestOverlay(item.type, data.getSFSArray("rewards"));
						openChestOverlay.addEventListener(Event.CLOSE, openChestOverlay_closeHandler);
						appModel.navigator.addChild(openChestOverlay);
						
						exchanger.exchange(item, data.getInt("now"));
						itemslist.dataProvider.updateItemAt(1);
						
						break;
				}
				item.enabled = true;
			}

		}
		
	}
}