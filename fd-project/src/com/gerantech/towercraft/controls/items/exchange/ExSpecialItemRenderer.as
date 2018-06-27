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
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;
import starling.events.Event;

public class ExSpecialItemRenderer extends ExBaseItemRenderer
{

public function ExSpecialItemRenderer(){}
override protected function commitData():void
{
	super.commitData();
	skin.alpha = 0.7;
	var cardDisplay:BuildingCard = new BuildingCard(false, false, true, false);
	cardDisplay.setData(exchange.outcome);
	cardDisplay.width = width * 0.6;
	cardDisplay.layoutData = new AnchorLayoutData(padding * 2, NaN, NaN, NaN, 0);
	addChild(cardDisplay);
	
	var countDisplay:ShadowLabel = new ShadowLabel("x " + exchange.outcomes.values()[0]);
	countDisplay.layoutData = new AnchorLayoutData(NaN, padding * 1.2, padding * 0.2);
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
	
	var ribbonDisplay:ImageLoader = new ImageLoader();
	ribbonDisplay.source = Assets.getTexture("cards/empty-badge", "gui");
	ribbonDisplay.layoutData = new AnchorLayoutData( -14 * appModel.scale, NaN, NaN, -14 * appModel.scale);
	ribbonDisplay.height = ribbonDisplay.width = width * 0.5;
	addChild(ribbonDisplay);
	ribbonDisplay.addEventListener(FeathersEventType.CREATION_COMPLETE, function():void
	{
		var discoutDisplay:ShadowLabel = new ShadowLabel( discount + "% OFF", 1, 0, "center", "ltr", false, null, 0.7);
		discoutDisplay.width = 200 * appModel.scale;
		discoutDisplay.alignPivot();
		discoutDisplay.rotation = -0.8;
		discoutDisplay.x = ribbonDisplay.width * 0.33;
		discoutDisplay.y = ribbonDisplay.height * 0.33;
		ribbonDisplay.addChild(discoutDisplay);
	});
}
}
}