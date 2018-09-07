package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.Main;
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
	
	listLayout.paddingLeft = listLayout.paddingRight = 12;
	list.itemRendererFactory = function():IListItemRenderer { return new QuestItemRenderer(); }
	list.addEventListener(Event.SELECT, list_selectHandler);
	list.dataProvider = new ListCollection(Quest.GET_ALL(player));
}

private function list_selectHandler(e:Event):void 
{
	var quest:Quest = e.data as Quest;
	if( quest.passed() )
	{
		list.dataProvider.removeItem(quest);
		return;
	}
	
	switch(quest.type)
	{
		case Quest.TYPE_OPERATIONS :		appModel.navigator.pushScreen(Main.OPERATIONS_SCREEN);	return;
		
		case Quest.TYPE_CARD_COLLECT :
		case Quest.TYPE_BOOK_OPEN :
		case Quest.TYPE_LEAGUEUP :
		case Quest.TYPE_LEVELUP :
		case Quest.TYPE_BATTLES :			DashboardScreen.tabIndex = 2;	break;
		case Quest.TYPE_FRIENDLY_BATTLES :	DashboardScreen.tabIndex = 3;	break;
		case Quest.TYPE_CHALLENGES :		DashboardScreen.tabIndex = 4;	break;
		case Quest.TYPE_CARD_UPGRADE :		DashboardScreen.tabIndex = 1;	break;
	}
	appModel.navigator.popScreen();
}
}
}