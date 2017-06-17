package com.gerantech.towercraft.controls.segments
{
	import com.gerantech.towercraft.controls.FastList;
	
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayout;

	public class RankingSegment extends Segment
	{
		private var list:FastList;

		private var _listCollection:ListCollection;
		public function RankingSegment()
		{
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			layout = new AnchorLayout();
			_listCollection = new ListCollection();
			
			/*list = new FastList();
			list.itemRendererFactory = function():IListItemRenderer
			{
				return new RankItemRenderer();
			}
			list.dataProvider = _listCollection;
			list.layoutData = new AnchorLayoutData(0,0,0,0);
			addChild(list);
			
			var extraInfo:SFSObject = new SFSObject();
			extraInfo.putUtfString(Commands.SFSOBJ_DATA_COMMAND, Commands.ORDER_GET_TOP_10);
			extraInfo.putInt(Commands.SFSOBJ_DATA_UID, int(Game.get_instance().get_player().get_id()));
		//	extraInfo.putByte(Commands.SFSOBJ_DATA_MSG_SENDER_ID, 0);
			SFSConnection.getInstance().addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
			SFSConnection.getInstance().sendExtensionRequest( Commands.REQ_ROOM, extraInfo );*/
		}

		/*protected function sfsConnection_extensionResponseHandler(event:SFSEvent):void
		{
			SFSConnection.getInstance().removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
			if(event.params.cmd == Commands.ORDER_GET_NEAR_RANKS || event.params.cmd == Commands.ORDER_GET_TOP_10)
				filllistCollection(event.params.params);
		}
		
		private function filllistCollection(sfsObject:SFSObject):void
		{
			var sfsList:ISFSArray = sfsObject.getSFSArray(Commands.SFSOBJ_DATA_KEY_2);
			var sObj:SFSObject;
			var rankData:RankData;
			var listSize:int = sfsList.size();
			for(var i:int = 0; i < sfsList.size(); i++) 
			{
				sObj = SFSObject(sfsList.getSFSObject(i));
				rankData = new RankData(sObj.getInt("id"), i + 1, sObj.getUtfString("nickname"), sObj.getInt("xp"), 0);
				_listCollection.addItem(rankData);
			}
		}*/

	}
}