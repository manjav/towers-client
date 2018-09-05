package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.items.QuestItemRenderer;
import com.gt.towers.others.Quest;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import starling.events.Event;

public class QuestsScreen extends ListScreen
{
override protected function initialize():void
{
	title = loc("button_quests");
	super.initialize();
	
	listLayout.paddingLeft = listLayout.paddingRight = 10;
	listLayout.gap = 4;	
	list.itemRendererFactory = function():IListItemRenderer { return new QuestItemRenderer(); }
	list.dataProvider = new ListCollection(Quest.GET_ALL(player));
	
	appModel.navigator.addLog("بخش مأموریت ها بزودی فعال خواهد شد.");
}

override protected function list_changeHandler(event:Event):void
{
	super.list_changeHandler(event);
}
}
}