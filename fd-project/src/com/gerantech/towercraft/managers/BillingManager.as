package com.gerantech.towercraft.managers
{
import com.gerantech.extensions.NativeAbilities;
import com.gerantech.extensions.iab.Iab;
import com.gerantech.extensions.iab.Purchase;
import com.gerantech.extensions.iab.events.IabEvent;
import com.gerantech.towercraft.controls.popups.MessagePopup;
import com.gerantech.towercraft.events.LoadingEvent;
import com.gerantech.towercraft.managers.net.LoadingManager;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import com.zarinpal.ZarinPal;
import com.zarinpal.ZarinpalGatewayRequest;
import com.zarinpal.events.ZarinpalRequestEvent;
import com.zarinpal.inventory.ZarinpalStockItem;
import feathers.events.FeathersEventType;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import mx.resources.ResourceManager;
import com.gt.towers.exchanges.Exchanger;




public class BillingManager extends BaseManager
{
private var items:Array;
private static var _instance:BillingManager;
public static function get instance():BillingManager
{
	if( _instance == null )
		_instance = new BillingManager();
	return (_instance);
}

public function BillingManager(){}
protected function loadingManager_loadedHandler(event:LoadingEvent):void
{
	appModel.loadingManager.removeEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
	init();
}		
public function init():void
{
	if( appModel.loadingManager.state < LoadingManager.STATE_LOADED )
	{
		appModel.loadingManager.addEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
		return;
	}
	
	// provide all sku items
	items = new Array("com.grantech.towers.item_0");
	var keys:Vector.<int> = exchanger.items.keys();
	for each(var k:int in keys)
		if( ExchangeType.getCategory(k) == ExchangeType.C0_HARD )
			items.push("com.grantech.towers.item_" + k);
		else if( ExchangeType.getCategory(k) == ExchangeType.C30_BUNDLES )
			items.push("towres.bundle_" + k);

	var base64Key:String, bindURL:String, packageURL:String;
	switch( appModel.descriptor.market )
	{
		case "google":
			base64Key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuBhhd2cIGxyfSAM1Vnv1qLtlmN25UD1KhXpvy8S8JrOIssw6sSoJXBfu8oWWi2VaQ6OPZJifiWKzV3E8+6mxCXn4u+GiO3v1F3zlhhbEPDuKxHu+cnEA3yCQy3w6HLe8f60+85I7VoGsgkEOu0E5fIJ1f5udp209gbi0DrajuTiC5cH4bZNSpDTpE2YE2T4rvsM4nVvN38PNE+xExsNtemm6QGbu9A5x9nWZrGP5dLNT6CSVuu8zdddHGkGCxOzvHekZ/Zsg3ZO9VvNp2n64puKiiCRul5U821iwl5k060CO1glHWrxwoFCWiZwyjnNKYggGBaaIw3m+amh2xp7eNwIDAQAB";
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
		
		case "ario":
			base64Key = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC1FSvYe0mDDFAnk8SHSMLFxaaQF9MvObuQ8U9tWf4uE0OT8erPKhgUR7cqOF74TXAYlrSwbyTC/nHgqURLRX7C0iFFT1/j9BpMKxNULb/CqulNaJg6AEfQbwTcwIfVzS04dUPhjhR9MdRICfiZkMzWesWfyE4Dfre+p5vt0qC0MQIDAQAB";
			bindURL = "com.arioclub.android.sdk.iab.InAppBillingService.BIND";
			packageURL = "com.arioclub.android";
			break;
		
		case "zarinpal":
			base64Key = "b37e90ce-b2bc-11e9-832c-000c29344814";
			bindURL = "towers://zarinpal";
			break;

		default://cafebazaar
			base64Key = "MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwDBF2CttLWeUoUQG+KcbDAxqB4JqYvOn/pd2bNiPNFJXmVkw2RzkgLEomhFM/phWseg+SVe4bHM7TQg++1gvLpnfzr2onbdcYdWDllDhbQQFXXEtW+h8WdeQDFB6LCc+nUBcrJh7B5c99acShSTnENuuiRMbz2xR9nnDivlleu4XO3peTq1e4qoXewE/meloWuCNnPkc8fWDOm87zKFDRHLwlIQ3vJGUlpnFxXFd3cCAwEAAQ==";
			bindURL = "ir.cafebazaar.pardakht.InAppBillingService.BIND";
			packageURL = "com.farsitel.bazaar";
			break;
	}

	if(appModel.descriptor.market == "zarinpal")
	{
		ZarinPal.instance.addEventListener(ZarinpalRequestEvent.INITIALIZE_FINISHED, zarinpal_initializeFinishedHandler);
		ZarinPal.instance.initialize(base64Key, bindURL, "", "");
		return;
	}		

	Iab.instance.addEventListener(IabEvent.SETUP_FINISHED, iab_setupFinishedHandler);
	Iab.instance.startSetup(base64Key, bindURL, packageURL);
}
protected function iab_setupFinishedHandler(event:IabEvent):void
{
	log("setup: " + event.result.response);
	Iab.instance.removeEventListener(IabEvent.SETUP_FINISHED, iab_setupFinishedHandler);
	dispatchEventWith(FeathersEventType.INITIALIZE);
	if( event.result.succeed )
		queryInventory();
}

protected function zarinpal_initializeFinishedHandler(event:ZarinpalRequestEvent):void
{
	ZarinPal.instance.removeEventListener(ZarinpalRequestEvent.INITIALIZE_FINISHED, zarinpal_initializeFinishedHandler);
	var keys:Vector.<int> = exchanger.items.keys();
	for each(var k:int in keys)
	{
		var exchangeItem:ExchangeItem = exchanger.items.get(k);
		if( ExchangeType.getCategory(k) == ExchangeType.C0_HARD )
			ZarinPal.instance.inventory.add("com.grantech.towers.item_" + k, loc("exchange_title_" + k), exchangeItem.requirements._map["h"][ResourceType.R5_CURRENCY_REAL], exchangeItem.outcomes._map["h"][ResourceType.R4_CURRENCY_HARD]);
		else if( ExchangeType.getCategory(k) == ExchangeType.C30_BUNDLES )
			ZarinPal.instance.inventory.add("towres.bundle_" + k, loc("exchange_title_" + k), exchangeItem.requirements._map["h"][ResourceType.R5_CURRENCY_REAL], exchangeItem.outcomes._map["h"][ResourceType.R4_CURRENCY_HARD]);
	}
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_- QUERY INVENTORY -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
/**Getting purchased product details, _iap should be initialized first</br>
 * if put items args getting purchased and not purchased product details
 */
public function queryInventory():void
{
	Iab.instance.addEventListener(IabEvent.QUERY_INVENTORY_FINISHED, iab_queryInventoryFinishedHandler);
	Iab.instance.queryInventory(); //restoring purchased in-app items and subscriptions
}

protected function iab_queryInventoryFinishedHandler(event:IabEvent):void
{
	log("queryInventory: " + event.result.response);
	if( !event.result.succeed )
	{
		dispatchEventWith(FeathersEventType.END_INTERACTION, false, event.result);
		return;
	}
	Iab.instance.removeEventListener(IabEvent.QUERY_INVENTORY_FINISHED, iab_queryInventoryFinishedHandler);
	
	// verify and consume all remaining items
	for each( var k:String in items )
	{
		var purchase:Purchase = Iab.instance.getPurchase(k);
		if( purchase == null || purchase.itemType == Iab.ITEM_TYPE_SUBS )
			continue;
		var param:SFSObject = new SFSObject();
		param.putText("productID", purchase.sku);
		param.putText("purchaseToken", purchase.token);
		verify(param);
	}
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_- PURCHASE -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
public function purchase(sku:String):void
{
	if(appModel.descriptor.market == "zarinpal")
	{
		var useZarinGate:Boolean = true;
		var gatewayRequest:ZarinpalGatewayRequest = new ZarinpalGatewayRequest(useZarinGate);
		gatewayRequest.addEventListener(ZarinpalRequestEvent.PAYMENT_REQUEST_RESPONSE_RECIEVED, gatewayRequest_responseRecievedHandler);
		var item:ZarinpalStockItem = ZarinPal.instance.inventory.getItem(sku);
		gatewayRequest.createRequest(item.sku, item.description, item.amount);
		appModel.navigator.addLog(loc("waiting_message"));
		gatewayRequest.send();
		function gatewayRequest_responseRecievedHandler(e:ZarinpalRequestEvent):void
		{
			var sku:String = e.response["ProductID"];
			var authCode:String = e.response["Authority"];
			var urlRequest:URLRequest = new URLRequest(gatewayRequest.getGatewayUrl(authCode));
			navigateToURL(urlRequest);
		}
	}
	else
	{
		Iab.instance.addEventListener(IabEvent.PURCHASE_FINISHED, iab_purchaseFinishedHandler);
		Iab.instance.purchase(sku);
	}
}

protected function iab_purchaseFinishedHandler(event:IabEvent):void
{
	log("purchase: " + event.result.response);
	Iab.instance.removeEventListener(IabEvent.PURCHASE_FINISHED, iab_purchaseFinishedHandler);
	if( !event.result.succeed )
	{
		explain(event.result.response);
		dispatchEventWith(FeathersEventType.END_INTERACTION, false, event.result);
		return;
	}
	var purchase:Purchase = Iab.instance.getPurchase(event.result.purchase.sku);
	if ( purchase != null )
	{
		var param:SFSObject = new SFSObject();
		param.putText("productID", purchase.sku);
		param.putText("purchaseToken", purchase.token);
		verify(param);
	}
	else
		queryInventory();
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_- PURCHASE VERIFICATION AND CONSUMPTION -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
public function verify(purchase:ISFSObject):void
{
	appModel.navigator.addLog(ResourceManager.getInstance().getString("loc", "waiting_message"));
	var param:SFSObject = new SFSObject();
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_purchaseVerifyHandler);
	if(appModel.descriptor.market == "zarinpal")
	{
		SFSConnection.instance.sendExtensionRequest(SFSCommands.VERIFY_PURCHASE, purchase as ISFSObject);
	}
	else
	{
		param.putText("productID", purchase.getText("productID"));
		param.putText("purchaseToken", purchase.getText("purchaseToken"));
		SFSConnection.instance.sendExtensionRequest(SFSCommands.VERIFY_PURCHASE, param);
	}
	function sfsConnection_purchaseVerifyHandler(event:SFSEvent):void
	{
		if( event.params.cmd != SFSCommands.VERIFY_PURCHASE )
			return;
		SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_purchaseVerifyHandler);
		var result:SFSObject = event.params.params;
		if( result.getBool("success") )
		{
			if ( appModel.descriptor.market == "zarinpal" )
			{
				/**
				 * No consume method for zarinpal.
				 */
				var productID:int = int( result.getText("productID").split("_")[1] );
				var item:ExchangeItem = exchanger.items.get(productID);
				
				var params:SFSObject = new SFSObject();
				params.putInt("type", item.type)
				params.putInt("hards", Exchanger.timeToHard(ExchangeType.getCooldown(item.outcome)));
				ExchangeManager.instance.exchange(item, params);
				
				item.enabled = true;
				// Dispatch event directly to exchange manager cause we might have lost
				// the process.
				ExchangeManager.instance.dispatchEventWith(FeathersEventType.END_INTERACTION, false, item);
				// false sucess cause we already dispatched end interaction.
				// dispatchEventWith(FeathersEventType.END_INTERACTION, false, {succeed: false});
			}
			else if( appModel.descriptor.market == "cafebazaar" || appModel.descriptor.market == "ario" )
			{
				if(  result.getInt("consumptionState") == 1 ){
					consume(result.getText("productID"));
				}
			}
			else
			{
				if(  result.getInt("consumptionState") == 0 )
					consume(result.getText("productID"));
			}
		}
		else
		{
			log("purchase verify=>invalid: " + result.getText("productID"));
			explain(Iab.IABHELPER_VERIFICATION_FAILED);
		}
	}	
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_- CONSUMING PURCHASED ITEM -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
public function consume(sku:String):void
{
	Iab.instance.addEventListener(IabEvent.CONSUME_FINISHED, iab_consumeFinishedHandler);
	Iab.instance.consume(sku);
}
protected function iab_consumeFinishedHandler(event:IabEvent):void
{			
	log("queryInventory: " + event.result.response);
	Iab.instance.removeEventListener(IabEvent.CONSUME_FINISHED, iab_consumeFinishedHandler);
	if( !event.result.succeed )
	{
		explain(Iab.IABHELPER_INVALID_CONSUMPTION);
		dispatchEventWith(FeathersEventType.END_INTERACTION, false, event.result);
		return;
	}
	
	/*var priceList:Array = skuDetails._price.split(" ");
	var price:String = priceList[0];
	var currency:String = priceList[1];
	price = price.split('٬').join('');
	if( currency == "ریال" )
		currency = "IRR";;
	price = StrUtils.getLatinNumber(price);
	trace(int(price), currency)
	GameAnalytics.addBusinessEvent("USD", 1000, "item", "id", "cart", "[receipt]", "[signature]");*/
	
	var params:SFSObject = new SFSObject();
	params.putText("productID", event.result.purchase.sku);
	params.putText("purchaseToken", event.result.purchase.token);
	params.putBool("consume", true);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.VERIFY_PURCHASE, params);
	
	dispatchEventWith(FeathersEventType.END_INTERACTION, false, event.result);
}

private function explain( response:int ) : void
{
	var res : int = Iab.IABHELPER_UNKNOWN_ERROR;
	switch( response )
	{
		case Iab.IABHELPER_NOT_SUPPORTED :
		case Iab.IABHELPER_USER_CANCELLED :
		case Iab.IABHELPER_NOT_INITIALIZED :
		case Iab.IABHELPER_VERIFICATION_FAILED :
		case Iab.IABHELPER_INVALID_CONSUMPTION :
			res = response;
			break;
	}
	appModel.navigator.addPopup(new MessagePopup(loc("popup_purchase_" + res, [appModel.descriptor.market])));
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- RATING -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
public function rate():void
{
	switch(appModel.descriptor.market )
	{
		case "google":
			navigateToURL(new URLRequest("https://play.google.com/store/apps/details?id=air." + appModel.descriptor.id));
			break;
		
		case "cafebazaar":
			NativeAbilities.instance.runIntent("android.intent.action.EDIT", "bazaar://details?id=air." + appModel.descriptor.id);
			break;
		
		case "myket":
			navigateToURL(new URLRequest("http://myket.ir/App/air." + appModel.descriptor.id));
			break;
		
		case "cando":
			navigateToURL(new URLRequest("cando://leave-review?id=air." + appModel.descriptor.id));
			break;
	}			
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- GET DOWNLOAD URL -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
public function getDownloadURL():String
{
	switch(appModel.descriptor.market )
	{
		case "google":		return 'https://play.google.com/store/apps/details?id=air.' + appModel.descriptor.id;			
		case "cafebazaar":	return 'https://cafebazaar.ir/app/air.' + appModel.descriptor.id;			
		case "myket":		return 'http://myket.ir/App/air.' + appModel.descriptor.id;
		case "cando":		return 'cando://details?id=air.' + appModel.descriptor.id;			
	}
	return "http://towers.grantech.ir/get/towerstory.apk";
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- SHARING -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
public function share():void
{
	NativeAbilities.instance.shareText(ResourceManager.getInstance().getString("loc", "app_title"), ResourceManager.getInstance().getString("loc", "app_brief") + "\n" + getDownloadURL());
}
private function log(message:String):void 
{
	//NativeAbilities.instance.showToast("iab_" + message, 2);
}
}
}