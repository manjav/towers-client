package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.segments.BuildingsSegment;
import com.gerantech.towercraft.controls.segments.ExchangeSegment;
import com.gerantech.towercraft.controls.segments.FriendsSegment;
import com.gerantech.towercraft.controls.segments.LobbyChatSegment;
import com.gerantech.towercraft.controls.segments.LobbyCreateSegment;
import com.gerantech.towercraft.controls.segments.LobbySearchSegment;
import com.gerantech.towercraft.controls.segments.MainSegment;
import com.gerantech.towercraft.controls.segments.Segment;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.vo.TabItemData;
import com.gt.towers.constants.SegmentType;

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.events.Event;
	
	
	public class SegmentsItemRenderer extends LayoutGroupListItemRenderer
	{
		private var _firstCommit:Boolean = true;
		private var segment:Segment;
		
		public function SegmentsItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();;
		}
		
		override protected function commitData():void
		{
			if(_firstCommit)
			{
				width = _owner.width
				height = _owner.height;
				_firstCommit = false;
				_owner.addEventListener(FeathersEventType.SCROLL_START, owner_scrollStartHandler);
				_owner.addEventListener(FeathersEventType.SCROLL_COMPLETE, owner_scrollCompleteHandler);
			}
			
			super.commitData();
			
			if( _data == null )
				return;
			
			if(segment != null)
				return;
			
			var tab:TabItemData = _data as TabItemData;
			switch(tab.index)
			{
				case SegmentType.S0_SHOP:
					segment = new ExchangeSegment();
					break;
				case SegmentType.S1_MAP:
					segment = new MainSegment();
					break;
				case SegmentType.S2_DECK:
					segment = new BuildingsSegment();
					break;

				case SegmentType.S10_LOBBY_MAIN:
						segment = new LobbyChatSegment();
					break;
				case SegmentType.S11_LOBBY_SEARCH:
					segment = new LobbySearchSegment();
					break;
				case SegmentType.S12_LOBBY_CREATE:
					segment = new LobbyCreateSegment();
					break;
				case SegmentType.S13_FRIENDS:
					segment = new FriendsSegment();
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
		
		private function owner_scrollStartHandler(event:Event):void
		{
			visible = true;
			if( isSelected && segment != null && segment.initializeCompleted )
				segment.updateData();
		}
		
		private function owner_scrollCompleteHandler(event:Event):void
		{
			visible = stage.getBounds(this).x == 0;
			if( visible )
			{
				owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, index);
				if(!segment.initializeCompleted)
					segment.init();
			}
		}
	
		
	}
}