package com.gerantech.towercraft.controls.groups 
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.items.exchange.ExBookBattleItemRenderer;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gt.towers.exchanges.ExchangeItem;
import feathers.controls.List;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.TiledRowsLayout;
import feathers.layout.VerticalAlign;
import flash.filesystem.File;
import starling.events.Event;

/**
* ...
* @author Mansour Djawadi
*/
public class HomeBooksLine extends TowersLayout 
{
public var paddingTop:Number;
private var listLayout:feathers.layout.TiledRowsLayout;
private var list:feathers.controls.List;

public function HomeBooksLine()
{
	super();
    height = 290 * appModel.scale;
	paddingTop = 40 * appModel.scale;
}

override protected function initialize():void 
{
	super.initialize();
	
	layout = new AnchorLayout();
	
	listLayout = new TiledRowsLayout();
	listLayout.requestedColumnCount = 4;
	listLayout.tileHorizontalAlign = listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	listLayout.verticalAlign = VerticalAlign.BOTTOM;
	listLayout.useSquareTiles = false;
	listLayout.useVirtualLayout = false;
	listLayout.padding = listLayout.gap = 4 * appModel.scale;
	listLayout.paddingTop = paddingTop;
	listLayout.typicalItemWidth = Math.floor((1080 * appModel.scale-listLayout.gap * 5) / 4) ;
	listLayout.typicalItemHeight = height - paddingTop - listLayout.gap;

	list = new List();
	list.layout = listLayout;
	list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	list.horizontalScrollPolicy = list.verticalScrollPolicy = ScrollPolicy.OFF;
	list.addEventListener(Event.CHANGE, list_changeHandler);
	list.itemRendererFactory = function ():IListItemRenderer{ return new ExBookBattleItemRenderer();}
	list.dataProvider = new ListCollection([114, 113, 112, 111]);
	addChild(list);
}

private function list_changeHandler(event:Event):void
{
	var ei:ExchangeItem = exchanger.items.get(list.selectedItem as int);
	if(!ei.enabled)
		return;
	ei.enabled = false;
	exchangeManager.process(ei);
	
	list.removeEventListener(Event.CHANGE, list_changeHandler);
	list.selectedIndex = -1;
	list.addEventListener(Event.CHANGE, list_changeHandler);
}
}
}