package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.Main;
	import com.gerantech.towercraft.controls.Devider;
	import com.gerantech.towercraft.controls.FastList;
	import com.gerantech.towercraft.controls.buttons.ExchangeButton;
	import com.gerantech.towercraft.controls.headers.ScreenHeader;
	import com.gerantech.towercraft.controls.items.QuestItemRenderer;
	import com.gerantech.towercraft.controls.overlays.WaitingOverlay;
	import com.gerantech.towercraft.models.tutorials.TutorialData;
	import com.gerantech.towercraft.models.tutorials.TutorialTask;
	import com.gerantech.towercraft.models.vo.Quest;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	import com.gt.towers.battle.fieldes.FieldData;
	import com.gt.towers.battle.fieldes.PlaceData;
	import com.gt.towers.utils.lists.PlaceDataList;
	
	import flash.utils.setTimeout;
	
	import feathers.controls.LayoutGroup;
	import feathers.controls.ScrollPolicy;
	import feathers.controls.StackScreenNavigatorItem;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.VerticalLayout;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;

	public class QuestsScreen extends BaseCustomScreen
	{
		private var listLayout:VerticalLayout;
		private var list:FastList;
		private var header:ScreenHeader;
		
		private var headerSize:int = 0;
		private var startScrollBarIndicator:Number = 0;

		override protected function initialize():void
		{
			super.initialize();
			//backgroundSkin = new Quad(1,1, BaseMetalWorksMobileTheme.CHROME_COLOR);
			layout = new AnchorLayout();
			
			headerSize = 150 * appModel.scale;

			listLayout = new VerticalLayout();
			listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
			listLayout.padding = 24 * appModel.scale;	
			listLayout.paddingTop = headerSize+listLayout.padding;
			listLayout.useVirtualLayout = true;
			listLayout.typicalItemHeight = 164 * appModel.scale;;
			listLayout.gap = 12 * appModel.scale;	
			
			list = new FastList();
			list.layout = listLayout;
			list.layoutData = new AnchorLayoutData(0,0,headerSize,0);
			list.verticalScrollPolicy = player.inTutorial() ? ScrollPolicy.OFF : ScrollPolicy.AUTO;
			list.itemRendererFactory = function():IListItemRenderer
			{
				return new QuestItemRenderer();
			}
			list.dataProvider = getQuestsData();
			list.addEventListener(Event.CHANGE, list_changeHandler);
			setTimeout(list.addEventListener, 100, Event.SCROLL, list_scrollHandler);
			addChild(list);
			
			header = new ScreenHeader(loc("map-gold-leaf"));
			header.height = headerSize;
			header.layoutData = new AnchorLayoutData(NaN,0,NaN,0);
			addChild(header);
			
			var footer:LayoutGroup = new LayoutGroup();
			footer.backgroundSkin = new Image(appModel.theme.tabUpSkinTexture);
			Image(footer.backgroundSkin).scale9Grid = BaseMetalWorksMobileTheme.TAB_SCALE9_GRID;
			footer.height = headerSize;
			footer.layoutData = new AnchorLayoutData(NaN,0,0,0);
			addChild(footer);
			
			var closeButton:ExchangeButton = new ExchangeButton();
			closeButton.height = 110 * appModel.scale;
			closeButton.layoutData = new AnchorLayoutData(NaN, NaN, 18*appModel.scale, NaN, 0);
			closeButton.addEventListener(Event.TRIGGERED, backButtonHandler);
			closeButton.label = loc("close_button");
			addChild(closeButton);
		}
		
		private function list_scrollHandler(event:Event):void
		{
			var scrollPos:Number = Math.max(0,list.verticalScrollPosition);
			var changes:Number = startScrollBarIndicator-scrollPos;
			header.y = Math.max(-headerSize, Math.min(0, header.y+changes));
			startScrollBarIndicator = scrollPos;
		}

		
		override protected function transitionInCompleteHandler(event:Event):void
		{
			super.transitionInCompleteHandler(event);
			showTutorials();
		}
		
		
		private function showTutorials():void
		{
			list.scrollToDisplayIndex(player.get_questIndex(), 0.5);
			var lastQuest:FieldData = game.fieldProvider.fields.get( "quest_" + player.get_questIndex() );
			
			trace("inTutorial:", player.inTutorial(), lastQuest.name, "hasStart:", lastQuest.hasStart, "hasIntro:", lastQuest.hasIntro, "hasFinal:", lastQuest.hasFinal, lastQuest.times);
			if(player.get_questIndex() == 4 && player.nickName == "guest")
			{
				backButtonHandler();
				return;	
			}
			
			var tutorialData:TutorialData = new TutorialData("");
			if( game.fieldProvider.fields.get( "quest_" + player.get_questIndex() ).hasStart )
				tutorialData.tasks.push(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_quest_" + player.get_questIndex() + "_start",  null, 200));
			
			if(player.inTutorial())
			{
				var pl:PlaceDataList = new PlaceDataList();
				var py:Number = (listLayout.typicalItemHeight+listLayout.gap)*player.get_questIndex()+listLayout.typicalItemHeight/2+listLayout.padding;
				pl.push(new PlaceData(0, stage.stageWidth/2/appModel.scale, py/appModel.scale, 0, 0, ""));
				tutorialData.tasks.push(new TutorialTask(TutorialTask.TYPE_TOUCH, null, pl, 200));
			}
			
			tutorials.show(this, tutorialData);
		}
		
		private function list_changeHandler(event:Event):void
		{
			var item:StackScreenNavigatorItem = appModel.navigator.getScreen( Main.BATTLE_SCREEN );
			item.properties.requestField = list.selectedItem as Quest ;
			item.properties.waitingOverlay = new WaitingOverlay() ;
			appModel.navigator.addOverlay(item.properties.waitingOverlay);

			appModel.navigator.pushScreen( Main.BATTLE_SCREEN ) ;
		}
		
		private function getQuestsData():ListCollection
		{
			var field:FieldData;
			var source:Array = new Array();
			
			var fkeys:Vector.<String> = game.fieldProvider.fields.keys();
			for( var i:int=0; i<fkeys.length; i++)
			{
				field = game.fieldProvider.fields.get(fkeys[i]);
				if(field.isQuest)
				{
					source.push( new Quest(field, field.index>player.get_questIndex() ? -1 : player.quests.get(field.index) ) );
				}
			}
			source.sortOn("index", Array.NUMERIC);
			return new ListCollection(source);
		}
	}
}