package com.gerantech.towercraft.managers
{
	import com.gerantech.extensions.NativeAbilities;
	import com.gerantech.towercraft.controls.popups.MessagePopup;
	import com.gerantech.towercraft.events.LoadingEvent;
	import com.gerantech.towercraft.managers.net.LoadingManager;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.vo.UserData;
	import com.gerantech.towercraft.utils.StrUtils;
	import com.gt.towers.constants.ExchangeType;
	import com.gt.towers.exchanges.ExchangeItem;
	import com.gt.towers.exchanges.Exchanger;
	import com.pozirk.payment.android.InAppPurchase;
	import com.pozirk.payment.android.InAppPurchaseDetails;
	import com.pozirk.payment.android.InAppPurchaseEvent;
	import com.pozirk.payment.android.InAppSkuDetails;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.resources.ResourceManager;
	
	import feathers.events.FeathersEventType;
	
	import starling.events.EventDispatcher;
	
	public class BillingManager extends EventDispatcher
	{
		private var _iap:InAppPurchase;
			
		private static var _instance:BillingManager;
		private var inited:Boolean;
		
		private var items:Array;
		private var skus:Vector.<InAppSkuDetails>;
		private var purchases:Vector.<InAppPurchaseDetails>;
		private var retryPurchase:String;

		private var purchaseDetails:InAppPurchaseDetails;

		private var skuDetails:InAppSkuDetails;
		
		public static function get instance():BillingManager
		{
			if(_instance == null)
				_instance = new BillingManager();
			return (_instance);
		}

		
		public function BillingManager(){}
		protected function loadingManager_loadedHandler(event:LoadingEvent):void
		{
			AppModel.instance.loadingManager.removeEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
			init();
		}		
		public function init():void
		{
			if( AppModel.instance.loadingManager.state < LoadingManager.STATE_LOADED )
			{
				AppModel.instance.loadingManager.addEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
				return;
			}
			
			// provide all sku items
			items = new Array("com.grantech.towers.item_0");
			var keys:Vector.<int> = AppModel.instance.game.exchanger.items.keys();
			for each(var k:int in keys)
				if( ExchangeType.getCategory(k) == ExchangeType.S_0_HARD )
					items.push("com.grantech.towers.item_" + k);
			
			var base64Key:String, bindURL:String, packageURL:String;
			switch(AppModel.instance.descriptor.market)
			{
				case "google":
					base64Key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuML2Gtw7jaO2bO1/JqtnvIIMH04IdQ/nX89tPz/Q9ltm3JyILgvSJJL36cmRqfvsHD4pXPuIu14cb/+iRVuSodASgtGpPCmv21l6wXT++VEED5TdWJCNZoyOnwt3iGWdpoUQNqpqj0hn46O7mmJdRY8dEtfuQ21P/pTSWzojkBBLCIxRM00va2ueE1AvMB5iJVw/0gCax7FZ0fSfVL0fhMps2uUu1e4Hro2AopwzGVzjug2rYpHviXQEOpX4/QJqyhDrs37vITA1yPjPguCHbB4YqOrgqM9ik2UDb1ouJ0NCj8jADzF8St6VajW9U64KZflE/7sppgSKGxcyAfsKnwIDAQAB";
					bindURL = "com.android.vending.billing.InAppBillingService.BIND";
					packageURL = "com.android.vending";
					break;
				
				case "myket":
					base64Key = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCfyHCc9OS523q+g7p/Deo3EVu89t0O2x5jjNqM74ojc1UfrXLsETjMcmS6FAtDYhL5gZT6fWkMe7Vx2sKKeFP1mdops4xLK4cQURMd5f7WqRls9cMiaitdnEV6x1kIr/VrS1ieypH9NqtF739LOyptXERLuY/GWgEnU30x7nj4swIDAQAB";
					bindURL = "ir.mservices.market.InAppBillingService.BIND";
					packageURL = "ir.mservices.market";
					break;
				
				case "cando":
					base64Key = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCC3hfXAyBj1bnrlNilrtdW4U1qkI8FP27usDKinH9w/XQddtbyn/yY+Qpgi9rZqGEiy8g7jqZr6YZAM3hJCB4V6dvZPwdHmF2AgtbQJQGYbk4lfhfzQl+UGUtsRJtiaPoJZ7ZTYFlqlAz0tRR83w5y0NdkHyqnaJYyOBvI9jgmXwIDAQAB";
					bindURL = "com.ada.market.service.payment.BIND";
					packageURL = "com.ada.market";
					break;
				
				default://cafebazaar
					base64Key = "MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwDBF2CttLWeUoUQG+KcbDAxqB4JqYvOn/pd2bNiPNFJXmVkw2RzkgLEomhFM/phWseg+SVe4bHM7TQg++1gvLpnfzr2onbdcYdWDllDhbQQFXXEtW+h8WdeQDFB6LCc+nUBcrJh7B5c99acShSTnENuuiRMbz2xR9nnDivlleu4XO3peTq1e4qoXewE/meloWuCNnPkc8fWDOm87zKFDRHLwlIQ3vJGUlpnFxXFd3cCAwEAAQ==";
					bindURL = "ir.cafebazaar.pardakht.InAppBillingService.BIND";
					packageURL = "com.farsitel.bazaar";
					break;
				
			}			

			_iap = new InAppPurchase();
			_iap.addEventListener(InAppPurchaseEvent.INIT_SUCCESS, iap_initSuccessHandler);
			_iap.addEventListener(InAppPurchaseEvent.INIT_ERROR, iap_initErrorHandler);
			if(AppModel.instance.platform == AppModel.PLATFORM_ANDROID)
				_iap.init(base64Key, bindURL, packageURL);
		}
		protected function iap_initSuccessHandler(event:InAppPurchaseEvent):void
		{
			_iap.removeEventListener(InAppPurchaseEvent.INIT_SUCCESS, iap_initSuccessHandler);
			_iap.removeEventListener(InAppPurchaseEvent.INIT_ERROR, iap_initErrorHandler);
			inited = true;
			trace("iap_initSuccessHandler(event)", event.data);
			restore();
			dispatchEventWith(FeathersEventType.INITIALIZE);
		}
		protected function iap_initErrorHandler(event:InAppPurchaseEvent):void
		{
			_iap.removeEventListener(InAppPurchaseEvent.INIT_SUCCESS, iap_initSuccessHandler);
			_iap.removeEventListener(InAppPurchaseEvent.INIT_ERROR, iap_initErrorHandler);
			trace("iap_initErrorHandler(event)", event.data);
			dispatchEventWith(FeathersEventType.INITIALIZE);
		}

		// -_-_-_-_-_-_-_-_-_-_-_-_-_-_- PURCHASE-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
		/**Getting purchased product details, _iap should be initialized first</br>
		 * if put items args getting purchased and not purchased product details
		 */
		public function restore(items:Array=null, subs:Array=null, retryPurchase:String=null):void
		{
			if(!inited)
			{
				dispatchEventWith(FeathersEventType.END_INTERACTION);
				explain("popup_purchase_not_initialized");
				//lostMarket();
				return;
			}
			this.retryPurchase = retryPurchase;
			_iap.addEventListener(InAppPurchaseEvent.RESTORE_SUCCESS, iap_restoreSuccessHandler);
			_iap.addEventListener(InAppPurchaseEvent.RESTORE_ERROR, iap_restoreErrorHandler);
			_iap.restore(items, subs); //restoring purchased in-app items and subscriptions
		}
		protected function iap_restoreSuccessHandler(event:InAppPurchaseEvent):void
		{
			_iap.removeEventListener(InAppPurchaseEvent.RESTORE_SUCCESS, iap_restoreSuccessHandler);
			_iap.removeEventListener(InAppPurchaseEvent.RESTORE_ERROR, iap_restoreErrorHandler);
			loadDetails();
			if(retryPurchase != null)
			{
				purchase(retryPurchase);
				retryPurchase = null;
			}
			trace("iap_restoreSuccessHandler", event.data);
		}
		protected function iap_restoreErrorHandler(event:InAppPurchaseEvent):void
		{
			_iap.removeEventListener(InAppPurchaseEvent.RESTORE_SUCCESS, iap_restoreSuccessHandler);
			_iap.removeEventListener(InAppPurchaseEvent.RESTORE_ERROR, iap_restoreErrorHandler);
			trace("iap_restoreErrorHandler", event.data);
		}			
		
		// -_-_-_-_-_-_-_-_-_-_-_-_-_-_- PURCHASE-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
		/**
		 * Making the purchase, _iap should be initialized first 
		 */
		public function purchase(sku:String=null):void
		{
			if(!inited)
			{
				dispatchEventWith(FeathersEventType.END_INTERACTION);
				explain("popup_purchase_not_initialized");
				//lostMarket();
				return;
			}
			trace(inited, "purchase => sku:", sku);
			_iap.addEventListener(InAppPurchaseEvent.PURCHASE_ALREADY_OWNED, iap_purchaseSuccessHandler);
			_iap.addEventListener(InAppPurchaseEvent.PURCHASE_SUCCESS, iap_purchaseSuccessHandler);
			_iap.addEventListener(InAppPurchaseEvent.PURCHASE_ERROR, iap_purchaseErrorHandler);
			_iap.purchase(sku, InAppPurchaseDetails.TYPE_INAPP);
		}
		
		protected function iap_purchaseSuccessHandler(event:InAppPurchaseEvent):void
		{
			_iap.removeEventListener(InAppPurchaseEvent.PURCHASE_ALREADY_OWNED, iap_purchaseSuccessHandler);
			_iap.removeEventListener(InAppPurchaseEvent.PURCHASE_SUCCESS, iap_purchaseSuccessHandler);
			_iap.removeEventListener(InAppPurchaseEvent.PURCHASE_ERROR, iap_purchaseErrorHandler);

			//restore([event.data]);
			purchaseDetails = _iap.getPurchaseDetails(event.data);
			skuDetails = _iap.getSkuDetails(event.data);
			if(purchaseDetails != null)
			{
				AppModel.instance.navigator.addLog(ResourceManager.getInstance().getString("loc", "waiting_message"));
				/* ------------ PURCHASE VERIFICATION AND CONSUMPTION -----------*/
				var param:SFSObject = new SFSObject();
				param.putText("productID", purchaseDetails._sku);
				param.putText("purchaseToken", purchaseDetails._token);
				SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_purchaseVerifyHandler);
				SFSConnection.instance.sendExtensionRequest(SFSCommands.VERIFY_PURCHASE, param);
				function sfsConnection_purchaseVerifyHandler(event:SFSEvent):void {
					if(event.params.cmd != SFSCommands.VERIFY_PURCHASE)
						return;
					SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_purchaseVerifyHandler);
					var result:SFSObject = event.params.params;
					trace(result.getDump());
					if (result.getBool("success") && result.getInt("consumptionState") == 1)
						consume(purchaseDetails._sku);
					else
						explain("popup_purchase_invalid");
				}
			}
			else
			{
				if(retryPurchase == null)
					restore(null, null, event.data);
			}
			trace("iap_purchaseSuccessHandler", event.data); //product id
		}
		
		private function explain(message:String):void
		{
			var popup:MessagePopup = new MessagePopup(ResourceManager.getInstance().getString("loc", message));
			AppModel.instance.navigator.addPopup(popup);
		}
		protected function iap_purchaseErrorHandler(event:InAppPurchaseEvent):void
		{
			_iap.removeEventListener(InAppPurchaseEvent.PURCHASE_ALREADY_OWNED, iap_purchaseSuccessHandler);
			_iap.removeEventListener(InAppPurchaseEvent.PURCHASE_SUCCESS, iap_purchaseSuccessHandler);
			_iap.removeEventListener(InAppPurchaseEvent.PURCHASE_ERROR, iap_purchaseErrorHandler);
			explain("popup_purchase_error");
			trace("iap_purchaseErrorHandler", event.data);
			dispatchEventWith(FeathersEventType.END_INTERACTION, false, purchaseDetails);
		}

		// -_-_-_-_-_-_-_-_-_-_-_-_-_-_- CONSUMING PURCHASED ITEM -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
		public function consume(sku:String=null):void
		{
			if(!inited)
			{
				dispatchEventWith(FeathersEventType.END_INTERACTION);
				explain("popup_purchase_not_initialized");
				//lostMarket();
				return;
			}
			trace("consume", sku); 
			_iap.addEventListener(InAppPurchaseEvent.CONSUME_SUCCESS, iap_consumeSuccessHandler);
			_iap.addEventListener(InAppPurchaseEvent.CONSUME_ERROR, iap_consumeErrorHandler);
			_iap.consume(sku);
		}
		
		protected function iap_consumeSuccessHandler(event:InAppPurchaseEvent):void
		{
			_iap.removeEventListener(InAppPurchaseEvent.CONSUME_SUCCESS, iap_consumeSuccessHandler);
			_iap.removeEventListener(InAppPurchaseEvent.CONSUME_ERROR, iap_consumeErrorHandler);
			
			var exchanger:Exchanger = AppModel.instance.game.exchanger;
			
			var sku:String = event.data;
			var item:ExchangeItem = exchanger.items.get(int(sku.substr(sku.length-1))); // reterive exchange item key
			exchanger.exchange(item, 0);
			restore();
			
			var priceList:Array = skuDetails._price.split(" ");
			var price:String = priceList[0];
			var currency:String = priceList[1];
			price = price.split('٬').join('');
			if( currency == "ریال" )
				currency = "IRR";;
			price = StrUtils.getLatinNumber(price);
			trace(int(price), currency)
			//GameAnalytics.addBusinessEvent("USD", 1000, "item", "id", "cart", "[receipt]", "[signature]");
			
			dispatchEventWith(FeathersEventType.END_INTERACTION, false, purchaseDetails);
			
			
			
			trace("iap_consumeSuccessHandler", event.data);
		}
		protected function iap_consumeErrorHandler(event:InAppPurchaseEvent):void
		{
			_iap.removeEventListener(InAppPurchaseEvent.CONSUME_SUCCESS, iap_consumeSuccessHandler);
			_iap.removeEventListener(InAppPurchaseEvent.CONSUME_ERROR, iap_consumeErrorHandler);
			trace("iap_consumeErrorHandler", event.data);
		}
		
		
		// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- LOAD DETAILS -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
		private function loadDetails():void
		{
			//getting details of purchase and skus: time, etc.
			purchases = new Vector.<InAppPurchaseDetails>();
			skus = new Vector.<InAppSkuDetails>();
			
			var purchase:InAppPurchaseDetails;
			var sku:InAppSkuDetails;
			
			for(var s:String in items)
			{
				purchase = _iap.getPurchaseDetails(s);
				if(purchase!=null)
					purchases.push(purchase);
				
				sku = _iap.getSkuDetails(s);
				if(sku!=null)
					skus.push(sku);
			}
			trace("purchases:", purchases, "skus:", skus);
		}
		
		
	/*	private function lostMarket():void
		{
			NativeAbilities.instance.showToast(ResourceManager.getInstance().getString("loc", "purchase_lost"), 1);
			init();
		}*/
		
		// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- RATING -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
		public function rate():void
		{
			UserData.instance.rated = true;
			UserData.instance.save();
			switch(AppModel.instance.descriptor.market)
			{
				case "google":
					navigateToURL(new URLRequest("https://play.google.com/store/apps/details?id=air." + AppModel.instance.descriptor.id));
					break;
				
				case "cafebazaar":
					NativeAbilities.instance.runIntent("android.intent.action.EDIT", "bazaar://details?id=air." + AppModel.instance.descriptor.id);
					break;
				
				case "myket":
					navigateToURL(new URLRequest("http://myket.ir/App/air." + AppModel.instance.descriptor.id));
					break;
				
				case "cando":
					navigateToURL(new URLRequest("cando://leave-review?id=air." + AppModel.instance.descriptor.id));
					break;
			}			
		}
		
		// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- GET DOWNLOAD URL -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
		public function getDownloadURL():String
		{
			switch(AppModel.instance.descriptor.market)
			{
				case "google":		return 'https://play.google.com/store/apps/details?id=air.' + AppModel.instance.descriptor.id;			
				case "cafebazaar":	return 'https://cafebazaar.ir/app/air.' + AppModel.instance.descriptor.id;			
				case "myket":		return 'http://myket.ir/App/air.' + AppModel.instance.descriptor.id;
				case "cando":		return 'cando://details?id=air.'+AppModel.instance.descriptor.id;			
			}
			return "http://towers.grantech.ir/get/towerstory.apk";
		}
		
		// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- SHARING -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
		public function share():void
		{
			NativeAbilities.instance.shareText(ResourceManager.getInstance().getString("loc", "app_title"), ResourceManager.getInstance().getString("loc", "app_brief") + "\n" + getDownloadURL());
		}
	}
}