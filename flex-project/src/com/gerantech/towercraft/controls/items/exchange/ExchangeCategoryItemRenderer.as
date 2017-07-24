package com.gerantech.towercraft.controls.items.exchange
{
	import com.gerantech.towercraft.controls.ExchangeHeader;
	import com.gerantech.towercraft.controls.items.BaseCustomItemRenderer;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.models.vo.ShopLine;
	import com.gt.towers.constants.ExchangeType;
	import com.gt.towers.exchanges.Exchange;
	import com.gt.towers.exchanges.ExchangeItem;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.List;
	import feathers.controls.ScrollPolicy;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.TiledColumnsLayout;
	import feathers.layout.VerticalAlign;
	
	import starling.events.Event;

	public class ExchangeCategoryItemRenderer extends BaseCustomItemRenderer 
	{
		private var _firstCommit:Boolean = true;
		private var line:ShopLine;
		private var list:List;

		private var listLayout:TiledColumnsLayout;
		private var headerDisplay:ExchangeHeader;
		private var descriptionDisplay:RTLLabel;
		
		public function ExchangeCategoryItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			
			headerDisplay = new ExchangeHeader("shop-line-header", new Rectangle(22,6,1,2), 52*appModel.scale);
			headerDisplay.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
			headerDisplay.height = 112 * appModel.scale;
			addChild(headerDisplay);
			
			descriptionDisplay = new RTLLabel(" ", 1, null, null, false, null, 0.74);
			descriptionDisplay.layoutData = new AnchorLayoutData(headerDisplay.height, 24 * appModel.scale, NaN, 24 * appModel.scale);
			addChild(descriptionDisplay);
			
			listLayout = new TiledColumnsLayout();
			listLayout.requestedColumnCount = 3;
			listLayout.tileHorizontalAlign = listLayout.horizontalAlign = appModel.align;
			listLayout.verticalAlign = VerticalAlign.BOTTOM;
			listLayout.useSquareTiles = false;
			listLayout.useVirtualLayout = false;
			listLayout.padding = listLayout.gap = 12 * appModel.scale;
			
			list = new List();
			list.layout = listLayout;
			list.layoutData = new AnchorLayoutData(120 * appModel.scale,0,0,0);
			list.horizontalScrollPolicy = list.verticalScrollPolicy = ScrollPolicy.OFF;
			list.addEventListener(Event.CHANGE, list_changeHandler);
			addChild(list);
		}

		override protected function commitData():void
		{
			if(_firstCommit)

				_firstCommit = false;

			super.commitData();
			line = _data as ShopLine;
			
			headerDisplay.label = loc("exchange_title_" + line.category);
			descriptionDisplay.visible = false;
			
			var CELL_SIZE:int = 480 * appModel.scale;
			switch( line.category )
			{
				case ExchangeType.S_20_BUILDING:
					descriptionDisplay.visible = true;
					descriptionDisplay.text = loc("exchange_description_" + line.category);
					CELL_SIZE = 460 * appModel.scale;
					listLayout.typicalItemWidth = width-listLayout.padding * 2 ;
					list.itemRendererFactory = function ():IListItemRenderer{ return new SpecialExchangeItemRenderer();}
					list.addEventListener(FeathersEventType.END_INTERACTION, list_endSpecialExchangeHandler);
					break;
				
				case ExchangeType.S_30_CHEST:
					CELL_SIZE = 620 * appModel.scale;
					listLayout.typicalItemWidth = (width-listLayout.gap*4) / 3 ; 
					list.itemRendererFactory = function ():IListItemRenderer{ return new ChestExchangeItemRenderer();}
					break;
				
				default:
					CELL_SIZE = 480 * appModel.scale;
					listLayout.typicalItemWidth = (width-listLayout.gap*4) / 3 ; 
					list.itemRendererFactory = function ():IListItemRenderer{ return new CurrencyExchangeItemRenderer();}
					break;
			}
			
			height = CELL_SIZE * Math.ceil(line.items.length/listLayout.requestedColumnCount) + headerDisplay.height + ( descriptionDisplay.visible ? descriptionDisplay.height : 0 ); 
			listLayout.typicalItemHeight = CELL_SIZE - listLayout.gap*2;
			
			list.dataProvider = new ListCollection(line.items);
		}
		
		private function list_endSpecialExchangeHandler(event:Event):void
		{
			if( event.data is ExchangeItem )
				owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, event.data);
		}	
		
		private function list_changeHandler(event:Event):void
		{
			if( list.selectedItem == null || line.category == ExchangeType.S_20_BUILDING )
				return;
			var ei:ExchangeItem = game.exchanger.items.get(list.selectedItem as int);
			if(!ei.enabled)
				return;
			ei.enabled = false;
			owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, ei);
			
			list.removeEventListener(Event.CHANGE, list_changeHandler);
			list.selectedIndex = -1;
			list.addEventListener(Event.CHANGE, list_changeHandler);
		}		

	}
}