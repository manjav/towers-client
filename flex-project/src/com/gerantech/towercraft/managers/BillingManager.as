package com.gerantech.towercraft.managers
{
	import com.gerantech.extensions.NativeAbilities;
	import com.gerantech.extensions.events.AndroidEvent;
	import com.gerantech.islamic.models.AppModel;
	import com.gerantech.islamic.models.UserModel;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.vo.UserData;
	import com.pozirk.payment.android.InAppPurchase;
	import com.pozirk.payment.android.InAppPurchaseDetails;
	import com.pozirk.payment.android.InAppPurchaseEvent;
	import com.pozirk.payment.android.InAppSkuDetails;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.resources.ResourceManager;
	
	public class BillingManager
	{
		private var _iap:InAppPurchase;
			
		private static var _instance:BillingManager;
		private var inited:Boolean;
		
		//public var premium:String = "air.com.gerantech.islamic.premium"
		
		public static function get instance():BillingManager
		{
			if(_instance == null)
				_instance = new BillingManager();
			return (_instance);
		}

		
		public function BillingManager(){}
		
		public function init():void
		{
			var base64Key:String, bindURL:String, packageURL:String;
			switch(AppModel.instance.descriptor.market)
			{
				case "google":
					base64Key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuML2Gtw7jaO2bO1/JqtnvIIMH04IdQ/nX89tPz/Q9ltm3JyILgvSJJL36cmRqfvsHD4pXPuIu14cb/+iRVuSodASgtGpPCmv21l6wXT++VEED5TdWJCNZoyOnwt3iGWdpoUQNqpqj0hn46O7mmJdRY8dEtfuQ21P/pTSWzojkBBLCIxRM00va2ueE1AvMB5iJVw/0gCax7FZ0fSfVL0fhMps2uUu1e4Hro2AopwzGVzjug2rYpHviXQEOpX4/QJqyhDrs37vITA1yPjPguCHbB4YqOrgqM9ik2UDb1ouJ0NCj8jADzF8St6VajW9U64KZflE/7sppgSKGxcyAfsKnwIDAQAB";
					bindURL = "com.android.vending.billing.InAppBillingService.BIND";
					packageURL = "com.android.vending";
					break;
				
				case "cafebazaar":
					base64Key = "MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwDNYE/Gp6vrAVhSRF/s/kixANnXtuCFkJbfLzVbwYimNlTw5bzben5xiSAb1aQtG3pDwT238aLnPBnqSAOhAQOryT5rC9w3BXloftI3Kgt+8ERKkG/BJyv/8u0KCVm9v3PqdbdAnacsfMMGyhT4zozGW8PxTh2AX1o8AagoqPkgOlUUYQ8COSFGNO9IftYb3Mq8kzG26t4oaYoxPV/m2VPQhfjJbWSX5Crn6FxvVDECAwEAAQ==";
					bindURL = "ir.cafebazaar.pardakht.InAppBillingService.BIND";
					packageURL = "com.farsitel.bazaar";
					break;
				
				case "myket":
					base64Key = "MIGeMA0GCSqGSIb3DQEBAQUAA4GMADCBiAKBgLrZzgFzF3P/4iYbG+kI/OseAo4pmfmvwgGjDLZFUFu7d5SZKBj5hGPOUg5Mu1Q8wEaj9LvI9jlybZkjpYmCn7ljCxbQ/QaCMwbNfp4gyF7EgEWOVeudzXNCXlhEoDSb1z63aNsD2opf294Cu64BzqLNQ+rlp0yW2YwjNiMU2O2/AgMBAAE=";
					//base64Key = "MIGeMA0GCSqGSIb3DQEBAQUAA4GMADCBiAKBgJMpfaXOx6tVOeg4RE63Z8GVqOiT8MigKw42dcTfwKuzo9n8vjjBtLX5XSatS0bsnkfBuNIq/w+FsXYFrHpU5TA/C0OMKBAr8BxCURX4LlYosQrXCBGzdKpGm242h+Oyco0Z9phXNs3jxBSe1qj9SKzofWObgPAUlUOjGL3gpfUZAgMBAAE=";
					bindURL = "ir.mservices.market.InAppBillingService.BIND";
					packageURL = "ir.mservices.market";
					break;
				
				case "cando":
					base64Key = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCC3hfXAyBj1bnrlNilrtdW4U1qkI8FP27usDKinH9w/XQddtbyn/yY+Qpgi9rZqGEiy8g7jqZr6YZAM3hJCB4V6dvZPwdHmF2AgtbQJQGYbk4lfhfzQl+UGUtsRJtiaPoJZ7ZTYFlqlAz0tRR83w5y0NdkHyqnaJYyOBvI9jgmXwIDAQAB";
					bindURL = "com.ada.market.service.payment.BIND";
					packageURL = "com.ada.market";
					break;
			}			

			_iap = new InAppPurchase();
			_iap.addEventListener(InAppPurchaseEvent.INIT_SUCCESS, onInitSuccess);
			_iap.addEventListener(InAppPurchaseEvent.INIT_ERROR, onInitError);
			if(AppModel.instance.platform == AppModel.PLATFORM_ANDROID)
				_iap.init(base64Key, bindURL, packageURL);
		}

		protected function onInitSuccess(event:InAppPurchaseEvent):void
		{
			inited = true;
		//	NativeAbilities.instance.showToast("Billing_extension_test.onInitSuccess", 1)
			restore();
			trace("Billing_extension_test.onInitSuccess(event)", event.data);
		}
		protected function onInitError(event:InAppPurchaseEvent):void
		{
			trace("Billing_extension_test.onInitError(event)", event.data);
		}
		
		//> making the purchase, _iap should be initialized first ---------------------------------------------------------------------
		public function purchase(sku:String=null):void
		{
//			if(sku==null)
//				sku = premium;
			
			if(!inited)
			{
				lostMarket();
				return;
			}
			_iap.addEventListener(InAppPurchaseEvent.PURCHASE_SUCCESS, onPurchaseSuccess);
			_iap.addEventListener(InAppPurchaseEvent.PURCHASE_ALREADY_OWNED, onPurchaseSuccess);
			_iap.addEventListener(InAppPurchaseEvent.PURCHASE_ERROR, onPurchaseError);
			_iap.purchase(sku, InAppPurchaseDetails.TYPE_INAPP);
		}
		
		protected function onPurchaseSuccess(event:InAppPurchaseEvent):void
		{
			_iap.addEventListener(InAppPurchaseEvent.RESTORE_SUCCESS, onRestoreSuccess);
			_iap.addEventListener(InAppPurchaseEvent.RESTORE_ERROR, onRestoreError);
			_iap.restore([event.data]);

			
			/* ------------ PURCHASE VERIFICATION EXAMPLE -----------
			sfsConnection.addEventListener(SFSEvent.EXTENSION_RESPONSE, adfs);
			var param:SFSObject = new SFSObject();
			param.putText("productID", "coin_pack_03");
			param.putText("purchaseToken", "SDu10PZdud5JoToeZa");
			sfsConnection.sendExtensionRequest("verify", param);
			function adfs(event:SFSEvent):void {
			trace(event.params);
			}*/		
			
			trace("onPurchaseSuccess", event.data); //product id
		}
		protected function onPurchaseError(event:InAppPurchaseEvent):void
		{
			trace("onPurchaseError", event.data); //trace error message
		}
			
		private function lostMarket():void
		{
			NativeAbilities.instance.showToast(ResourceManager.getInstance().getString("loc", "purchase_lost"), 1);
			init();
		}

			
		//> getting purchased product details, _iap should be initialized first --------------------------------------------------
		public function restore():void
		{
			if(!inited)
			{
				lostMarket();
				return;
			}
			_iap.addEventListener(InAppPurchaseEvent.RESTORE_SUCCESS, onRestoreSuccess);
			_iap.addEventListener(InAppPurchaseEvent.RESTORE_ERROR, onRestoreError);
			_iap.restore([premium]); //restoring purchased in-app items and subscriptions
		}
		
		protected function onRestoreSuccess(event:InAppPurchaseEvent):void
		{
			//getting details of purchase: time, etc.
			var premiumPurchase:InAppPurchaseDetails = _iap.getPurchaseDetails(premium);
			if(premiumPurchase)
			{
				//NativeAbilities.instance.showToast("Restore premium "+ premiumPurchase._json, 1);
				//UserModel.instance.premiumMode = true;
				
			}
			trace("onRestoreSuccess", premiumPurchase); //product id
		}
		protected function onRestoreError(event:InAppPurchaseEvent):void
		{
			//NativeAbilities.instance.showToast("onRestoreError", 1)
			trace("onRestoreError", event.data); //trace error message
		}
	
		//> getting purchased and not purchased product details ----------------------------------------------------------------------
		public function restoreAll():void
		{
			if(!inited)
			{
				NativeAbilities.instance.showToast(ResourceManager.getInstance().getString("loc", "purchase_lost"), 1);
				return;
			}
			_iap.addEventListener(InAppPurchaseEvent.RESTORE_SUCCESS, onRestoreAllSuccess);
			_iap.addEventListener(InAppPurchaseEvent.RESTORE_ERROR, onRestoreError);
			
			var items:Array = ["my.product.id1", "my.product.id2", "my.product.id3"];
			
			var subs:Array = ["my.subs.id1", "my.subs.id2", "my.subs.id3"];
			_iap.restore(items, subs); //restoring purchased + not purchased in-app items and subscriptions
		}
		
		protected function onRestoreAllSuccess(event:InAppPurchaseEvent):void
		{
			//getting details of product: time, etc.
			var skuDetails1:InAppSkuDetails = _iap.getSkuDetails("my.product.id1");
			
			//getting details of product: time, etc.
			var skuDetails2:InAppSkuDetails = _iap.getSkuDetails("my.subs.id1");
			
			//getting details of purchase: time, etc.
			var purchase:InAppPurchaseDetails = _iap.getPurchaseDetails(premium);
		}
		
		//> consuming purchased item ------------------------------------------------------------------------------------------
		public function consume(sku:String=null):void
		{
			if(sku==null)
				sku = premium;
			if(!inited)
			{
				lostMarket();
				return;
			}
			_iap.addEventListener(InAppPurchaseEvent.CONSUME_SUCCESS, onConsumeSuccess);
			_iap.addEventListener(InAppPurchaseEvent.CONSUME_ERROR, onConsumeError);
			_iap.consume(sku);
		}
		
		protected function onConsumeSuccess(event:InAppPurchaseEvent):void
		{
			trace(event.data); //trace error message				
		}
		protected function onConsumeError(event:InAppPurchaseEvent):void
		{
			trace(event.data); //trace error message				
		}		
		
		public function rate():void
		{
			UserData.getInstance().rated = true;
			switch(AppModel.instance.descriptor.market)
			{
				case "google":
					navigateToURL(new URLRequest("https://play.google.com/store/apps/details?id=air."+AppModel.instance.descriptor.id));
					break;
				
				case "cafebazaar":
					NativeAbilities.instance.runIntent("android.intent.action.EDIT", "bazaar://details?id=air."+AppModel.instance.descriptor.id);
					break;
				
				case "myket":
					navigateToURL(new URLRequest("http://myket.ir/App/air.com.gerantech.islamic/%D9%86%D8%B1%D9%85-%D8%A7%D9%81%D8%B2%D8%A7%D8%B1-%D8%A7%D8%B3%D9%84%D8%A7%D9%85%DB%8C-%D9%87%D8%AF%D8%A7%DB%8C%D8%AA"));
					break;
				
				case "cando":
					navigateToURL(new URLRequest("cando://leave-review?id=air."+AppModel.instance.descriptor.id));
					break;
			}			
		}
		
		public function share():void
		{
			var link:String;
			switch(AppModel.instance.descriptor.market)
			{
				case "google":
					//link = '<a href="https://play.google.com/store/apps/details?id=air.'+AppModel.instance.descriptor.id+'">'+ResourceManager.getInstance().getString("loc", "download_link")+'</a>';			
					link = 'https://play.google.com/store/apps/details?id=air.'+AppModel.instance.descriptor.id;			
					break;
				
				case "cafebazaar":
				//	link = '<a href="bazaar://details?id=air.'+AppModel.instance.descriptor.id+'">'+ResourceManager.getInstance().getString("loc", "download_link")+'</a>';			
					link = 'https://cafebazaar.ir/app/air.'+AppModel.instance.descriptor.id;			
					break;
				
				case "myket":
				//	link = '<a href="http://myket.ir/App/air.com.gerantech.islamic/%D9%86%D8%B1%D9%85-%D8%A7%D9%81%D8%B2%D8%A7%D8%B1-%D8%A7%D8%B3%D9%84%D8%A7%D9%85%DB%8C-%D9%87%D8%AF%D8%A7%DB%8C%D8%AA">'+ResourceManager.getInstance().getString("loc", "download_link")+'</a>';			
					link = 'http://myket.ir/App/air.com.gerantech.islamic/%D9%86%D8%B1%D9%85-%D8%A7%D9%81%D8%B2%D8%A7%D8%B1-%D8%A7%D8%B3%D9%84%D8%A7%D9%85%DB%8C-%D9%87%D8%AF%D8%A7%DB%8C%D8%AA';			
					break;
				
				case "cando":
				//	link = '<a href="cando://details?id=air.'+AppModel.instance.descriptor.id+'">'+ResourceManager.getInstance().getString("loc", "download_link")+'</a>';			
					link = 'cando://details?id=air.'+AppModel.instance.descriptor.id;			
					break;
			}			
			NativeAbilities.instance.shareText(ResourceManager.getInstance().getString("loc", "app_title"), ResourceManager.getInstance().getString("loc", "app_descript")+"\n"+link);
		}
	}
}