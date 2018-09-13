package com.gerantech.towercraft.controls.buttons 
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.texts.CountdownLabel;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.exchanges.ExchangeItem;
import com.gt.towers.others.Quest;
import feathers.controls.ButtonState;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;
import flash.geom.Rectangle;
import starling.events.Event;

/**
* ...
* @author Mansour Djawadi
*/
public class HomeQuestsButton extends HomeHeaderButton 
{
public function HomeQuestsButton(){super();}

override public function update() : void
{
	reset();
	exchange = exchanger.items.get(ExchangeType.C101_FREE);
	if( exchange == null )
		return;
	state = ExchangeItem.CHEST_STATE_WAIT;
	for each( var q:Quest in player.quests )
	{
		q.current = Quest.getCurrent(player, q.type, q.key);
		if( q.passed() )
			state = ExchangeItem.CHEST_STATE_READY;
	}
	
	backgroundFactory();
	iconFactory("tasks");
	titleFactory(loc("button_quests"));
	countdownFactory();
}
}
}