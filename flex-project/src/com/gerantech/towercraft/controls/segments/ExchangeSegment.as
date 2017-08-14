package com.gerantech.towercraft.controls.segments
{
	import com.gerantech.towercraft.controls.items.exchange.ExchangeCategoryItemRenderer;
	import com.gerantech.towercraft.controls.overlays.OpenChestOverlay;
	import com.gerantech.towercraft.controls.popups.RequirementConfirmPopup;
	import com.gerantech.towercraft.managers.BillingManager;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.vo.ShopLine;
	import com.gt.towers.constants.ExchangeType;
	import com.gt.towers.constants.ResourceType;
	import com.gt.towers.exchanges.ExchangeItem;
	import com.gt.towers.utils.GameError;
	import com.gt.towers.utils.maps.IntIntMap;
	import com.marpies.ane.gameanalytics.GameAnalytics;
	import com.marpies.ane.gameanalytics.data.GAResourceFlowType;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.filesystem.File;
	
	import feathers.controls.List;
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
		private var itemslistData:ListCollection;
		private var itemslist:List;
		
		public function ExchangeSegment()
		{
			super();
			//appModel.assetsManager.verbose = true;
			if( appModel.assets.getTexture("shop-line-header") != null )
				return;
			appModel.assets.enqueue(File.applicationDirectory.resolvePath( "assets/images/shop"));
			appModel.assets.loadQueue(appModel_loadCallback)
		}
		
		private function appModel_loadCallback(ratio:Number):void
		{
			if(ratio >= 1 && initializeStarted && !initializeCompleted)
				init();
		}
		
		override public function init():void
		{
			super.init();
			if(appModel.assets.isLoading )
				return;
			
			layout = new AnchorLayout();

			var listLayout:VerticalLayout = new VerticalLayout();
			listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
			listLayout.hasVariableItemDimensions = true;
			listLayout.paddingTop = 148 * appModel.scale;
			listLayout.useVirtualLayout = true;
			
			updateData();
			itemslist = new List();
			itemslist.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
			itemslist.layout = listLayout;
			itemslist.layoutData = new AnchorLayoutData(0,0,0,0);
			itemslist.itemRendererFactory = function():IListItemRenderer { return new ExchangeCategoryItemRenderer(); }
			itemslist.dataProvider = itemslistData;
			itemslist.addEventListener(FeathersEventType.FOCUS_IN, list_changeHandler);
			addChild(itemslist);
			initializeCompleted = true;
		}
		
		override public function updateData():void
		{
			if( itemslistData == null )
				itemslistData = new ListCollection();
			
			var itemKeys:Vector.<int> = exchanger.items.keys();
			var offers:ShopLine = new ShopLine(ExchangeType.S_20_SPECIALS);
			var chests:ShopLine = new ShopLine(ExchangeType.S_30_CHEST);
			var hards:ShopLine = new ShopLine(ExchangeType.S_0_HARD);
			var softs:ShopLine = new ShopLine(ExchangeType.S_10_SOFT);

			for (var i:int=0; i<itemKeys.length; i++)
			{
				if ( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.S_0_HARD )
					hards.add(itemKeys[i]);
				else if ( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.S_10_SOFT )
					softs.add(itemKeys[i]);
				else if(ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.S_20_SPECIALS )
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
			itemslistData.data = categoreis;
		}
		
		private function list_changeHandler(event:Event):void
		{
			var item:ExchangeItem = event.data as ExchangeItem;
			if(ExchangeType.getCategory(item.type) == ExchangeType.S_0_HARD)
			{
				BillingManager.instance.addEventListener(FeathersEventType.END_INTERACTION, billinManager_endInteractionHandler);
				BillingManager.instance.purchase("com.grantech.towers.item_"+item.type);
				function billinManager_endInteractionHandler ( event:Event ) : void {
					item.enabled = true;
				}
				return;
			}
			
			var params:SFSObject = new SFSObject();
			params.putInt("type", item.type );
			
			if(ExchangeType.getCategory(item.type) == ExchangeType.S_30_CHEST)
			{
				if(item.expiredAt > timeManager.now )
				{
					var req:IntIntMap = exchanger.getChestRequierement( item.expiredAt-timeManager.now );
					if( !player.has(req) )
					{
						var confirm:RequirementConfirmPopup = new RequirementConfirmPopup(loc("popup_timetogem_message"), req);
						confirm.data = item;
						confirm.addEventListener(FeathersEventType.ERROR, confirms_errorHandler);
						confirm.addEventListener(Event.SELECT, confirms_selectHandler);
						confirm.addEventListener(Event.CANCEL, confirms_cancelHandler);
						appModel.navigator.addPopup(confirm);
						return;
					}
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
				appModel.navigator.addPopup(confirm);
				return;
			}
			else
			{
				try
				{
					exchanger.exchange(item, 0);
				} 
				catch(error:GameError) 
				{
					if ( error.id == 0 )
						appModel.navigator.addLog(loc("log_not_enough", [loc("resource_title_"+error.object)]));
					return;
				}
				
				SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
				SFSConnection.instance.sendExtensionRequest(SFSCommands.EXCHANGE, params);
			}
		}

		
		private function confirms_cancelHandler(event:Event):void
		{
			var item:ExchangeItem = RequirementConfirmPopup(event.currentTarget).data as ExchangeItem;
			item.enabled = true;
		}
		private function confirms_errorHandler(event:Event):void
		{
			appModel.navigator.addLog(loc("log_not_enough", [loc("resource_title_1003")]));
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
					case ExchangeType.S_20_SPECIALS:
						itemslist.dataProvider.updateItemAt(0);
						//Game Analytic
						// track 
						//GameAnalytics.addResourceEvent(GAResourceFlowType.SOURCE, ResourceType.CURRENCY_HARD.toString(), 400, "IAP", "Coins400");
						//GameAnalytics.addResourceEvent(GAResourceFlowType.SINK, ResourceType.CURRENCY_SOFT.toString(), 400, "IAP", "Coins400");
						break;
					
					case ExchangeType.S_30_CHEST:
						item.outcomes = new IntIntMap();
						for(var i:int=0; i< data.getSFSArray("rewards").size(); i++ )
							item.outcomes.set(data.getSFSArray("rewards").getSFSObject(i).getInt("t"), data.getSFSArray("rewards").getSFSObject(i).getInt("c"));
						//Game Analytic
						//GameAnalytics.addResourceEvent(GAResourceFlowType.SOURCE, ResourceType.CURRENCY_HARD.toString(), 400, "IAP", "Coins400");
			
						var openChestOverlay:OpenChestOverlay = new OpenChestOverlay(item);
						openChestOverlay.addEventListener(Event.CLOSE, openChestOverlay_closeHandler);
						appModel.navigator.addOverlay(openChestOverlay);
						function openChestOverlay_closeHandler(event:Event):void {
							openChestOverlay.removeEventListener(Event.CLOSE, openChestOverlay_closeHandler);
							exchanger.exchange(item, data.getInt("now"), data.getInt("hards"));
							itemslist.dataProvider.updateItemAt(1);
						}
						break;
				}
				item.enabled = true;
			}

		}
		
	}
}