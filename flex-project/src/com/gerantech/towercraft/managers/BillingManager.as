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
import com.gerantech.towercraft.models.AppModel;
import com.gt.towers.constants.ExchangeType;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSObject;

import flash.net.URLRequest;
import flash.net.navigateToURL;

import mx.resources.ResourceManager;

import feathers.events.FeathersEventType;

import starling.events.EventDispatcher;

public class BillingManager extends EventDispatcher
{
private var items:Array;

private static var _instance:BillingManager;
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
	switch( AppModel.instance.descriptor.market )
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
		
			case "ario":
			base64Key = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC1FSvYe0mDDFAnk8SHSMLFxaaQF9MvObuQ8U9tWf4uE0OT8erPKhgUR7cqOF74TXAYlrSwbyTC/nHgqURLRX7C0iFFT1/j9BpMKxNULb/CqulNaJg6AEfQbwTcwIfVzS04dUPhjhR9MdRICfiZkMzWesWfyE4Dfre+p5vt0qC0MQIDAQAB";
			bindURL = "com.arioclub.android.sdk.iab.InAppBillingService.BIND";
			packageURL = "com.arioclub.android";
			break;
		
		default://cafebazaar
			base64Key = "MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwDBF2CttLWeUoUQG+KcbDAxqB4JqYvOn/pd2bNiPNFJXmVkw2RzkgLEomhFM/phWseg+SVe4bHM7TQg++1gvLpnfzr2onbdcYdWDllDhbQQFXXEtW+h8WdeQDFB6LCc+nUBcrJh7B5c99acShSTnENuuiRMbz2xR9nnDivlleu4XO3peTq1e4qoXewE/meloWuCNnPkc8fWDOm87zKFDRHLwlIQ3vJGUlpnFxXFd3cCAwEAAQ==";
			bindURL = "ir.cafebazaar.pardakht.InAppBillingService.BIND";
			packageURL = "com.farsitel.bazaar";
			break;
	}			

	Iab.instance.addEventListener(IabEvent.SETUP_FINISHED, iab_setupFinishedHandler);
	Iab.instance.startSetup(base64Key, bindURL, packageURL);
}
protected function iab_setupFinishedHandler(event:IabEvent):void
{
	trace("iab_setupFinishedHandler", event.result.message);
	Iab.instance.removeEventListener(IabEvent.SETUP_FINISHED, iab_setupFinishedHandler);
	dispatchEventWith(FeathersEventType.INITIALIZE);
	if( event.result.succeed )
		queryInventory();
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
		verify(purchase);
	}
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_- PURCHASE -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
public function purchase(sku:String):void
{
	Iab.instance.addEventListener(IabEvent.PURCHASE_FINISHED, iab_purchaseFinishedHandler);
	Iab.instance.purchase(sku);
}

protected function iab_purchaseFinishedHandler(event:IabEvent):void
{
	trace("iab_purchaseFinishedHandler", event.result.message);
	Iab.instance.removeEventListener(IabEvent.PURCHASE_FINISHED, iab_purchaseFinishedHandler);
	if( !event.result.succeed )
	{
		explain(event.result.response == Iab.IABHELPER_NOT_SUPPORTED ? "popup_purchase_not_initialized":"popup_purchase_error");
		dispatchEventWith(FeathersEventType.END_INTERACTION, false, event.result);
		return;
	}
	var purchase:Purchase = Iab.instance.getPurchase(event.result.purchase.sku);
	if( purchase != null )
		verify(purchase);
	else
		queryInventory();
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_- PURCHASE VERIFICATION AND CONSUMPTION -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
private function verify(purchase:Purchase):void
{
	AppModel.instance.navigator.addLog(ResourceManager.getInstance().getString("loc", "waiting_message"));
	var param:SFSObject = new SFSObject();
	param.putText("productID", purchase.sku);
	param.putText("purchaseToken", purchase.token);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_purchaseVerifyHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.VERIFY_PURCHASE, param);
	function sfsConnection_purchaseVerifyHandler(event:SFSEvent):void
	{
		if( event.params.cmd != SFSCommands.VERIFY_PURCHASE )
			return;
		SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_purchaseVerifyHandler);
		var result:SFSObject = event.params.params;
		trace(result.getDump());
		if( result.getBool("success") )
		{
			if( ( AppModel.instance.descriptor.market == "cafebazaar" && result.getInt("consumptionState") == 1 ) || ( AppModel.instance.descriptor.market == "myket" && result.getInt("consumptionState") == 0 ) )
				consume(purchase.sku);
		}
		else
		{
			explain("popup_purchase_invalid");
		}
	}	
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_- CONSUMING PURCHASED ITEM -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
public function consume(sku:String):void
{
	trace("consume", sku); 
	Iab.instance.addEventListener(IabEvent.CONSUME_FINISHED, iab_consumeFinishedHandler);
	Iab.instance.consume(sku);
}
protected function iab_consumeFinishedHandler(event:IabEvent):void
{			
	trace("iab_consumeFinishedHandler", event.result.message);
	Iab.instance.removeEventListener(IabEvent.CONSUME_FINISHED, iab_consumeFinishedHandler);
	if( !event.result.succeed )
	{
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

private function explain(message:String):void
{
	var popup:MessagePopup = new MessagePopup(ResourceManager.getInstance().getString("loc", message));
	AppModel.instance.navigator.addPopup(popup);
}

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_- RATING -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
public function rate():void
{
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