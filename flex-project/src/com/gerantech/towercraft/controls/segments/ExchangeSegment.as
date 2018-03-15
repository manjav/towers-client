package com.gerantech.towercraft.controls.segments
{
import com.gerantech.extensions.iab.IabResult;
import com.gerantech.towercraft.controls.items.exchange.ExchangeCategoryItemRenderer;
import com.gerantech.towercraft.controls.overlays.OpenChestOverlay;
import com.gerantech.towercraft.controls.popups.AdConfirmPopup;
import com.gerantech.towercraft.controls.popups.ChestsDetailsPopup;
import com.gerantech.towercraft.controls.popups.ConfirmPopup;
import com.gerantech.towercraft.controls.popups.RequirementConfirmPopup;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.managers.BillingManager;
import com.gerantech.towercraft.managers.VideoAdsManager;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.models.vo.ShopLine;
import com.gerantech.towercraft.models.vo.UserData;
import com.gerantech.towercraft.models.vo.VideoAd;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.ExchangeType;
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
public static var focusedCategory:int = 0
private var itemslistData:ListCollection;
private var itemslist:List;
private var openChestOverlay:OpenChestOverlay;

public function ExchangeSegment()
{
	super();
}

private function assets_loadCallback(ratio:Number):void
{
	if( ratio >= 1 && initializeStarted && !initializeCompleted )
		init();
}

override public function init():void
{
	super.init();
	//appModel.assets.verbose = true;
	if( appModel.assets.getTexture("books_tex") == null )
	{
		appModel.assets.enqueue(File.applicationDirectory.resolvePath( "assets/animations/books" ));
		appModel.assets.loadQueue(assets_loadCallback)
	}
	if( appModel.assets.isLoading )
		return;
	
	OpenChestOverlay.createFactory();

	layout = new AnchorLayout();

	var listLayout:VerticalLayout = new VerticalLayout();
	listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	listLayout.hasVariableItemDimensions = true;
	listLayout.paddingTop = 120 * appModel.scale;
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
	focus();
}

override public function focus():void
{
	if( !initializeCompleted )
		return;
	showTutorial();
	var time:Number = Math.abs(focusedCategory * 480 * appModel.scale - itemslist.verticalScrollPosition) * 0.003;
	itemslist.scrollToDisplayIndex(focusedCategory, time);
	focusedCategory = 0;
}


private function showTutorial():void
{
	tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_finishHandler);
	if( player.getTutorStep() != PrefsTypes.T_141_SHOP_FOCUS )
		return;
	
	UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_142_SHOP_FIRST_VIEW );
	var tutorialData:TutorialData = new TutorialData("shop_start");
	tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_shop_0", null, 1000, 1000, 0));
	tutorials.show(tutorialData);
}

private function tutorials_finishHandler(event:Event):void
{
	if( event.data.name == "shop_start" )
	{
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_143_SHOP_BOOK_FOCUS );
	}
	else if( event.data.name == "shop_end" )
	{
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_151_DECK_FOCUS);
		tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_finishHandler);
		var tutorialData:TutorialData = new TutorialData("shop_end");
		tutorials.show(tutorialData);
	}
}

override public function updateData():void
{
	if( itemslistData == null )
		itemslistData = new ListCollection();
	else return;
	
	var itemKeys:Vector.<int> = exchanger.items.keys();
	//var specials:ShopLine = new ShopLine(ExchangeType.S_20_SPECIALS);
	var frees:ShopLine = new ShopLine(ExchangeType.CHEST_CATE_100_FREE);
	var battles:ShopLine = new ShopLine(ExchangeType.CHEST_CATE_110_BATTLES);
	var offers:ShopLine = new ShopLine(ExchangeType.CHEST_CATE_120_OFFERS);
	var hards:ShopLine = new ShopLine(ExchangeType.S_0_HARD);
	var softs:ShopLine = new ShopLine(ExchangeType.S_10_SOFT);
	for (var i:int=0; i<itemKeys.length; i++)
	{
		if ( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.S_0_HARD && itemKeys[i] != ExchangeType.S_0_HARD )//test
			hards.add(itemKeys[i]);
		else if ( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.S_10_SOFT )
			softs.add(itemKeys[i]);
		else if( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.CHEST_CATE_110_BATTLES )
			battles.add(itemKeys[i]);
		else if( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.CHEST_CATE_120_OFFERS )
			offers.add(itemKeys[i]);
		else if( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.CHEST_CATE_100_FREE )
			frees.add(itemKeys[i]);
	}
	
	var categoreis:Array = new Array( frees, battles, offers, hards, softs );
	for (i=0; i<categoreis.length; i++)
	{
		categoreis[i].items.sort();
		if( !appModel.isLTR )
			categoreis[i].items.reverse();
	}
	itemslistData.data = categoreis;
}

private function list_changeHandler(event:Event):void
{
	var item:ExchangeItem = event.data as ExchangeItem;
	if( player.inTutorial() && item.type != ExchangeType.CHEST_CATE_101_FREE )
		return;// disalble all items in tutorial

	if( item.category == ExchangeType.S_0_HARD )
	{
		BillingManager.instance.addEventListener(FeathersEventType.END_INTERACTION, billinManager_endInteractionHandler);
		BillingManager.instance.purchase("com.grantech.towers.item_"+item.type);
		function billinManager_endInteractionHandler ( event:Event ) : void {
			var result:IabResult = event.data as IabResult;
			if( result.succeed )
			{
				// exchange item
				exchanger.exchange(item, timeManager.now);
				
				// show achieve animation
				var outs:Vector.<int> = item.outcomes.keys();
				for ( var i:int=0; i<outs.length; i++ )
					appModel.navigator.addResourceAnimation(stage.stageWidth * 0.5, stage.stageHeight * 0.5, outs[i], item.outcomes.get(outs[i]));
									
				// send analytics events
				GameAnalytics.addResourceEvent(GAResourceFlowType.SOURCE, outs[0].toString(), item.outcomes.get(outs[0]), "IAP", result.purchase.sku);

				var currency:String = appModel.descriptor.market == "google" ? "USD" : "IRR";
				var amount:int = item.requirements.get(outs[0]) * (appModel.descriptor.market == "google" ? 1 : 10);
				GameAnalytics.addBusinessEvent(currency, amount, result.purchase.itemType, result.purchase.sku, outs[0].toString(), result.purchase!=null?result.purchase.json:null, result.purchase!=null?result.purchase.signature:null);			
			}
			item.enabled = true;
		}
		return;
	}
	
	var params:SFSObject = new SFSObject();
	params.putInt("type", item.type );
	
	if( item.category == ExchangeType.S_10_SOFT )
	{
		if( !player.has(item.requirements) )
		{
			appModel.navigator.addLog(loc("log_not_enough", [loc("resource_title_1003")]));
			item.enabled = true;
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
			item.enabled = true;
		}
		return;
	}

	if( item.isChest() )
	{
		item.enabled = true;
		if( ( item.category == ExchangeType.CHEST_CATE_100_FREE || item.category == ExchangeType.CHEST_CATE_110_BATTLES ) && item.getState(timeManager.now) == ExchangeItem.CHEST_STATE_READY  )
		{
			exchange(item, params);
			
			if( player.getTutorStep() == PrefsTypes.T_143_SHOP_BOOK_FOCUS )
				UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_144_SHOP_BOOK_OPENED );
			
			return;
		}
	
		
		if ( item.getState(timeManager.now) != ExchangeItem.CHEST_STATE_READY && item.category == ExchangeType.CHEST_CATE_100_FREE )
		{
			appModel.navigator.addLog(loc("exchange_free_waiting", [StrUtils.toTimeFormat(item.expiredAt - timeManager.now)]));
			return;
		}
		
		var details:ChestsDetailsPopup = new ChestsDetailsPopup(item);
		details.addEventListener(Event.SELECT, details_selectHandler);
		appModel.navigator.addPopup(details);
		function details_selectHandler(event:Event):void{
			details.removeEventListener(Event.SELECT, details_selectHandler);
			exchange(item, params);
		}
		return;
	}
}

private function exchange(item:ExchangeItem, params:SFSObject):void
{
	try
	{
		var chestType:int = item.category == ExchangeType.CHESTS_50 ? item.type : item.outcome; // reserved because outcome changed after exchange
		if( exchanger.exchange(item, timeManager.now) )
		{
			if( item.isChest() && ( item.getState(timeManager.now) != ExchangeItem.CHEST_STATE_BUSY || item.category == ExchangeType.CHEST_CATE_100_FREE ) )
			{
				openChestOverlay = new OpenChestOverlay(chestType);
				appModel.navigator.addOverlay(openChestOverlay);
			}
		}
	} 
	catch(error:GameError) 
	{
		if ( error.id == 0 )
			appModel.navigator.addLog(loc("log_not_enough", [loc("resource_title_"+error.object)]));
		return;
	}
	sendData(params)			
}

private function sendData(params:SFSObject):void
{
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.EXCHANGE, params);			
}

private function confirms_closeHandler(event:Event):void
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
	sendData(params);
}

protected function sfsConnection_extensionResponseHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.EXCHANGE )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
	var data:SFSObject = event.params.params;
	var item:ExchangeItem = exchanger.items.get(data.getInt("type"));
	item.enabled = true;
	if( !data.getBool("succeed") )
		return;
	
	if( item.isChest() )
	{
		itemslist.dataProvider.updateItemAt( (item.category - 100) / 10 );
		if( !data.containsKey("rewards") )
			return;
		item.outcomes = new IntIntMap();
		//trace(data.getSFSArray("rewards").getDump());
		var reward:ISFSObject;
		for( var i:int=0; i<data.getSFSArray("rewards").size(); i++ )
		{
			reward = data.getSFSArray("rewards").getSFSObject(i);
			if( reward.getInt("t") != ResourceType.XP && reward.getInt("t") != ResourceType.POINT )
				item.outcomes.set(reward.getInt("t"), reward.getInt("c"));
		}
		player.addResources(item.outcomes);
		openChestOverlay.setItem( item );
		openChestOverlay.addEventListener(Event.CLOSE, openChestOverlay_closeHandler);
		function openChestOverlay_closeHandler(event:Event):void {
			openChestOverlay.removeEventListener(Event.CLOSE, openChestOverlay_closeHandler);
			if( item.category != ExchangeType.CHEST_CATE_130_ADS )
				showAd();
			openChestOverlay = null;
			gotoDeckTutorial();
		}
		appModel.navigator.dispatchEventWith("bookOpened");
	}
	if( item.category == ExchangeType.S_10_SOFT )
	{
		var outs:Vector.<int> = item.outcomes.keys();
		for ( i=0; i<outs.length; i++ )
			appModel.navigator.addResourceAnimation(stage.stageWidth * 0.5, stage.stageHeight * 0.5, outs[i], item.outcomes.get(outs[i])); 
	}
}

private function gotoDeckTutorial():void
{
	if( !player.inShopTutorial() )
		return;

	var tutorialData:TutorialData = new TutorialData("shop_end");
	tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_shop_6", null, 1000, 1000, 4));
	tutorials.show(tutorialData);
}

private function showAd():void
{
	if( player.inTutorial() || !VideoAdsManager.instance.getAdByType(VideoAdsManager.TYPE_CHESTS).available )
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
	params.putInt("type", ExchangeType.CHEST_CATE_131_ADS );
	exchange(exchanger.items.get(ExchangeType.CHEST_CATE_131_ADS), params);
}
public override function dispose() : void
{
	tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_finishHandler);
	super.dispose();
}
}
}