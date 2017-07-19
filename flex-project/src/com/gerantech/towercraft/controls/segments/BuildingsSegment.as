package com.gerantech.towercraft.controls.segments
{
	import com.gerantech.towercraft.controls.FastList;
	import com.gerantech.towercraft.controls.items.BuildingItemRenderer;
	import com.gerantech.towercraft.controls.overlays.TransitionData;
	import com.gerantech.towercraft.controls.overlays.UpgradeOverlay;
	import com.gerantech.towercraft.controls.popups.BuildingDetailsPopup;
	import com.gerantech.towercraft.controls.popups.RequirementConfirmPopup;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gt.towers.buildings.Building;
	import com.gt.towers.constants.BuildingType;
	import com.gt.towers.constants.ExchangeType;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.ScrollBarDisplayMode;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.TiledRowsLayout;
	
	import starling.animation.Transitions;
	import starling.events.Event;
	
	public class BuildingsSegment extends Segment
	{
		private var buildingslist:FastList;
		private var listLayout:TiledRowsLayout;
		
		override protected function initialize():void
		{
			super.initialize();
			
			layout = new AnchorLayout();
			listLayout = new TiledRowsLayout();
			listLayout.padding = listLayout.gap = 16 * appModel.scale;
			listLayout.paddingTop = 120 * appModel.scale;
			listLayout.useSquareTiles = false;
			listLayout.requestedColumnCount = 4;
			listLayout.typicalItemWidth = (width -listLayout.gap*(listLayout.requestedColumnCount+1)) / listLayout.requestedColumnCount;
			listLayout.typicalItemHeight = listLayout.typicalItemWidth * 1.6;
			
			buildingslist = new FastList();
			buildingslist.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
			buildingslist.layout = listLayout;
			buildingslist.layoutData = new AnchorLayoutData(0,0,0,0);
			buildingslist.itemRendererFactory = function():IListItemRenderer { return new BuildingItemRenderer(); }
			buildingslist.addEventListener(FeathersEventType.FOCUS_IN, list_changeHandler);
			addChild(buildingslist);

			updateBuildingData();
		}
		
		private function updateBuildingData():void
		{
			var buildings:Vector.<int> = BuildingType.getAll().keys();
			var buildingArray:Array = new Array();
			while(buildings.length > 0)
				buildingArray.push(buildings.pop());
			buildingArray.sort();		
			buildingslist.dataProvider = new ListCollection(buildingArray);
			/*for each ( var b:int in buildingArray)
				if(player.buildings.exists(b))
					trace("buildings", b, player.buildings.get(b).level);*/
		}
		
		private function list_changeHandler(event:Event):void
		{
			var item:BuildingItemRenderer = event.data as BuildingItemRenderer;

			if( !player.buildings.exists( item.data as int) )
			{
				appModel.navigator.addLog(loc("unlocked_at_arena", [loc("arena_title_"+game.unlockedBuildingAt(item.data as int ))]));
				return;
			}
			
			// create transition in data
			var ti:TransitionData = new TransitionData();
			ti.transition = Transitions.EASE_OUT_BACK;
			ti.sourceAlpha = 1;
			ti.sourceBound = item.getBounds(this);
			ti.destinationConstrain = this.getBounds(stage);
			ti.destinationBound = new Rectangle(width*0.1, height*0.3, width*0.8, height*0.6);

			// create transition out data
			var to:TransitionData = new TransitionData();
			to.sourceAlpha = 1;
			to.sourceBound = ti.destinationBound.clone();
			to.destinationBound = ti.sourceBound.clone();

			var details:BuildingDetailsPopup = new BuildingDetailsPopup();
			details.buildingType = item.data as int;
			details.transitionIn = ti;
			details.transitionOut = to;
			details.addEventListener(Event.CLOSE, details_closeHandler);
			appModel.navigator.addChild(details);
			details.addEventListener(Event.UPDATE, details_updateHandler);
			function details_closeHandler():void
			{
				buildingslist.selectedIndex = -1;
			}
		}
		
		private function details_updateHandler(event:Event):void
		{
			var building:Building = event.data as Building;
			var confirmedHards:int = 0;
			if( !player.has(building.get_upgradeRequirements()) )
			{
				var confirm:RequirementConfirmPopup = new RequirementConfirmPopup(loc("popup_resourcetogem_message"), building.get_upgradeRequirements());
				confirm.data = building;
				confirm.addEventListener(FeathersEventType.ERROR, upgradeConfirm_errorHandler);
				confirm.addEventListener(Event.SELECT, upgradeConfirm_selectHandler);
				appModel.navigator.addChild(confirm);
				return;
			}
			
			seudUpgradeRequest(building, 0);
		}
		
		private function upgradeConfirm_errorHandler(event:Event):void
		{
			appModel.navigator.addLog("ssdf sddflkds");
			dispatchEventWith(FeathersEventType.ENTER, true, ExchangeType.S_0_HARD);
		}
		private function upgradeConfirm_selectHandler(event:Event):void
		{
			var confirm:RequirementConfirmPopup = event.currentTarget as RequirementConfirmPopup;
			seudUpgradeRequest(confirm.data as Building, exchanger.toHard(player.deductions(confirm.requirements)));
		}
		
		private function seudUpgradeRequest(building:Building, confirmedHards:int):void
		{
			if(!building.upgrade(confirmedHards))
				return;
			
			var sfs:SFSObject = new SFSObject();
			sfs.putInt("type", building.type);
			SFSConnection.instance.sendExtensionRequest(SFSCommands.BUILDING_UPGRADE, sfs);
			
			var upgradeOverlay:UpgradeOverlay = new UpgradeOverlay();
			upgradeOverlay.building = building;
			appModel.navigator.addChild(upgradeOverlay);
			
			updateBuildingData();
		}
	}
}