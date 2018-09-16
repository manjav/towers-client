package com.gerantech.towercraft.controls.buttons 
{
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.events.CoreEvent;
import com.gt.towers.exchanges.ExchangeItem;
import com.gt.towers.others.Quest;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

/**
* ...
* @author Mansour Djawadi
*/
public class HomeQuestsButton extends HomeHeaderButton 
{
private var timeoutId:uint;
public function HomeQuestsButton(){ super(); }
override protected function initialize() : void
{
	super.initialize();
	player.resources.addEventListener(CoreEvent.CHANGE, playerResources_changeHandler);
}

private function playerResources_changeHandler(e:CoreEvent):void 
{
	clearTimeout(timeoutId);
	timeoutId = setTimeout( updateQuests, 10);
}

private function updateQuests():void 
{
	trace("updateQuests")
	for each( var q:Quest in player.quests )
	{
		q.current = Quest.getCurrent(player, q.type, q.key);
		if( q.passed() )
			state = ExchangeItem.CHEST_STATE_READY;
	}
	backgroundFactory();
}
override public function update() : void
{
	reset();
	
	exchange = exchanger.items.get(ExchangeType.C101_FREE);
	if( exchange == null )
		return;
	state = ExchangeItem.CHEST_STATE_WAIT;
	updateQuests();
	
	iconFactory("tasks");
	titleFactory(loc("button_quests"));
	countdownFactory();
}

override public function dispose() : void
{
	clearTimeout(timeoutId);
	player.resources.removeEventListener(CoreEvent.CHANGE, playerResources_changeHandler);
	super.dispose();
}
}
}