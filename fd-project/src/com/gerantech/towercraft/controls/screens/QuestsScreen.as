package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.items.QuestItemRenderer;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import starling.events.Event;

public class QuestsScreen extends ListScreen
{
override protected function initialize():void
{
	title = loc("button_quests");
	super.initialize();
	
	listLayout.padding = 10;
	listLayout.gap = 4;	
	list.itemRendererFactory = function():IListItemRenderer { return new QuestItemRenderer(); }
	list.dataProvider = new ListCollection([1, 2, 3, 4, 5, 6]);
	list.touchable = false;
	
	appModel.navigator.addLog("بخش مأموریت ها بزودی فعال خواهد شد.");
}

override protected function list_changeHandler(event:Event):void
{
	super.list_changeHandler(event);
}
}
}