package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.controls.FastList;
	import com.gerantech.towercraft.controls.buttons.CustomButton;
	import com.gerantech.towercraft.controls.headers.ScreenHeader;
	import com.gerantech.towercraft.controls.items.QuestItemRenderer;
	import com.gerantech.towercraft.controls.items.QuestMapItemRenderer;
	import com.gerantech.towercraft.models.vo.Quest;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	import com.gt.towers.battle.fieldes.FieldData;
	
	import flash.utils.setTimeout;
	
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.ScrollBarDisplayMode;
	import feathers.controls.ScrollPolicy;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalLayout;
	
	import starling.display.Image;
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
			backgroundSkin = new Quad(1,1, 0xFFDF78);

			QuestMapItemRenderer.questIndex = player.get_questIndex();

			list = new List();
			list.layoutData = new AnchorLayoutData(0,0,0,0);
			list.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
			list.verticalScrollPolicy = player.inTutorial() ? ScrollPolicy.OFF : ScrollPolicy.AUTO;
			list.itemRendererFactory = function():IListItemRenderer { return new QuestMapItemRenderer(); }
			list.elasticity = 0.03;
			list.dataProvider = getQuestsData();
			layout = new AnchorLayout();
			
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