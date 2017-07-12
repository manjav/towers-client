package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.Main;
	import com.gerantech.towercraft.controls.FastList;
	import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
	import com.gerantech.towercraft.controls.items.QuestItemRenderer;
	import com.gerantech.towercraft.controls.overlays.WaitingOverlay;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.models.tutorials.TutorialData;
	import com.gerantech.towercraft.models.tutorials.TutorialTask;
	import com.gerantech.towercraft.models.vo.Quest;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	import com.gt.towers.battle.fieldes.FieldData;
	import com.gt.towers.battle.fieldes.PlaceData;
	import com.gt.towers.utils.lists.PlaceDataList;
	
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
		private var list:FastList;

		private var listLayout:VerticalLayout;

		override protected function initialize():void
		{
			super.initialize();
			backgroundSkin = new Quad(1,1, BaseMetalWorksMobileTheme.CHROME_COLOR);
			layout = new AnchorLayout();
			
			listLayout = new VerticalLayout();
			listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
			listLayout.useVirtualLayout = true;
			listLayout.typicalItemHeight = 164 * appModel.scale;;
			listLayout.padding = 24 * appModel.scale;	
			listLayout.gap = 12 * appModel.scale;	
			
			list = new FastList();
			list.layout = listLayout;
			list.layoutData = new AnchorLayoutData(0,0,0,0);
			list.itemRendererFactory = function():IListItemRenderer
			{
				return new QuestItemRenderer();
			}
			list.dataProvider = getQuestsData();
			list.addEventListener(Event.CHANGE, list_changeHandler);
			addChild(list);
			
			var backButton:SimpleLayoutButton = new SimpleLayoutButton();
			backButton.width = backButton.height = 240*appModel.scale;
			backButton.layoutData = new AnchorLayoutData(NaN, 0, 0, NaN);
			backButton.backgroundSkin = new Image(Assets.getTexture("tab-1", "gui"));
			backButton.addEventListener(Event.TRIGGERED, backButtonHandler);
			addChild(backButton);
		}
		
		override protected function transitionInCompleteHandler(event:Event):void
		{
			super.transitionInCompleteHandler(event);
			showTutorials();
		}
		
		
		private function showTutorials():void
		{
			list.scrollToDisplayIndex(player.get_questIndex(), 0.5);
			
			trace(player.inTutorial(), "quest screen", player.get_questIndex());
			if( !player.inTutorial())
			{
				if(player.get_questIndex() == 4 && player.nickName == "guest")
					backButtonHandler();
				return;	
			}
			var tutorialData:TutorialData = new TutorialData("");
			tutorialData.tasks.push(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_quest_" + player.get_questIndex() + "_start",  null, 200));
			var pl:PlaceDataList = new PlaceDataList();
			var py:Number = (listLayout.typicalItemHeight+listLayout.gap)*player.get_questIndex()+listLayout.typicalItemHeight/2+listLayout.padding;
			pl.push(new PlaceData(0, stage.stageWidth/2/appModel.scale, py/appModel.scale, 0, 0, ""));
			tutorialData.tasks.push(new TutorialTask(TutorialTask.TYPE_TOUCH, null, pl, 200));
			tutorials.show(this, tutorialData);
		}
		
		private function list_changeHandler(event:Event):void
		{
			var item:StackScreenNavigatorItem = appModel.navigator.getScreen( Main.BATTLE_SCREEN );
			item.properties.requestField = list.selectedItem as Quest ;
			item.properties.waitingOverlay = new WaitingOverlay() ;
			appModel.navigator.addChild(item.properties.waitingOverlay);
			appModel.navigator.pushScreen( Main.BATTLE_SCREEN ) ;
			appModel.navigator.addChild(item.properties.waitingOverlay);
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