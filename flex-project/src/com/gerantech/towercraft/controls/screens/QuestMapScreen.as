package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.Main;
	import com.gerantech.towercraft.controls.buttons.SimpleButton;
	import com.gerantech.towercraft.controls.floatings.MapElementFloating;
	import com.gerantech.towercraft.controls.items.QuestMapItemRenderer;
	import com.gerantech.towercraft.controls.overlays.TransitionData;
	import com.gerantech.towercraft.controls.popups.QuestDetailsPopup;
	import com.gt.towers.battle.fieldes.FieldData;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	import feathers.controls.List;
	import feathers.controls.ScrollBarDisplayMode;
	import feathers.controls.ScrollPolicy;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.animation.Transitions;
	import starling.display.Quad;
	import starling.events.Event;

	public class QuestMapScreen extends BaseCustomScreen
	{

		private var list:List;
		public function QuestMapScreen()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			backgroundSkin = new Quad(1,1, 0xFFDF78);
			QuestMapItemRenderer.questIndex = player.get_questIndex();

			list = new List();
			list.layoutData = new AnchorLayoutData(0,0,0,0);
			list.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
			list.verticalScrollPolicy = player.inTutorial() ? ScrollPolicy.OFF : ScrollPolicy.AUTO;
			list.decelerationRate = 0.98
			list.itemRendererFactory = function():IListItemRenderer { return new QuestMapItemRenderer(); }
			list.addEventListener(Event.SELECT, list_selectHandler);
			list.elasticity = 0.03;
			list.dataProvider = getQuestsData();
			//setTimeout(list.addEventListener, 100, Event.SCROLL, list_scrollHandler);
			addChild(list);
/*
			var closeButton:CustomButton = new CustomButton();
			closeButton.height = 110 * appModel.scale;
			closeButton.layoutData = new AnchorLayoutData(NaN, NaN, 18*appModel.scale, NaN, 0);
			closeButton.addEventListener(Event.TRIGGERED, backButtonHandler);
			closeButton.label = loc("close_button");
			addChild(closeButton);*/
		}
		
		private function list_selectHandler(event:Event):void
		{
			var btn:SimpleButton = event.data as SimpleButton;
			var index:int = int(btn.name)
			var popupWidth:int = 320 * appModel.scale;
			
			// create transitions data
			var ti:TransitionData = new TransitionData();
			var to:TransitionData = new TransitionData();
			to.destinationAlpha = ti.sourceAlpha = 0;
			ti.transition = Transitions.EASE_OUT_BACK;
			to.destinationBound = ti.sourceBound = new Rectangle(btn.x-popupWidth/1.8, btn.y-200*appModel.scale, popupWidth*1.6, popupWidth);
			ti.destinationAlpha = to.sourceAlpha = 1;
			to.sourceBound = ti.destinationBound = new Rectangle(btn.x-popupWidth/2, btn.y-200*appModel.scale, popupWidth, popupWidth);
			
			var detailsPopup:QuestDetailsPopup = new QuestDetailsPopup(index);
			detailsPopup.transitionIn = ti;
			detailsPopup.transitionOut = to;
			detailsPopup.addEventListener(Event.SELECT, floating_selectHandler);
			addChild(detailsPopup);
			function floating_selectHandler(event:Event):void
			{
			}
		}
		
		private function getQuestsData():ListCollection
		{
			var field:FieldData;
			var source:Array = new Array();
			
			var fields:Vector.<FieldData> = game.fieldProvider.shires.values();
			for( var i:int=0; i < fields.length; i++)
				source.push( fields[i] );
			source.sortOn("index", Array.NUMERIC|Array.DESCENDING);
			return new ListCollection(source);
		}
		
	}
}