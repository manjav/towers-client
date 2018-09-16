package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.controls.items.exchange.ExCategoryItemRenderer;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.models.vo.ShopLine;
import com.gerantech.towercraft.models.vo.UserData;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.exchanges.ExchangeItem;
import feathers.controls.ImageLoader;
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
import flash.geom.Rectangle;
import starling.events.Event;
import starling.utils.Color;

public class ExchangeSegment extends Segment
{
public static var SELECTED_CATEGORY:int = 0
private var itemslistData:ListCollection;
private var itemslist:List;
private var scrollPaddingTop:int;

public function ExchangeSegment(){super();}
override public function init():void
{
	super.init();

	layout = new AnchorLayout();

	var listLayout:VerticalLayout = new VerticalLayout();
	listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	listLayout.hasVariableItemDimensions = true;
	listLayout.paddingTop = 120;
	listLayout.paddingBottom = 50;
	listLayout.useVirtualLayout = true;
	
	updateData();
	itemslist = new List();
	itemslist.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	itemslist.layout = listLayout;
	itemslist.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	itemslist.itemRendererFactory = function():IListItemRenderer { return new ExCategoryItemRenderer(); }
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
	///////////////////////showTutorial();
	//var time:Number = Math.abs(focusedCategory * 520 - itemslist.verticalScrollPosition) * 0.003;
	if( SELECTED_CATEGORY == 0 )
		itemslist.scrollToPosition(0, 0, 0.5);
	else
		itemslist.scrollToPosition(0, SELECTED_CATEGORY * ExCategoryItemRenderer.HEIGHT_NORMAL + scrollPaddingTop, 0.5);
	SELECTED_CATEGORY = 0;
}

override public function updateData():void
{
	if( itemslistData != null )
		return;
	
	var itemKeys:Vector.<int> = exchanger.items.keys();
	var bundles:ShopLine = new ShopLine(ExchangeType.C30_BUNDLES);
	var specials:ShopLine = new ShopLine(ExchangeType.C20_SPECIALS);
	var magics:ShopLine = new ShopLine(ExchangeType.C120_MAGICS);
	var hards:ShopLine = new ShopLine(ExchangeType.C0_HARD);
	var softs:ShopLine = new ShopLine(ExchangeType.C10_SOFT);
	for (var i:int=0; i<itemKeys.length; i++)
	{
		if( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.C30_BUNDLES && exchanger.items.get(itemKeys[i]).expiredAt > timeManager.now )
			bundles.add(itemKeys[i]);
		if( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.C20_SPECIALS )
			specials.add(itemKeys[i]);
		else if( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.C120_MAGICS )
			magics.add(itemKeys[i]);
		else if( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.C0_HARD && itemKeys[i] != ExchangeType.C0_HARD )//test
			hards.add(itemKeys[i]);
		else if( ExchangeType.getCategory( itemKeys[i] ) == ExchangeType.C10_SOFT )
			softs.add(itemKeys[i]);
	}
	
	scrollPaddingTop = ExCategoryItemRenderer.HEIGHT_C120_MAGICS;
	var categoreis:Array = new Array( magics, hards, softs );
	if( specials.items.length > 0 )
	{
		categoreis.unshift(specials);
		scrollPaddingTop += ExCategoryItemRenderer.HEIGHT_C20_SPECIALS;
	}
	if( bundles.items.length > 0 )
	{
		categoreis.unshift(bundles);
		scrollPaddingTop += ExCategoryItemRenderer.HEIGHT_C30_BUNDLES;
	}
	for (i=0; i<categoreis.length; i++)
		categoreis[i].items.sort();
	
	itemslistData = new ListCollection(categoreis);
	
	scrollPaddingTop = ExCategoryItemRenderer.HEIGHT_C120_MAGICS;
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
}
}