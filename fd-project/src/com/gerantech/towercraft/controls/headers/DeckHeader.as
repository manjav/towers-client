package com.gerantech.towercraft.controls.headers
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.buttons.CardButton;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Quad;
import starling.events.Event;
import starling.events.Touch;

public class DeckHeader extends TowersLayout
{
public var _height:int;
private var padding:int;
public var cards:Vector.<CardButton>;
public var cardsBounds:Vector.<Rectangle>;

public function DeckHeader()
{
	super();
	_height = 640;
	padding = 32;
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	
	backgroundSkin = new Quad(1, 1, 0);
	backgroundSkin.alpha = 0.8;
	height = _height;
	
	
	var titleDisplay:ShadowLabel = new ShadowLabel(loc("deck_label"));
	titleDisplay.layoutData = new AnchorLayoutData(padding * 4, NaN, NaN, NaN, 0);
	addChild(titleDisplay);
	
	cards = new Vector.<CardButton>();
	cardsBounds = new Vector.<Rectangle>();
	for ( var i:int = 0; i < player.decks.get(player.selectedDeck).size(); i++ ) 
		createDeckItem(i);
}

private function createDeckItem(i:int):void
{
	var button:CardButton = new CardButton(player.decks.get(player.selectedDeck).get(i));
	button.x = padding + 260 * i;
	button.y = padding * 7 ;
	button.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
	addChild(button)
	
	cards.push(button.card);
	cardsBounds.push(button.getIconBounds());
}

private function buttons_triggeredHandler(event:Event):void
{
	dispatchEventWith(Event.SELECT, false, SimpleLayoutButton(event.currentTarget).getChildAt(0));
}

public function startHanging():void
{
	y = 0;
	for ( var i:int = 0; i < cards.length; i++ ) 
	{
		cards[i].rotation = -0.02;
		Starling.juggler.tween(cards[i], 0.15, {delay:i*0.05, rotation:0.015, reverse:true, repeatCount:1000, transition:Transitions.EASE_IN_OUT});
	}
}

public function fix():void
{
	for ( var i:int = 0; i < cards.length; i++ )
	{
		Starling.juggler.removeTweens(cards[i]);
		cards[i].scale = 1;
		cards[i].rotation = 0;
	}
}

public function getCardIndex(touch:Touch):int
{
	var ret:int = -1;
	for ( var i:int = 0; i < cardsBounds.length; i++ )
		if( cardsBounds[i].contains(touch.globalX, touch.globalY) )
			ret = i;
	for ( i = 0; i < cards.length; i++ )
		cards[i].scale = i==ret ? 1.1 : 1;
	return ret;
}

public function update():void
{
	//for ( var i:int = 0; i < cards.length; i++ ) 
	//	cards[i].setData(cards[i].card.type, cards[i].card.level);	
}
}
}