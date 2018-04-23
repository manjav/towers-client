package com.gerantech.towercraft.controls.groups 
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.items.exchange.ExchangeBookItemRenderer;
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
private var listLayout:feathers.layout.TiledRowsLayout;
private var list:feathers.controls.List;

public function HomeBooksLine()
{
	super();
    height = 310 * appModel.scale;
}
private function assets_loadCallback(ratio:Number):void
{
	if( ratio >= 1 )
		initialize();
}

override protected function initialize():void 
{
	//appModel.assets.verbose = true;
	if( appModel.assets.getTexture("books_tex") == null )
	{
		appModel.assets.enqueue(File.applicationDirectory.resolvePath( "assets/animations/books" ));
		appModel.assets.loadQueue(assets_loadCallback)
	}
	if( appModel.assets.isLoading )
		return;
	OpenBookOverlay.createFactory();
	
	super.initialize();
	
	layout = new AnchorLayout();
	
	listLayout = new TiledRowsLayout();
	listLayout.requestedColumnCount = 4;
	listLayout.tileHorizontalAlign = listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	listLayout.verticalAlign = VerticalAlign.BOTTOM;
	listLayout.useSquareTiles = false;
	listLayout.useVirtualLayout = false;
	listLayout.padding = listLayout.gap = 5 * appModel.scale;
	listLayout.typicalItemWidth = Math.floor((1080 * appModel.scale-listLayout.gap * 5) / 4) ;
	listLayout.typicalItemHeight = height - listLayout.gap * 1.6;

	list = new List();
	list.layout = listLayout;
	list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	list.horizontalScrollPolicy = list.verticalScrollPolicy = ScrollPolicy.OFF;
	list.addEventListener(Event.CHANGE, list_changeHandler);
	list.itemRendererFactory = function ():IListItemRenderer{ return new ExchangeBookItemRenderer();}
	list.dataProvider = new ListCollection([101, 102, 103, 111]);
	addChild(list);
	
	exchangeManager.addEventListener(Event.COMPLETE, exchangeManager_completeHandler);
}

private function exchangeManager_completeHandler(event:Event):void 
{
	var item:ExchangeItem = event.data as ExchangeItem;
	if( !item.isBook() )
		return;
	
	for( var i:int = 0; i < list.dataProvider.length; i++ )
		if( list.dataProvider.getItemAt(i) == item.type )
			list.dataProvider.updateItemAt(i);
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
override public function dispose():void 
{
	exchangeManager.removeEventListener(Event.COMPLETE, exchangeManager_completeHandler);
	super.dispose();
}
}
}