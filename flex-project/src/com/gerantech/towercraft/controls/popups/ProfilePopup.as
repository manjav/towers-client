package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.controls.FastList;
	import com.gerantech.towercraft.controls.buttons.CustomButton;
	import com.gerantech.towercraft.controls.items.BuildingItemRenderer;
	import com.gerantech.towercraft.controls.items.ProfileBuildingItemRenderer;
	import com.gerantech.towercraft.controls.items.ProfileFeatureItemRenderer;
	import com.gerantech.towercraft.controls.overlays.TransitionData;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.controls.texts.ShadowLabel;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.constants.BuildingType;
	import com.smartfoxserver.v2.core.SFSEvent;
	import com.smartfoxserver.v2.entities.data.ISFSArray;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.ScrollBarDisplayMode;
	import feathers.controls.ScrollPolicy;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.TiledRowsLayout;
	
	import starling.core.Starling;
	import starling.events.Event;

	public class ProfilePopup extends SimplePopup 
	{
		private var playerName:String;
		
		private var playerData:ISFSObject;
		private var featuresData:ISFSArray;
		private var buildingsData:ISFSArray;
		
		public function ProfilePopup(playerName:String, playerId:int, adminMode:Boolean=false)
		{
			this.playerName = playerName;
			
			var params:SFSObject = new SFSObject();
			params.putInt("id", playerId);
			if( adminMode )
				params.putBool("am", true);
			SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_responceHandler);
			SFSConnection.instance.sendExtensionRequest(SFSCommands.PROFILE, params);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			transitionOut.destinationBound = transitionIn.sourceBound = new Rectangle(stage.stageWidth*0.05, stage.stageHeight*0.10, stage.stageWidth*0.9, stage.stageHeight*0.8);
			transitionIn.destinationBound = transitionOut.sourceBound = new Rectangle(stage.stageWidth*0.05, stage.stageHeight*0.05, stage.stageWidth*0.9, stage.stageHeight*0.9);
			rejustLayoutByTransitionData();
		}
		protected override function transitionInCompleted():void
		{
			super.transitionInCompleted();
			if( playerData != null )
				showProfile();
		}
		protected function sfsConnection_responceHandler(event:SFSEvent):void
		{
			if( event.params.cmd != SFSCommands.PROFILE )
				return;
			SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_responceHandler);
			playerData = event.params.params as SFSObject;
			featuresData = playerData.getSFSArray("features");
			buildingsData = playerData.getSFSArray("buildings");
			
			if( transitionState >= TransitionData.STATE_IN_FINISHED )
				showProfile();
		}
		
		private function showProfile():void
		{
			
			var iconDisplay:ImageLoader = new ImageLoader();
			iconDisplay.width = padding * 4;
			iconDisplay.height = padding * 6;
			iconDisplay.source = Assets.getTexture("arena-"+Math.min(8, player.get_arena(0)), "gui");
			iconDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN);
			addChild(iconDisplay);
			
			var nameDisplay:ShadowLabel = new ShadowLabel(playerName, 1, 0, null, null, true, "center", 1);
			nameDisplay.layoutData = new AnchorLayoutData(padding*1.4, appModel.isLTR?NaN:padding*6, NaN, appModel.isLTR?padding*6:NaN);
			addChild(nameDisplay);
			
			var tagDisplay:RTLLabel = new RTLLabel("#"+playerData.getText("tag"), 0xAABBBB, null, "ltr", true, null, 0.8);
			tagDisplay.layoutData = new AnchorLayoutData(padding*3, appModel.isLTR?NaN:padding*6, NaN, appModel.isLTR?padding*6:NaN);
			addChild(tagDisplay);
			
			var closeButton:CustomButton = new CustomButton();
			closeButton.label = "";
			closeButton.addEventListener(Event.TRIGGERED, close_triggeredHandler);
			closeButton.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0);
			addChild(closeButton);
			closeButton.y = height - closeButton.height - padding*1.6;
			closeButton.alpha = 0;
			closeButton.height = 110 * appModel.scale;
			closeButton.label = loc("close_button");
			Starling.juggler.tween(closeButton, 0.2, {delay:0.2, alpha:1, y:height - closeButton.height - padding});

			// features
			var featureList:List = new List();
			featureList.horizontalScrollPolicy = featureList.verticalScrollPolicy = ScrollPolicy.OFF;
			featureList.itemRendererFactory = function ():IListItemRenderer { return new ProfileFeatureItemRenderer(); }
			featureList.dataProvider = new ListCollection(SFSArray(playerData.getSFSArray("features")).toArray());
			featureList.layoutData = new AnchorLayoutData(padding*7, padding*2, NaN, padding*2);
			addChild(featureList);
			
			// buildings
			var listLayout:TiledRowsLayout = new TiledRowsLayout();
			listLayout.padding = padding;
			listLayout.gap = padding * 0.5;
			listLayout.useSquareTiles = false;
			listLayout.requestedColumnCount = 4;
			listLayout.typicalItemWidth = (width -listLayout.padding*(listLayout.requestedColumnCount+1)) / listLayout.requestedColumnCount;
			listLayout.typicalItemHeight = listLayout.typicalItemWidth * 1.5;
			
			var buildingslist:FastList = new FastList();
			buildingslist.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
			buildingslist.layout = listLayout;
			buildingslist.layoutData = new AnchorLayoutData(padding*7 + featureList.dataProvider.length*padding*1.8, 0, padding*5, 0);
			buildingslist.itemRendererFactory = function():IListItemRenderer { return new ProfileBuildingItemRenderer(); }
			buildingslist.dataProvider = getBuildingData();
			addChild(buildingslist);
		}
		
		public function getBuildingData():ListCollection
		{
			var ret:ListCollection = new ListCollection();
			var buildings:Vector.<int> = new Vector.<int>();// BuildingType.getAll().keys();
			var buildingArray:Array = new Array();
			while( buildings.length > 0 )
			{
				var b:int = buildings.pop();
				buildingArray.push({type:b, level:getLevel(b)});
			}
			buildingArray.sortOn("type");
			return new ListCollection(buildingArray);
		}
		
		private function getLevel(type:int):int
		{
			var bLen:int = buildingsData.size()
			for (var i:int = 0; i < bLen; i++) 
				if( buildingsData.getSFSObject(i).getInt("type") == type )
					return buildingsData.getSFSObject(i).getInt("level");
			return 0;
		}		
		
		private function close_triggeredHandler(event:Event):void
		{
			close();
		}
	}
}