package com.gerantech.towercraft.managers 
{
import com.gerantech.extensions.iab.IabResult;
import com.gerantech.towercraft.controls.overlays.EarnOverlay;
import com.gerantech.towercraft.controls.overlays.FortuneOverlay;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.controls.popups.AdConfirmPopup;
import com.gerantech.towercraft.controls.popups.BookDetailsPopup;
import com.gerantech.towercraft.controls.popups.ConfirmPopup;
import com.gerantech.towercraft.controls.popups.FortuneSkipPopup;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.models.vo.VideoAd;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.MessageTypes;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;
import com.gt.towers.utils.GameError;
import com.gt.towers.utils.maps.IntIntMap;
import com.marpies.ane.gameanalytics.GameAnalytics;
import com.marpies.ane.gameanalytics.data.GAResourceFlowType;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.events.FeathersEventType;
import starling.events.Event;
/**
* ...
* @author Mansour Djawadi
*/
public class ExchangeManager extends BaseManager 
{
private static var _instance:ExchangeManager;
private var earnOverlay:EarnOverlay;
public static function get instance() : ExchangeManager
{
	if( _instance == null )
		_instance = new ExchangeManager();
	return (_instance);
}
public function ExchangeManager() {	super(); }
public function process(item : ExchangeItem) : void 
{
	if ( (player.inDeckTutorial() || player.inShopTutorial()) && item.type != ExchangeType.C101_FREE )
	{
		dispatchEndEvent(false, item);
		return;// disalble all items in tutorial
	}

	var params:SFSObject = new SFSObject();
	params.putInt("type", item.type );
	if( item.category == ExchangeType.C0_HARD || item.category == ExchangeType.C30_BUNDLES )
	{
		BillingManager.instance.addEventListener(FeathersEventType.END_INTERACTION, billinManager_endInteractionHandler);
		BillingManager.instance.purchase((item.category == ExchangeType.C0_HARD ? "com.grantech.towers.item_" : "towres.bundle_") + item.type);
		function billinManager_endInteractionHandler ( event:Event ) : void {
			BillingManager.instance.removeEventListener(FeathersEventType.END_INTERACTION, billinManager_endInteractionHandler);
			var result:IabResult = event.data as IabResult;
			if( result.succeed )
			{
				exchange(item, params);
				
				if( item.category == ExchangeType.C0_HARD )
				{
					// send analytics events
					var outs:Vector.<int> = item.outcomes.keys();
					GameAnalytics.addResourceEvent(GAResourceFlowType.SOURCE, outs[0].toString(), item.outcomes.get(outs[0]), "IAP", result.purchase.sku);
					
					var currency:String = appModel.descriptor.market == "google" ? "USD" : "IRR";
					var amount:int = item.requirements.get(outs[0]) * (appModel.descriptor.market == "google" ? 1 : 10);
					GameAnalytics.addBusinessEvent(currency, amount, result.purchase.itemType, result.purchase.sku, outs[0].toString(), result.purchase != null?result.purchase.json:null, result.purchase != null?result.purchase.signature:null);  
					
					dispatchEndEvent(true, item);
				}
				return;
			}
			
			dispatchEndEvent(false , item);
			return;
		}
		return;
	}
	
	if( item.category == ExchangeType.C10_SOFT )
	{
		if( !player.has(item.requirements) )
		{
			appModel.navigator.addLog(loc("log_not_enough", [loc("resource_title_1003")]));
			dispatchEndEvent(false, item);
			return;
		}
		var confirm1:ConfirmPopup = new ConfirmPopup(loc("popup_sure_label"));
		confirm1.acceptStyle = "danger";
		confirm1.addEventListener(Event.SELECT, confirm1_selectHandler);
		confirm1.addEventListener(Event.CLOSE, confirm1_closeHandler);
		appModel.navigator.addPopup(confirm1);
		function confirm1_selectHandler ( event:Event ):void {
			confirm1.removeEventListener(Event.SELECT, confirm1_selectHandler);
			confirm1.removeEventListener(Event.CLOSE, confirm1_closeHandler);
			exchange(item, params);
		}
		function confirm1_closeHandler ( event:Event ):void {
			confirm1.removeEventListener(Event.SELECT, confirm1_selectHandler);
			confirm1.removeEventListener(Event.CLOSE, confirm1_closeHandler);
			dispatchEndEvent(false, item);
		}
		return;
	}
	
	if( item.category == ExchangeType.C20_SPECIALS )
	{
		if( !player.has(item.requirements) )
		{
			appModel.navigator.addLog(loc("log_not_enough", [loc("resource_title_" + item.requirements.keys()[0])]));
			dispatchEndEvent(false, item);
			return;
		}
		exchange(item, params);
		return;
	}

	if( item.isBook() )
	{
		item.enabled = true;
		if( ( item.category == ExchangeType.C100_FREES || item.category == ExchangeType.C110_BATTLES ) && item.getState(timeManager.now) == ExchangeItem.CHEST_STATE_READY  )
		{
			item.outcomes = new IntIntMap();
			exchange(item, params);
			
			if( player.getTutorStep() == PrefsTypes.T_143_SHOP_BOOK_FOCUS )
				UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_144_SHOP_BOOK_OPENED );
			
			return;
		}
		else if( item.category == ExchangeType.C100_FREES && item.getState(timeManager.now) != ExchangeItem.CHEST_STATE_READY )
		{
			var dailyPopup:FortuneSkipPopup = new FortuneSkipPopup(item);
			dailyPopup.addEventListener(Event.SELECT, dailyPopup_selectHandler);
			appModel.navigator.addPopup(dailyPopup);
			function dailyPopup_selectHandler(event:Event):void{
				dailyPopup.removeEventListener(Event.SELECT, dailyPopup_selectHandler);
				exchange(item, params);
			}
			dispatchEndEvent(false, item);
			return;
		}
		
		var details:BookDetailsPopup = new BookDetailsPopup(item);
		details.addEventListener(Event.SELECT, details_selectHandler);
		appModel.navigator.addPopup(details);
		function details_selectHandler(event:Event):void{
			details.removeEventListener(Event.SELECT, details_selectHandler);
			exchange(item, params);
		}
	}
}

private function exchange( item:ExchangeItem, params:SFSObject ) : void
{
	try
	{
		if( item.category == ExchangeType.C100_FREES )
			exchanger.findRandomOutcome(item);
		var bookType:int = -1;
		if( item.category == ExchangeType.C30_BUNDLES )
			bookType = item.containBook(); // reterive a book from bundle. if not found show golden book
		else 
			bookType = item.category == ExchangeType.BOOKS_50 ? item.type : item.outcome; // reserved because outcome changed after exchange
		
		if( exchanger.exchange(item, timeManager.now) == MessageTypes.RESPONSE_SUCCEED )
		{
			if( ( item.isBook() && ( item.getState(timeManager.now) != ExchangeItem.CHEST_STATE_BUSY || item.category == ExchangeType.C100_FREES ) ) || ( item.category == ExchangeType.C30_BUNDLES && ExchangeType.getCategory(bookType) == ExchangeType.BOOKS_50 ) )
			{
				earnOverlay = item.category == ExchangeType.C100_FREES ? new FortuneOverlay(bookType) : new OpenBookOverlay(bookType);
				appModel.navigator.addOverlay(earnOverlay);
			}
		}
	} 
	catch(error:GameError) 
	{
		if( error.id == 0 )
			appModel.navigator.addLog(loc("log_not_enough", [loc("resource_title_" + error.object)]));
		return;
	}
	if( item.category != ExchangeType.C0_HARD )
		sendData(params)			
}

private function sendData(params:SFSObject):void
{
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.EXCHANGE, params);			
}

protected function sfsConnection_extensionResponseHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.EXCHANGE )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
	var data:SFSObject = event.params.params;
	var item:ExchangeItem = exchanger.items.get(data.getInt("type"));
	if( data.getInt("response") != MessageTypes.RESPONSE_SUCCEED )
	{
		dispatchEndEvent(false, item);
		return;
	}
	
	if( item.isBook() || item.containBook() > -1 )
	{
		if( !data.containsKey("rewards") )
			return;
		var outcomes:IntIntMap = new IntIntMap();
		//trace(data.getSFSArray("rewards").getDump());
		var reward:ISFSObject;
		for( var i:int=0; i<data.getSFSArray("rewards").size(); i++ )
		{
			reward = data.getSFSArray("rewards").getSFSObject(i);
			if( ResourceType.isBuilding(reward.getInt("t")) || reward.getInt("t") == ResourceType.CURRENCY_HARD || reward.getInt("t") == ResourceType.CURRENCY_SOFT || reward.getInt("t") == ResourceType.KEY )
				outcomes.set(reward.getInt("t"), reward.getInt("c"));
		}
		
		if( item.category == ExchangeType.C110_BATTLES && data.containsKey("nextOutcome") )
			exchanger.items.get(item.type).outcome = data.getInt("nextOutcome");
		
		player.addResources( outcomes );
		earnOverlay.outcomes = outcomes;
		earnOverlay.addEventListener(Event.CLOSE, openChestOverlay_closeHandler);
		function openChestOverlay_closeHandler(event:Event):void {
			earnOverlay.removeEventListener(Event.CLOSE, openChestOverlay_closeHandler);
			if( item.category != ExchangeType.C43_ADS )
				showAd();
			earnOverlay = null;
			gotoDeckTutorial();
		}
		appModel.navigator.dispatchEventWith("bookOpened");
	}
	dispatchEndEvent(true, item);
}

private function gotoDeckTutorial():void
{
	if( !player.inShopTutorial() )
		return;

	var tutorialData:TutorialData = new TutorialData("shop_end");
	tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_shop_6", null, 500, 1500, 4));
	tutorials.show(tutorialData);
}


private function showAd():void
{
	if( player.inTutorial() || player.prefs.getAsBool(PrefsTypes.SETTINGS_5_REMOVE_ADS) || !VideoAdsManager.instance.getAdByType(VideoAdsManager.TYPE_CHESTS).available )
		return;
	
	var adConfirmPopup:AdConfirmPopup = new AdConfirmPopup();
	adConfirmPopup.addEventListener(Event.SELECT, adConfirmPopup_selectHandler);
	appModel.navigator.addPopup(adConfirmPopup);
	function adConfirmPopup_selectHandler(event:Event):void {
		adConfirmPopup.removeEventListener(Event.SELECT, adConfirmPopup_selectHandler);
		VideoAdsManager.instance.showAd(VideoAdsManager.TYPE_CHESTS);
		VideoAdsManager.instance.addEventListener(Event.COMPLETE, videoIdsManager_completeHandler);
	}
}
private function videoIdsManager_completeHandler(event:Event):void
{
	VideoAdsManager.instance.removeEventListener(Event.COMPLETE, videoIdsManager_completeHandler);
	VideoAdsManager.instance.requestAd(VideoAdsManager.TYPE_CHESTS, true);
	var ad:VideoAd = event.data as VideoAd;
	if( !ad.rewarded )
		return;
	
	var params:SFSObject = new SFSObject();
	params.putInt("type", ExchangeType.C43_ADS );
	exchange(exchanger.items.get(ExchangeType.C43_ADS), params);
}
private function dispatchEndEvent( succeed:Boolean, item:ExchangeItem ) : void 
{
	item.enabled = true;
	dispatchEventWith(succeed?Event.COMPLETE:Event.FATAL_ERROR, false, item);
}
}
}