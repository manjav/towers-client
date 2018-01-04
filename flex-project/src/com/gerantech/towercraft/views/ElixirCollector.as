package com.gerantech.towercraft.views
{
import com.gerantech.towercraft.managers.BaseManager;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.buildings.Place;

import flash.utils.clearInterval;
import flash.utils.setInterval;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;

public class ElixirCollector extends BaseManager
{
private var elixirId:uint;
private var place:Place;

private var elixir:Image;
public function ElixirCollector(place:Place)
{
	this.place = place;
	elixirId = setInterval(showCollectElixir, 4000);
}

private function showCollectElixir():void
{
	trace("ElixirCollector")
	elixir = new Image(Assets.getTexture("cards/elixir-" + (place.mode+1), "gui"));
	elixir.pivotX = elixir.width * 0.5;
	elixir.pivotY = elixir.height * 0.5;
	elixir.scale = 0;
	elixir.x = place.x;
	elixir.y = place.y - 100;
	appModel.battleFieldView.guiImagesContainer.addChild(elixir);
	Starling.juggler.tween(elixir, 1.5, {scale : 2, transition:Transitions.EASE_IN_OUT_ELASTIC});
	Starling.juggler.tween(elixir, 2.5, {y : place.y - 200, alpha:0, onComplete:elixir.removeFromParent, onCompleteArgs:[true]});

}

public function dispose():void
{
	if( elixir )
	{
		Starling.juggler.removeTweens(elixir);
		elixir.removeFromParent(true);
	}
	clearInterval(elixirId);
}
}
}