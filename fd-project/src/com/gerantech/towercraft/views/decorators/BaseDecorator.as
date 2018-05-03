package com.gerantech.towercraft.views.decorators 
{
import com.gerantech.towercraft.managers.TutorialManager;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.views.BattleFieldView;
import com.gerantech.towercraft.views.PlaceView;
import com.gt.towers.Game;
import com.gt.towers.Player;
import com.gt.towers.buildings.Place;
import starling.events.Event;
import starling.events.EventDispatcher;

/**
* ...
* @author Mansour Djawadi
*/
public class BaseDecorator extends EventDispatcher 
{
protected var placeView:PlaceView;
protected var place:Place;
public function BaseDecorator(placeView:PlaceView) 
{
	this.placeView = placeView;
	this.place = placeView.place;
	this.placeView.addEventListener(Event.UPDATE, placeView_updateHandler);

	addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
}

protected function addedToStageHandler(event:Event) : void
{
	removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
}
protected function placeView_updateHandler(event:Event) : void 
{
	update(event.data[0], event.data[1], event.data[2]);
}
protected function update(population:int, troopType:int, occupied:Boolean) : void {}
public function dispose() : void { }

protected function get appModel():		AppModel		{	return AppModel.instance;					}
protected function get game():			Game			{	return appModel.game;						}
protected function get player():		Player			{	return game.player;							}
protected function get tutorials():		TutorialManager	{	return TutorialManager.instance;			}
protected function get fieldView():		BattleFieldView {	return AppModel.instance.battleFieldView;	}

}
}