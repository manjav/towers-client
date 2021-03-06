package com.gerantech.towercraft.controls.headers
{
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.buttons.Indicator;
import com.gerantech.towercraft.events.LoadingEvent;
import com.gerantech.towercraft.managers.net.LoadingManager;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.events.CoreEvent;

import flash.geom.Rectangle;
import flash.utils.Dictionary;

import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.display.Image;
import starling.events.Event;

public class Toolbar extends TowersLayout
{
public var indicators:Dictionary = new Dictionary();

override protected function initialize():void
{
	super.initialize();

	var gradient:Image = new Image(Assets.getTexture("theme/gradeint-top", "gui"));
	gradient.scale9Grid = new Rectangle(1,1,7,7);
	gradient.color = 0x1122;
	backgroundSkin = gradient;
	backgroundSkin.touchable = false;
	
	var padding:Number = 36 * appModel.scale;
	height = padding * 4;
	layout = new AnchorLayout();
	
	indicators[ResourceType.POINT] = new Indicator("ltr", ResourceType.POINT, false, false);
	indicators[ResourceType.POINT].width = 160 * appModel.scale;
	indicators[ResourceType.POINT].addEventListener(Event.SELECT, indicators_selectHandler);
	indicators[ResourceType.POINT].layoutData = new AnchorLayoutData(NaN, NaN, NaN, padding);
	addChild(indicators[ResourceType.POINT]);
	
	indicators[ResourceType.CURRENCY_HARD] = new Indicator("rtl", ResourceType.CURRENCY_HARD);
	indicators[ResourceType.CURRENCY_HARD].addEventListener(Event.SELECT, indicators_selectHandler);
	indicators[ResourceType.CURRENCY_HARD].layoutData = new AnchorLayoutData(NaN, padding, NaN, NaN);
	addChild(indicators[ResourceType.CURRENCY_HARD]);
	
	indicators[ResourceType.CURRENCY_SOFT] = new Indicator("rtl", ResourceType.CURRENCY_SOFT);
	indicators[ResourceType.CURRENCY_SOFT].addEventListener(Event.SELECT, indicators_selectHandler);
	indicators[ResourceType.CURRENCY_SOFT].layoutData = new AnchorLayoutData(NaN, padding*3+indicators[ResourceType.CURRENCY_HARD].width, NaN, NaN);
	addChild(indicators[ResourceType.CURRENCY_SOFT]);
	
	indicators[ResourceType.KEY] = new Indicator("ltr", ResourceType.KEY, false, false);
	indicators[ResourceType.KEY].width = 160 * appModel.scale;
	indicators[ResourceType.KEY].addEventListener(Event.SELECT, indicators_selectHandler);
	indicators[ResourceType.KEY].layoutData = new AnchorLayoutData(NaN, NaN, NaN, padding*2.4+indicators[ResourceType.POINT].width);
	addChild(indicators[ResourceType.KEY]);

	if(appModel.loadingManager.state >= LoadingManager.STATE_LOADED )
		loadingManager_loadedHandler(null);
	else
		appModel.loadingManager.addEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
}
protected function loadingManager_loadedHandler(event:LoadingEvent):void
{
	player.resources.addEventListener(CoreEvent.CHANGE, playerResources_changeHandler);
	updateIndicators();
}


protected function playerResources_changeHandler(event:CoreEvent):void
{
	trace("CoreEvent.CHANGE:", ResourceType.getName(event.key), event.from, event.to);
	updateIndicators();
}

public function updateIndicators():void
{
	indicators[ResourceType.KEY].visible = indicators[ResourceType.POINT].visible = !player.inTutorial();
	
	indicators[ResourceType.POINT].setData(0, player.get_point(), NaN);
	indicators[ResourceType.CURRENCY_SOFT].setData(0, player.get_softs(), NaN);
	indicators[ResourceType.CURRENCY_HARD].setData(0, player.get_hards(), NaN);
	indicators[ResourceType.KEY].setData(0, player.get_keys(), NaN);
}		

private function indicators_selectHandler(event:Event):void
{
	dispatchEventWith(Event.SELECT, false, event.currentTarget);
}

override public function dispose():void
{
	appModel.loadingManager.removeEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
	player.resources.removeEventListener(CoreEvent.CHANGE, playerResources_changeHandler);
	super.dispose();
}
}
}