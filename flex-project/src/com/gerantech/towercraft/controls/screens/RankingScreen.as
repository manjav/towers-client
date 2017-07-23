package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.controls.FastList;
	import com.gerantech.towercraft.controls.items.RankItemRenderer;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;

	public class RankingScreen extends BaseCustomScreen
	{
		private var list:FastList;

		private var _listCollection:ListCollection;
		public function RankingScreen()
		{
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			layout = new AnchorLayout();
			
			var padding:int = 12 * appModel.scale;
			
			list = new FastList();
			list.itemRendererFactory = function():IListItemRenderer { return new RankItemRenderer(); }
			list.dataProvider = _listCollection;
			list.layoutData = new AnchorLayoutData(padding, padding, padding, padding);
			addChild(list);
			
			SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
		}

		protected function sfsConnection_extensionResponseHandler(event:SFSEvent):void
		{
			if( event.params.cmd != SFSCommands.RANK )
				return;
			
			SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
			var params:SFSObject = event.params.params;
			list.dataProvider = new ListCollection(SFSArray(params.getSFSArray("list")).toArray());
		}
		
		override public function dispose():void
		{
			SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
			super.dispose();
		}
		
		
	}
}