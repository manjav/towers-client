package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.segments.BuildingsSegment;
import com.gerantech.towercraft.controls.segments.ExchangeSegment;
import com.gerantech.towercraft.controls.segments.MainSegment;
import com.gerantech.towercraft.controls.segments.Segment;
import com.gt.towers.constants.PageType;

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.events.Event;
	
	
	public class DashboardPageItemRenderer extends LayoutGroupListItemRenderer
	{
		private var _firstCommit:Boolean = true;
		private var segment:Segment;
		
		public function DashboardPageItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();;
			
/*			var q:Quad = new Quad(1,1);
			addChild(q);*/
			
		}
		
		override protected function commitData():void
		{
			if(_firstCommit)
			{
				width = _owner.width
				height = _owner.height;
				_firstCommit = false;
				_owner.addEventListener(FeathersEventType.SCROLL_COMPLETE, owner_scrollCompleteHandler);
			}
			
			super.commitData();
			
			if( _data == null )
				return;
			
			if(segment != null)
				return;
			
			switch(index)
			{
				case PageType.S0_SHOP:
					segment = new ExchangeSegment();
					break;
				case PageType.S1_BATTLE:
					segment = new MainSegment();
					break;
				case PageType.S2_DECK:
					segment = new BuildingsSegment();
					break;
				
				default:
					break;
			}
			
			if(segment != null)
			{
				segment.layoutData = new AnchorLayoutData(0,0,0,0);
				segment.width = _owner.width
				segment.height = _owner.height;
				addChild(segment);
			}
		}
		
		private function owner_scrollCompleteHandler(event:Event):void
		{
			visible = stage.getBounds(this).x == 0;
			if(visible)
			{
				owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, index); 
//
			}
		}
	
		
	}
}