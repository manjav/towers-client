package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.controls.Devider;
	import com.gerantech.towercraft.controls.FastList;
	import com.gerantech.towercraft.controls.items.CardItemRenderer;
	import com.gerantech.towercraft.views.BattleFieldView;
	import com.gerantech.towercraft.views.decorators.BuildingDecorator;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.LayoutGroup;
	import feathers.controls.ScrollBarDisplayMode;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.TiledRowsLayout;
	
	public class DeckScreen extends BaseCustomScreen
	{
		private var battleField:BattleFieldView;
		
		private var deckLayout:TiledRowsLayout;
		private var deckList:FastList;
		private var draggableTower:BuildingDecorator;
		private var editOverlay:LayoutGroup;
		private var selectedCardBounds:Rectangle;
		private var dragFrom:int;
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			
			battleField = new BattleFieldView();
			battleField.layoutData = new AnchorLayoutData(stage.width/3,0,NaN,0);
			addChild(battleField);

			editOverlay = new Devider();
			editOverlay.layout = new AnchorLayout();
			editOverlay.layoutData = new AnchorLayoutData(0, 0, stage.width/3*2, 0);
			addChild(editOverlay);
			
			deckLayout = new TiledRowsLayout();
			deckLayout.useSquareTiles = false;
			deckLayout.gap = 1
			
			deckList = new FastList();
			deckList.layout = deckLayout;
			deckList.layoutData = new AnchorLayoutData(0, 0, 0, 0);
			
			deckList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
			//deckList.snapToPages = true;
			//deckList.pageHeight = 200
			deckList.itemRendererFactory = function ():IListItemRenderer
			{
				return new CardItemRenderer();
			}
			deckList.dataProvider = new ListCollection(player.get_buildingsLevel());
			//deckList.addEventListener(Event.READY, deckList_changeHandler);
			editOverlay.addChild(deckList);
			
			//addEventListener(TouchEvent.TOUCH, touchHandler);
			//addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionInCompleteHandler);
		}
		
		/*private function transitionInCompleteHandler():void
		{
			removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionInCompleteHandler);
			battleField.addDrops();
			//battleField.readyForEdit();
		}
		
		private function deckList_changeHandler(event:Event):void
		{
			var item:CardItemRenderer = event.data as CardItemRenderer;
			
			// create transition in data
			var ti:PopupTransitionData = new PopupTransitionData();
			ti.transition = Transitions.EASE_OUT_BACK;
			ti.sourceAlpha = 1;
			ti.sourceBound = item.getBounds(this);
			ti.destinationConstrain = this.getBounds(stage);
			ti.destinationBound = new Rectangle(ti.sourceBound.x-10, ti.sourceBound.y-40, ti.sourceBound.width+20, ti.sourceBound.height+80);
			
			// create transition out data
			var to:PopupTransitionData = new PopupTransitionData();
			to.sourceAlpha = 1;
			to.sourceBound = ti.destinationBound.clone();
			to.destinationBound = ti.sourceBound.clone();
			
			var details:TowerSelectPopup = new TowerSelectPopup();
			details.tower = item.data  as Tower;
			details.transitionIn = ti;
			details.transitionOut = to;
			details.addEventListener(Event.CLOSE, details_closeHandler);
			details.addEventListener(Event.SELECT, details_selectHandler);
			//details.addEventListener(Event.UPDATE, details_updateHandler);
			addChild(details);
			function details_closeHandler():void
			{
				details.removeEventListener(Event.CLOSE, details_closeHandler);
				details.removeEventListener(Event.SELECT, details_selectHandler);
				//details.removeEventListener(Event.UPDATE, details_updateHandler);
				deckList.selectedIndex = -1;
			}
			
			selectedCardBounds = ti.sourceBound;
		}
		
		private function details_selectHandler(event:Event):void
		{
			deckList.visible = false;
			var dt:TowerDecorator = new TowerDecorator(event.data as Tower, true);
			//dt.x = width/2;
			//dt.y = editOverlay.height/2;
			editOverlay.addChild(dt);
			
			dt.x = selectedCardBounds.x+selectedCardBounds.width/2;
			dt.y = selectedCardBounds.y+selectedCardBounds.height/2;
			Starling.juggler.tween(dt, 0.6, {x:width/2, y:editOverlay.height/2, transition: Transitions.EASE_OUT_BACK});
		}
		
		private function touchHandler(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this);
			if(touch == null)
				return;
			
			if(touch.phase == TouchPhase.BEGAN)
			{
				dragFrom = -1;
				//trace(touch.target, 0)
				if(touch.target.parent is TowerDecorator)
				{
					draggableTower = touch.target.parent as TowerDecorator;
					dragFrom = 0;
				}
				else if(touch.target is PlaceDecorator)
				{
					draggableTower = PlaceDecorator(touch.target).towerDecorator;
					dragFrom = 1;
				}
				
				if(draggableTower != null)
					editOverlay.addChild(draggableTower);
			}
			else if(draggableTower != null)
			{
				if(touch.phase == TouchPhase.MOVED)
				{
					draggableTower.x = touch.globalX;
					draggableTower.y = touch.globalY;
				}
				else if(touch.phase == TouchPhase.ENDED)
				{
					var dest:DisplayObject = battleField.dropTargets.contain(touch.globalX, touch.globalY);
					if(dest is PlaceDecorator)
					{
						var place:PlaceDecorator = dest as PlaceDecorator;
						battleField.setTower(place, draggableTower);
						deckList.visible = true;
						draggableTower = null;
						return;
					}
					if(dragFrom == 0)
					{
						draggableTower.x = width/2;
						draggableTower.y = editOverlay.height/2;
					}
					else if(dragFrom == 1)
					{
						battleField.setTower(draggableTower.place, draggableTower);
					}
					draggableTower = null;
				}
			}
		}
		*/
	}
}