package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.controls.items.exchange.ExchangeCategoryItemRenderer;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.models.vo.ShopLine;
import com.gerantech.towercraft.models.vo.UserData;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.exchanges.ExchangeItem;
import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;
import flash.filesystem.File;
import starling.events.Event;

public class ExchangeSegment extends Segment
{
public static var focusedCategory:int = 0
private var itemslistData:ListCollection;
private var itemslist:List;

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
	
	OpenBookOverlay.createFactory();

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
	itemslist.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	itemslist.itemRendererFactory = function():IListItemRenderer { return new ExchangeCategoryItemRenderer(); }
	itemslist.dataProvider = itemslistData;
	itemslist.addEventListener(FeathersEventType.FOCUS_IN, list_changeHandler);
	addChild(itemslist);
	initializeCompleted = true;
	exchangeManager.addEventListener(Event.COMPLETE, exchangeManager_completeHandler);
	focus();
}

private function exchangeManager_completeHandler(event:Event):void 
{
	var item:ExchangeItem = event.data as ExchangeItem;
	if( item.category == ExchangeType.S_0_HARD || item.category == ExchangeType.S_10_SOFT )
	{
		//show achieve animation
		var outs:Vector.<int> = item.outcomes.keys();
		for ( var i:int=0; i<outs.length; i++ )
			appModel.navigator.addResourceAnimation(stage.stageWidth * 0.5, stage.stageHeight * 0.5, outs[i], item.outcomes.get(outs[i]));
	}
}

override public function focus():void
{
	if( !initializeCompleted )
		return;
	///////////////////////showTutorial();
	var time:Number = Math.abs(focusedCategory * 480 * appModel.scale - itemslist.verticalScrollPosition) * 0.003;
	itemslist.scrollToDisplayIndex(focusedCategory, time);
	focusedCategory = 0;
}

/*private function showTutorial():void
{
	tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_finishHandler);
	if( player.getTutorStep() != PrefsTypes.T_141_SHOP_FOCUS )
		return;
	
	UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_142_SHOP_FIRST_VIEW );
	var tutorialData:TutorialData = new TutorialData("shop_start");
	tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_shop_0", null, 500, 1500, 0));
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
}*/

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
		//else if( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.CHEST_CATE_110_BATTLES )
			//battles.add(itemKeys[i]);
		else if( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.CHEST_CATE_120_OFFERS )
			offers.add(itemKeys[i]);
		//else if( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.CHEST_CATE_100_FREE )
			//frees.add(itemKeys[i]);
	}
	
	var categoreis:Array = new Array( /*frees, battles,*/ offers, hards, softs );
	for (i=0; i<categoreis.length; i++)
	{
		categoreis[i].items.sort();
		if( !appModel.isLTR )
			categoreis[i].items.reverse();
	}
	itemslistData.data = categoreis;
}

private function list_changeHandler(event:Event) : void
{
	exchangeManager.process(event.data as ExchangeItem);
}

/*private function confirms_closeHandler(event:Event):void
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
}*/

public override function dispose() : void
{
	exchangeManager.removeEventListener(Event.COMPLETE, exchangeManager_completeHandler);
	///////////////////////tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorials_finishHandler);
	super.dispose();
}
}
}