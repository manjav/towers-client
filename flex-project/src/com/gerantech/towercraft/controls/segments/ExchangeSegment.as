package com.gerantech.towercraft.controls.segments
{
	import com.gerantech.towercraft.controls.items.exchange.ExchangeCategoryItemRenderer;
	import com.gerantech.towercraft.controls.overlays.OpenChestOverlay;
	import com.gerantech.towercraft.controls.popups.AdConfirmPopup;
	import com.gerantech.towercraft.controls.popups.ChestsDetailsPopup;
	import com.gerantech.towercraft.controls.popups.ConfirmPopup;
	import com.gerantech.towercraft.controls.popups.RequirementConfirmPopup;
	import com.gerantech.towercraft.managers.BillingManager;
	import com.gerantech.towercraft.managers.VideoAdsManager;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.vo.ShopLine;
	import com.gerantech.towercraft.models.vo.VideoAd;
	import com.gt.towers.constants.ExchangeType;
	import com.gt.towers.constants.ResourceType;
	import com.gt.towers.exchanges.ExchangeItem;
	import com.gt.towers.utils.GameError;
	import com.gt.towers.utils.maps.IntIntMap;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
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

		private var openChestOverlay:OpenChestOverlay;
		
		public function ExchangeSegment()
		{
			super();
			// appModel.assets.verbose = true;
			if( appModel.assets.getTexture("shop-line-header") == null )
			{
				appModel.assets.enqueue(File.applicationDirectory.resolvePath( "assets/images/shop" ));
				appModel.assets.enqueue(File.applicationDirectory.resolvePath( "assets/animations/chests" ));
				appModel.assets.loadQueue(appModel_loadCallback)
			}
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
			
			OpenChestOverlay.createFactory();

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
			else return;
			
			var itemKeys:Vector.<int> = exchanger.items.keys();
			//var specials:ShopLine = new ShopLine(ExchangeType.S_20_SPECIALS);
			var battles:ShopLine = new ShopLine(ExchangeType.CHEST_CATE_110_BATTLES);
			var offers:ShopLine = new ShopLine(ExchangeType.CHEST_CATE_120_OFFERS);
			var hards:ShopLine = new ShopLine(ExchangeType.S_0_HARD);
			var softs:ShopLine = new ShopLine(ExchangeType.S_10_SOFT);
			for (var i:int=0; i<itemKeys.length; i++)
			{
				if ( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.S_0_HARD )
					hards.add(itemKeys[i]);
				else if ( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.S_10_SOFT )
					softs.add(itemKeys[i]);
				else if( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.CHEST_CATE_110_BATTLES )
					battles.add(itemKeys[i]);
				else if( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.CHEST_CATE_120_OFFERS )
					offers.add(itemKeys[i]);
			}
			
			var categoreis:Array = new Array( battles, offers, hards, softs );
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
			var cate:int = ExchangeType.getCategory(item.type);
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
			
			if( cate == ExchangeType.CHEST_CATE_110_BATTLES || cate == ExchangeType.CHEST_CATE_120_OFFERS )
			{
				appModel.navigator.addPopup(new ChestsDetailsPopup(item));
				item.enabled = true;
			}
			else if( !player.has(item.requirements) )
			{
				var confirm:RequirementConfirmPopup = new RequirementConfirmPopup(loc("popup_resourcetogem_message"), item.requirements);
				confirm.data = item;
				confirm.addEventListener(FeathersEventType.ERROR, confirms_errorHandler);
				confirm.addEventListener(Event.SELECT, confirms_selectHandler);
				confirm.addEventListener(Event.CANCEL, confirms_cancelHandler);
				appModel.navigator.addPopup(confirm);
				return;
			}
			else
			{
				if( ExchangeType.getCategory(item.type) == ExchangeType.S_10_SOFT )
				{
					var confirm1:ConfirmPopup = new ConfirmPopup(loc("popup_sure_label"));
					confirm1.addEventListener(Event.SELECT, confirm1_selectHandler);
					confirm1.addEventListener(Event.CANCEL, confirm1_cancelHandler);
					appModel.navigator.addPopup(confirm1);
					function confirm1_selectHandler ( event:Event ):void {
						confirm1.removeEventListener(Event.SELECT, confirm1_selectHandler);
						confirm1.removeEventListener(Event.CANCEL, confirm1_cancelHandler);
						exchange(item, params);
					}
					function confirm1_cancelHandler ( event:Event ):void {
						confirm1.removeEventListener(Event.SELECT, confirm1_selectHandler);
						confirm1.removeEventListener(Event.CANCEL, confirm1_cancelHandler);
						item.enabled = true;
					}
					return;
				}
				exchange(item, params);
			}
		}
		
		private function exchange(item:ExchangeItem, params:SFSObject):void
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
			sendData(item.type, params)			
		}
		
		private function sendData(type:int, params:SFSObject):void
		{
			if( ExchangeType.getCategory( type ) == ExchangeType.S_30_CHEST )
			{
				openChestOverlay = new OpenChestOverlay(type, params.containsKey("isAd"));
				appModel.navigator.addOverlay(openChestOverlay);
			}
			
			SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
			SFSConnection.instance.sendExtensionRequest(SFSCommands.EXCHANGE, params);			
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
			sendData(item.type, params);
		}

		protected function sfsConnection_extensionResponseHandler(event:SFSEvent):void
		{
			if( event.params.cmd != SFSCommands.EXCHANGE )
				return;
			SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
			var data:SFSObject = event.params.params;
			var item:ExchangeItem = exchanger.items.get(data.getInt("type"));
			if( data.getBool("succeed") )
			{
				switch(ExchangeType.getCategory(item.type))
				{
					case ExchangeType.S_20_SPECIALS:
						itemslist.dataProvider.updateItemAt(0);
						break;
					
					case ExchangeType.S_30_CHEST:
						item.outcomes = new IntIntMap();
						//trace(data.getSFSArray("rewards").getDump());
						var reward:ISFSObject;
						for(var i:int=0; i< data.getSFSArray("rewards").size(); i++ )
						{
							reward = data.getSFSArray("rewards").getSFSObject(i);
							if( reward.getInt("t") != ResourceType.XP && reward.getInt("t") != ResourceType.POINT )
								item.outcomes.set(reward.getInt("t"), reward.getInt("c"));
						}
						openChestOverlay.setItem( item );
						openChestOverlay.addEventListener(Event.CLOSE, openChestOverlay_closeHandler);
						function openChestOverlay_closeHandler(event:Event):void {
							openChestOverlay.removeEventListener(Event.CLOSE, openChestOverlay_closeHandler);
							if( !openChestOverlay.isAd )
								showAd(item.type);
							openChestOverlay = null;
							exchanger.exchange(item, data.getInt("now"), data.getInt("hards"));
							itemslist.dataProvider.updateItemAt(1);
						}
						break;
				}
				item.enabled = true;
			}

		}
		
		private function showAd(type:int):void
		{
			var adConfirmPopup:AdConfirmPopup = new AdConfirmPopup(type);
			adConfirmPopup.addEventListener(Event.SELECT, adConfirmPopup_selectHandler);
			appModel.navigator.addPopup(adConfirmPopup);
			function adConfirmPopup_selectHandler(event:Event):void {
				adConfirmPopup.removeEventListener(Event.SELECT, adConfirmPopup_selectHandler);
				VideoAdsManager.instance.requestAd(type, false);
				VideoAdsManager.instance.addEventListener(Event.COMPLETE, videoIdsManager_completeHandler);
			}
		}
		private function videoIdsManager_completeHandler(event:Event):void
		{
			VideoAdsManager.instance.removeEventListener(Event.COMPLETE, videoIdsManager_completeHandler);
			var ad:VideoAd = event.data as VideoAd;
			
			if( !ad.completed || !ad.rewarded )
				return;
			
			var params:SFSObject = new SFSObject();
			params.putInt("type", ad.type );
			params.putBool("isAd", true );
			sendData(ad.type, params);
		}
		
	}
}