package com.gerantech.towercraft.controls.items.exchange
{
import com.gerantech.towercraft.controls.headers.ExchangeHeader;
import com.gerantech.towercraft.controls.items.AbstractTouchableListItemRenderer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.vo.ShopLine;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.exchanges.ExchangeItem;
import feathers.controls.List;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.TiledRowsLayout;
import feathers.layout.VerticalAlign;
import flash.geom.Rectangle;
import flash.utils.setTimeout;
import starling.core.Starling;
import starling.events.Event;

public class ExchangeCategoryItemRenderer extends AbstractTouchableListItemRenderer 
{
private var line:ShopLine;
private var list:List;
private var listLayout:TiledRowsLayout;
private var headerDisplay:ExchangeHeader;
private var descriptionDisplay:RTLLabel;
private var categoryCollection:ListCollection = new ListCollection();

public function ExchangeCategoryItemRenderer() { super(); }
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	
	headerDisplay = new ExchangeHeader("shop-line-header", new Rectangle(22, 6, 1, 2), 52 * appModel.scale);
	headerDisplay.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
	headerDisplay.height = 112 * appModel.scale;
	addChild(headerDisplay);
	
	listLayout = new TiledRowsLayout();
	listLayout.requestedColumnCount = 3;
	listLayout.tileHorizontalAlign = listLayout.horizontalAlign = HorizontalAlign.LEFT;
	listLayout.tileVerticalAlign = listLayout.verticalAlign = VerticalAlign.TOP;
	listLayout.useSquareTiles = false;
	listLayout.useVirtualLayout = false;
	listLayout.padding = listLayout.gap = 5 * appModel.scale;
	
	list = new List();
	list.layout = listLayout;
	list.layoutData = new AnchorLayoutData(headerDisplay.height, 0, 0, 0);
	list.horizontalScrollPolicy = list.verticalScrollPolicy = ScrollPolicy.OFF;
	list.addEventListener(Event.CHANGE, list_changeHandler);
	list.dataProvider = categoryCollection;
	addChild(list);
}

override protected function commitData():void
{
	super.commitData();
	if ( _data == null )
		return;
	line = _data as ShopLine;
	headerDisplay.label = loc("exchange_title_" + line.category);
	headerDisplay.data = line.category;

    var CELL_SIZE:int = 360 * appModel.scale;
	listLayout.typicalItemWidth = Math.floor((width - listLayout.gap * 4) / 3) ;
	//descriptionDisplay.visible = false;
	switch( line.category )
	{
		case ExchangeType.C20_SPECIALS:
			CELL_SIZE = 492 * appModel.scale;
			headerDisplay.showCountdown(line.items[0]);
			list.itemRendererFactory = function ():IListItemRenderer{ return new ExchangeSpecialItemRenderer();}
			break;
		
		case ExchangeType.C30_BUNDLES:
			CELL_SIZE = 580 * appModel.scale;
			listLayout.typicalItemWidth = Math.floor((width - listLayout.gap * 3) / 2) ;
			headerDisplay.showCountdown(line.items[0]);
			list.itemRendererFactory = function ():IListItemRenderer{ return new ExchangeBundleItemRenderer();}
			break;
		
		case ExchangeType.C100_FREES:
		case ExchangeType.C110_BATTLES:
			list.itemRendererFactory = function ():IListItemRenderer{ return new ExchangeBookBattleItemRenderer();}
			break;		
		
		case ExchangeType.C120_MAGICS:
			CELL_SIZE = 320 * appModel.scale;
			list.itemRendererFactory = function ():IListItemRenderer{ return new ExchangeBookBaseItemRenderer();}
			break;		
		
		default:
            CELL_SIZE = (line.category == ExchangeType.C0_HARD || line.category == ExchangeType.C10_SOFT ? 520:360) * appModel.scale;
			list.itemRendererFactory = function ():IListItemRenderer{ return new ExchangeCurrencyItemRenderer();}
			break;
	}
	
	height = CELL_SIZE * Math.ceil(line.items.length / listLayout.requestedColumnCount) + headerDisplay.height;
	listLayout.typicalItemHeight = CELL_SIZE - listLayout.gap * 1.6;
	/*setTimeout(function():void{*/categoryCollection.data = line.items/*}, index * 300);*/
	//alpha = 0;
	//Starling.juggler.tween(this, 0.3, {delay:index * 0.3, alpha:1});
}

private function list_changeHandler(event:Event):void
{
	var ei:ExchangeItem = exchanger.items.get(list.selectedItem as int);
	if( !ei.enabled )
		return;
	ei.enabled = false;
	owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, ei);
	list.removeEventListener(Event.CHANGE, list_changeHandler);
	list.selectedIndex = -1;
	list.addEventListener(Event.CHANGE, list_changeHandler);
}
}
}