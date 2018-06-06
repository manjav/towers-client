package com.gerantech.towercraft.controls.items.exchange
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.buttons.DiscountButton;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;
import com.gt.towers.exchanges.Exchanger;
import dragonBones.starling.StarlingArmatureDisplay;
import feathers.controls.ImageLoader;
import feathers.controls.LayoutGroup;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;
import starling.events.Event;

public class ExchangeBundleItemRenderer extends ExchangeBaseItemRenderer
{
public function ExchangeBundleItemRenderer(){}
override protected function commitData():void
{
	super.commitData();
	skin.alpha = 0.7;
	
	var outKeys:Vector.<int> = exchange.outcomes.keys();
	var outcomesContainer:LayoutGroup = new LayoutGroup();
	outcomesContainer.x = width * 0.5 - padding * 5 * outKeys.length - padding * 4;
	//outcomesContainer.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0);
	addChild(outcomesContainer);
	
	for ( var i:int = 0; i < outKeys.length; i ++ )
		createIcon(outcomesContainer, outKeys, i);
	
	var availabledLabel:RTLLabel = new RTLLabel(exchange.numExchanges + "/3", 0, null, "right", false, null, 0.7);
	availabledLabel.layoutData = new AnchorLayoutData(padding, padding * 2);
	addChild(availabledLabel);
	
	var outValue:int = Exchanger.toReal(exchange.outcomes);
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
	ribbonDisplay.height = ribbonDisplay.width = width * 0.35;
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

private function createIcon(outcomesContainer:LayoutGroup, outKeys:Vector.<int>, i:int):void 
{
	if( ResourceType.isBook(outKeys[i]) ) 
	{
		var bookArmature:StarlingArmatureDisplay = OpenBookOverlay.factory.buildArmatureDisplay("book-" + outKeys[i]);
		bookArmature.width = padding * 24;
		bookArmature.scaleY = bookArmature.scaleX;
		bookArmature.animation.gotoAndStopByProgress("appear", 1);
		bookArmature.animation.timeScale = 0;
		bookArmature.x = padding * i * 8 + bookArmature.width * 0.5;
		bookArmature.y = padding * i * 8 + padding + bookArmature.height * 0.8;
		outcomesContainer.addChild(bookArmature);		
		return;
	}
	
	var cardDisplay:BuildingCard = new BuildingCard();
	cardDisplay.showLevel = false;
	cardDisplay.showSlider = false;
	cardDisplay.width = padding * 18;
	cardDisplay.height = cardDisplay.width * 1.35;
	cardDisplay.type = outKeys[i];
	cardDisplay.x = padding * i * 10;
	cardDisplay.y = padding * i * 9 + padding * 2;
	outcomesContainer.addChild(cardDisplay);
	
	var countDisplay:ShadowLabel = new ShadowLabel(exchange.outcomes.get(outKeys[i]).toString(), 1, 0, "center", null, false, null, 0.9);
	countDisplay.layoutData = new AnchorLayoutData(padding * 0.5, padding * 2, NaN, padding * 2);
	cardDisplay.addChild(countDisplay);
}

override protected function showAchieveAnimation(item:ExchangeItem):void 
{
	if( item.containBook() > -1 )
		return;
	super.showAchieveAnimation(item);
}
}
}