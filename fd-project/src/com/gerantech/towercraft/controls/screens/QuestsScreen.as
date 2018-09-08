package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.items.QuestItemRenderer;
import com.gt.towers.others.Quest;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import flash.utils.setTimeout;
import starling.events.Event;

public class QuestsScreen extends ListScreen
{
override protected function initialize():void
{
	title = loc("button_quests");
	virtualHeader = false;
	headerSize = 200;
	super.initialize();
	
	header.labelLayout.verticalCenter = 40;
	listLayout.paddingLeft = listLayout.paddingRight = 12;
	listLayout.hasVariableItemDimensions = true;
	list.itemRendererFactory = function():IListItemRenderer { return new QuestItemRenderer(); }
	list.addEventListener(Event.SELECT, list_selectHandler);
	list.dataProvider = new ListCollection(Quest.GET_ALL(player));
}

private function list_selectHandler(e:Event):void 
{
	var questItem:QuestItemRenderer = e.data as QuestItemRenderer;
	if( questItem.quest.passed() )
	{
		passQuest(questItem);
		return;
	}
	
	switch(questItem.quest.type)
	{
		case Quest.TYPE_OPERATIONS :		appModel.navigator.pushScreen(Main.OPERATIONS_SCREEN);	return;
		
		case Quest.TYPE_CARD_COLLECT :
		case Quest.TYPE_BOOK_OPEN :
		case Quest.TYPE_LEAGUEUP :
		case Quest.TYPE_LEVELUP :
		case Quest.TYPE_CARD_UPGRADE :		DashboardScreen.tabIndex = 1;	break;
		case Quest.TYPE_BATTLES :			DashboardScreen.tabIndex = 2;	break;
		case Quest.TYPE_FRIENDLY_BATTLES :	DashboardScreen.tabIndex = 3;	break;
		case Quest.TYPE_CHALLENGES :		DashboardScreen.tabIndex = 4;	break;
	}
	appModel.navigator.popScreen();
}

private function passQuest(questItem:QuestItemRenderer):void 
{
	questItem.hide();
	var rect:Rectangle = questItem.getBounds(stage);
	rect.x += 150;
	rect.y += QuestItemRenderer.HEIGHT * 0.2;
	appModel.navigator.addMapAnimation(rect.x, rect.y, questItem.quest.rewards);
}
}
}