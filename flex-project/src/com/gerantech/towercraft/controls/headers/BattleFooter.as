package com.gerantech.towercraft.controls.headers
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.TowersLayout;

import feathers.layout.AnchorLayout;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;

import starling.display.Quad;

public class BattleFooter extends TowersLayout
{
	private var _height:int;
	private var padding:int;

	private var cards:Vector.<BuildingCard>;
public function BattleFooter()
{
	super();
	_height = 260 * appModel.scale;
}

override protected function initialize():void
{
	super.initialize();
	
	var hlayout:HorizontalLayout = new HorizontalLayout();
	hlayout.padding = hlayout.gap = 16 * appModel.scale;
	hlayout.verticalAlign = VerticalAlign.JUSTIFY;
	hlayout.horizontalAlign = HorizontalAlign.RIGHT;
	layout = hlayout;
	
	backgroundSkin = new Quad(1,1,0);
	backgroundSkin.alpha = 0.7;
	height = _height;
	
	
	cards = new Vector.<BuildingCard>();
	for ( var i:int = 0; i < player.decks.get(player.selectedDeck).size(); i++ ) 
		createDeckItem(i);
	
}

private function createDeckItem(i:int):void
{
	var card:BuildingCard = new BuildingCard();
	card.showLevel = card.showSlider = false;
	card.width = 180 * appModel.scale;
	card.type = player.decks.get(player.selectedDeck).get(i);
	cards.push(card);
	addChild(card);
}


}
}