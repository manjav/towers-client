package com.gerantech.towercraft.controls.screens
{
	import com.gerantech.towercraft.Main;
	import com.gerantech.towercraft.controls.items.QuestItemRenderer;
	import com.gerantech.towercraft.controls.overlays.WaitingOverlay;
	import com.gerantech.towercraft.models.tutorials.TutorialData;
	import com.gerantech.towercraft.models.tutorials.TutorialTask;
	import com.gerantech.towercraft.models.vo.Quest;
	import com.gt.towers.battle.fieldes.FieldData;
	import com.gt.towers.battle.fieldes.PlaceData;
	import com.gt.towers.utils.lists.PlaceDataList;
	
	import feathers.controls.ScrollPolicy;
	import feathers.controls.StackScreenNavigatorItem;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	
	import starling.events.Event;

	public class QuestsScreen extends ListScreen
	{
		override protected function initialize():void
		{
			title = loc("map-gold-leaf");
			super.initialize();
			
			list.verticalScrollPolicy = player.inTutorial() ? ScrollPolicy.OFF : ScrollPolicy.AUTO;
			list.itemRendererFactory = function():IListItemRenderer { return new QuestItemRenderer(); }
			list.dataProvider = getQuestsData();
		}
		
		override protected function transitionInCompleteHandler(event:Event):void
		{
			super.transitionInCompleteHandler(event);
			showTutorials();
		}
		private function showTutorials():void
		{
			list.scrollToDisplayIndex(player.get_questIndex(), 0.5);
			var lastQuest:FieldData = game.fieldProvider.quests.get( "quest_" + player.get_questIndex() );
			
			trace("inTutorial:", player.inTutorial(), lastQuest.name, "hasStart:", lastQuest.hasStart, "hasIntro:", lastQuest.hasIntro, "hasFinal:", lastQuest.hasFinal, lastQuest.times);
			if(player.get_questIndex() == 3 && player.nickName == "guest")
			{
				backButtonHandler();
				return;	
			}
			
			var tutorialData:TutorialData = new TutorialData("");
			if( game.fieldProvider.quests.get( "quest_" + player.get_questIndex() ).hasStart )
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
		
		protected override function list_changeHandler(event:Event):void
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
			
			var fkeys:Vector.<String> = game.fieldProvider.quests.keys();
			for( var i:int=0; i<fkeys.length; i++)
			{
				field = game.fieldProvider.quests.get(fkeys[i]);
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