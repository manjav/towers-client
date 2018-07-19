package com.gerantech.towercraft.controls.buttons 
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.texts.CountdownLabel;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.exchanges.ExchangeItem;
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
public class HomeTasksButton extends HomeHeaderButton 
{
public function HomeTasksButton(){super();}

override public function update() : void
{
	reset();
	exchange = exchanger.items.get(ExchangeType.C101_FREE);
	if( exchange == null )
		return;
	state = 0;
	
	backgroundFactory();
	iconFactory("tasks");
	titleFactory("مأموریت");
	countdownFactory();
}
}
}