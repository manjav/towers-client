package com.gerantech.towercraft.controls.items.exchange
{
	import com.gerantech.towercraft.controls.ExchangeHeader;
	import com.gerantech.towercraft.controls.items.BaseCustomItemRenderer;
	import com.gerantech.towercraft.models.vo.ShopLine;
	import com.gt.towers.constants.ExchangeType;
	import com.gt.towers.exchanges.ExchangeItem;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.List;
	import feathers.controls.ScrollPolicy;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalAlign;
	
	import starling.events.Event;

	public class ExchangeCategoryItemRenderer extends BaseCustomItemRenderer 
	{
		private var _firstCommit:Boolean = true;
		private var line:ShopLine;
		private var list:List;

		private var listLayout:HorizontalLayout;
		private var header:ExchangeHeader;
		public function ExchangeCategoryItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			
			header = new ExchangeHeader("shop-line-header", new Rectangle(22,6,1,2), 48*appModel.scale);
			header.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
			header.height = 112 * appModel.scale;
			addChild(header);
			
			listLayout = new HorizontalLayout();
			listLayout.verticalAlign = VerticalAlign.JUSTIFY;
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
			
			header.label = loc("exchange_title_" + line.category);
			
			height = 620 * appModel.scale ; 
			listLayout.typicalItemWidth = (width-listLayout.gap*4) / 3 ; 
			switch(line.category)
			{
				case ExchangeType.S_20_BUILDING:
					height = 460 * appModel.scale ; 
					listLayout.typicalItemWidth = width-listLayout.padding * 2 ;
					list.itemRendererFactory = function ():IListItemRenderer{ return new SpecialExchangeItemRenderer();}
					break;
				
				case ExchangeType.S_30_CHEST:
					height = 720 * appModel.scale ; 
					list.itemRendererFactory = function ():IListItemRenderer{ return new ChestExchangeItemRenderer();}
					break;
				
				default:
					list.itemRendererFactory = function ():IListItemRenderer{ return new CurrencyExchangeItemRenderer();}
					break;
			}
			list.dataProvider = new ListCollection(line.items);
		}
		
		
		private function list_changeHandler(event:Event):void
		{
			var ei:ExchangeItem = core.get_exchanger().bundlesMap.get(list.selectedItem as int);
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