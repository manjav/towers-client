package com.gerantech.towercraft.controls.items.exchange
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.buttons.DiscountButton;
import com.gerantech.towercraft.controls.buttons.ExchangeButton;
import com.gerantech.towercraft.controls.groups.Devider;
import com.gerantech.towercraft.controls.texts.LTRLable;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;
import com.gt.towers.exchanges.Exchanger;
import com.gt.towers.utils.maps.IntIntMap;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayoutData;
import starling.events.Event;

public class ExchangeSpecialItemRenderer extends ExchangeBaseItemRenderer
{

public function ExchangeSpecialItemRenderer(){}
override protected function commitData():void
{
	super.commitData();
	skin.alpha = 0.7;
	var cardDisplay:BuildingCard = new BuildingCard();
	cardDisplay.showLevel = false;
	cardDisplay.showSlider = false;
	cardDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -padding * 6);
	cardDisplay.width = width * 0.7;
	cardDisplay.height = cardDisplay.width * 1.35;
	cardDisplay.type = exchange.outcome;
	addChild(cardDisplay);
	
	var countDisplay:ShadowLabel = new ShadowLabel("x " + exchange.outcomes.values()[0]);
	countDisplay.layoutData = new AnchorLayoutData(NaN, padding * 2, padding * 2);
	cardDisplay.addChild(countDisplay);	
	
	if( exchange.numExchanges > 0 )
	{
		var fineDisplay:ImageLoader = new ImageLoader();
		fineDisplay.source = Assets.getTexture("checkbox-on", "gui");
		fineDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding * 4, NaN, padding * 2);
		fineDisplay.height = fineDisplay.width = width * 0.32;
		addChild(fineDisplay);
		return;
	}
	
	var outValue:int = exchange.requirements.keys()[0] == ResourceType.CURRENCY_HARD ? Exchanger.toHard(exchange.outcomes) : Exchanger.toSoft(exchange.outcomes);
	var discount:int = Math.round((1 - (exchange.requirements.values()[0] / outValue)) * 100)
	
	var buttonDisplay:DiscountButton = new DiscountButton();
	buttonDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding * 2, NaN, 0);
	buttonDisplay.width = 320 * appModel.scale;
	if( exchange.requirements.keys()[0] == ResourceType.CURRENCY_REAL )
		buttonDisplay.currency = "ت";
	buttonDisplay.originCount = outValue;
	buttonDisplay.count = exchange.requirements.values()[0];
	buttonDisplay.type = exchange.requirements.keys()[0];
	addChild(buttonDisplay);
	
	var newDisplay:ImageLoader = new ImageLoader();
	newDisplay.source = Assets.getTexture("cards/empty-badge", "gui");
	newDisplay.layoutData = new AnchorLayoutData( -16 * appModel.scale, NaN, NaN, -16 * appModel.scale);
	newDisplay.height = newDisplay.width = width * 0.65;
	addChild(newDisplay);
	
	var discoutDisplay:ShadowLabel = new ShadowLabel( discount + "% OFF", 1, 0, "center", "ltr", false, null, 0.85);
	discoutDisplay.width = 300 * appModel.scale;
	discoutDisplay.alignPivot();
	discoutDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, -width * 0.35, -height * 0.35);
	discoutDisplay.rotation = -0.8;
	addChild(discoutDisplay);
}

override protected function exchangeManager_completeHandler(event:Event):void 
{
	var item:ExchangeItem = event.data as ExchangeItem;
	if( item.type != exchange.type )
		return;
	removeChildren();
	commitData();
	showAchieveAnimation(item);
}
}
}