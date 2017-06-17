package com.gerantech.towercraft.controls.segments
{
	import com.gerantech.towercraft.controls.FastList;
	import com.gerantech.towercraft.controls.items.BuildingItemRenderer;
	import com.gerantech.towercraft.controls.overlays.TransitionData;
	import com.gerantech.towercraft.events.LoadingEvent;
	import com.gerantech.towercraft.managers.net.LoadingManager;
	import com.gt.towers.constants.BuildingType;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.AutoSizeMode;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.TiledRowsLayout;
	
	import starling.animation.Transitions;
	import starling.display.Quad;
	import starling.events.Event;
	
	public class BuildingsSegment extends Segment
	{
		private var weaponlist:FastList;
		private var listLayout:TiledRowsLayout;
		
		override protected function initialize():void
		{
			super.initialize();
			if(appModel.loadingManager.state <  LoadingManager.STATE_LOADED )
			{
				appModel.loadingManager.addEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
				return;
			}
			createElements();
		}
		
		protected function loadingManager_loadedHandler(event:LoadingEvent):void
		{
			appModel.loadingManager.removeEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
			createElements();
		}
		
		
		private function createElements():void
		{
		
			layout = new AnchorLayout();
			listLayout = new TiledRowsLayout();
			listLayout.padding = listLayout.gap = 10;
			listLayout.paddingBottom = listLayout.paddingTop = 50;
			listLayout.useSquareTiles = false;
			listLayout.requestedColumnCount = 4;
			listLayout.typicalItemWidth = (width -listLayout.gap*(listLayout.requestedColumnCount+1)) / listLayout.requestedColumnCount;
			listLayout.typicalItemHeight = listLayout.typicalItemWidth * 1.2;
			
			weaponlist = new FastList();
			weaponlist.layout = listLayout;
			weaponlist.layoutData = new AnchorLayoutData(0,0,0,0);
			weaponlist.itemRendererFactory = function():IListItemRenderer
			{
				return new BuildingItemRenderer();
			}
			//weaponlist.addEventListener(FeathersEventType.FOCUS_IN, list_changeHandler);
			addChild(weaponlist);

			var buildings:Vector.<int> = BuildingType.getAll().keys();
			var collection:Array = new Array();
			while(buildings.length > 0)
				collection.push(buildings.pop());
			collection.sort();			
			weaponlist.dataProvider = new ListCollection(collection);
		}
		
		private function list_changeHandler(event:Event):void
		{
			var item:BuildingItemRenderer = event.data as BuildingItemRenderer;
			
			// create transition in data
			var ti:TransitionData = new TransitionData();
			ti.transition = Transitions.EASE_OUT_BACK;
			ti.sourceAlpha = 1;
			ti.sourceBound = item.getBounds(this);
			ti.destinationConstrain = this.getBounds(stage);
			ti.destinationBound = new Rectangle(ti.sourceBound.x-10, ti.sourceBound.y-40, ti.sourceBound.width+20, ti.sourceBound.height+80);

			// create transition out data
			var to:TransitionData = new TransitionData();
			to.sourceAlpha = 1;
			to.sourceBound = ti.destinationBound.clone();
			to.destinationBound = ti.sourceBound.clone();
/*
			var details:WeaponSelectPopup = new WeaponSelectPopup();
			details.weaponType = item.data as int;
			details.transitionIn = ti;
			details.transitionOut = to;
			details.addEventListener(Event.CLOSE, details_closeHandler);
			addChild(details);
			//details.addEventListener(Event.ADDED, details_closeHandler);
			//details.addEventListener(Event.UPDATE, details_selectHandler);
			//PopUpManager.addPopUp(details);
			function details_closeHandler():void
			{
				weaponlist.selectedIndex = -1;
			}*/
		}
	}
}