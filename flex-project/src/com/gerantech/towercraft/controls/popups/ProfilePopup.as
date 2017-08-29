package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.controls.items.PlayerFeatureItemRenderer;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.List;
	import feathers.controls.ScrollPolicy;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayoutData;

	public class ProfilePopup extends MessagePopup //ConfirmPopup
	{
		
		public function ProfilePopup(playerName:String, playerId:int)
		{
			message = playerName;
			super(message)//, loc("friendship_friendly_battle"), loc("friendship_remove_friend"));
			
			var params:SFSObject = new SFSObject();
			params.putInt("id", playerId);
			SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_responceHandler);
			SFSConnection.instance.sendExtensionRequest(SFSCommands.PROFILE, params);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			closable = true;
			transitionIn.destinationBound = transitionIn.sourceBound = new Rectangle(stage.stageWidth*0.10, stage.stageHeight*0.3, stage.stageWidth*0.8, stage.stageHeight*0.35);
			transitionOut.destinationBound = transitionOut.sourceBound = new Rectangle(stage.stageWidth*0.10, stage.stageHeight*0.3, stage.stageWidth*0.8, stage.stageHeight*0.35);
			rejustLayoutByTransitionData();
			
		//	acceptButton.width = declineButton.width = width*0.4;
			container.layoutData = new AnchorLayoutData(padding, padding*2, NaN, padding*2);
		}
		
		protected function sfsConnection_responceHandler(event:SFSEvent):void
		{
			if( event.params.cmd != SFSCommands.PROFILE )
				return;
			SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_responceHandler);
			//trace(event.params.params.getDump())
			var featureList:List = new List();
			featureList.horizontalScrollPolicy = featureList.verticalScrollPolicy = ScrollPolicy.OFF;
			featureList.itemRendererFactory = function ():IListItemRenderer { return new PlayerFeatureItemRenderer(); }
			featureList.dataProvider = new ListCollection(SFSArray(SFSObject(event.params.params).getSFSArray("features")).toArray());
			container.addChild(featureList);
		}
	}
}