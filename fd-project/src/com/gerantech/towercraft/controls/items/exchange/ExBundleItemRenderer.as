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
import flash.utils.setTimeout;
import starling.display.DisplayObjectContainer;

public class ExBundleItemRenderer extends ExBaseItemRenderer
{
public function ExBundleItemRenderer(){}
override protected function commitData():void
{
	super.commitData();
	skin.alpha = 0.7;
	
	var outKeys:Vector.<int> = exchange.outcomes.keys();

	var rowH:int = width / ( outKeys.length );
	for ( var i:int = 0; i < outKeys.length; i ++ )
		createOutcome(outKeys, i, rowH);
	
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
	ribbonDisplay.height = ribbonDisplay.width = padding * 18;
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

private function createOutcome(outKeys:Vector.<int>, i:int, rowH:int):void 
{
	var outcome:DisplayObjectContainer;
	if( ResourceType.isBook(outKeys[i]) ) 
	{
		var bookArmature:StarlingArmatureDisplay = OpenBookOverlay.factory.buildArmatureDisplay("book-" + outKeys[i]);
		bookArmature.width = padding * 24;
		bookArmature.scaleY = bookArmature.scaleX;
		bookArmature.animation.gotoAndStopByProgress("appear", 1);
		bookArmature.animation.timeScale = 0;
		outcome = bookArmature;
	}
	else
	{
		var cardDisplay:BuildingCard = new BuildingCard();
		cardDisplay.showLevel = false;
		cardDisplay.showSlider = false;
		cardDisplay.width = padding * 18;
		cardDisplay.height = cardDisplay.width * 1.35;		
		cardDisplay.type = outKeys[i];
		cardDisplay.pivotX = cardDisplay.width * 0.5;
		cardDisplay.pivotY = cardDisplay.height * 0.5;	
		
		var countDisplay:ShadowLabel = new ShadowLabel(exchange.outcomes.get(outKeys[i]).toString(), 1, 0, "center", null, false, null, 0.9);
		countDisplay.layoutData = new AnchorLayoutData(padding * 0.5, padding * 2, NaN, padding * 2);
		setTimeout(cardDisplay.addChild, 10, countDisplay);
		outcome = cardDisplay;
	}

	outcome.x = i * rowH + rowH * 0.5;
	outcome.y = padding * 18;
	addChild(outcome);
	
	var labelDisplay:ShadowLabel = new ShadowLabel(loc((ResourceType.isBuilding(outKeys[i]) ? "building_title_" : (ResourceType.isBook(outKeys[i])?"exchange_title_":"resource_title_")) + outKeys[i]), 1, 0, "center");
	labelDisplay.width = rowH;
	labelDisplay.pivotX = rowH * 0.5;
	labelDisplay.x = i * rowH + rowH * 0.5;
	labelDisplay.y = padding * 30;
	addChild(labelDisplay);
}

override protected function showAchieveAnimation(item:ExchangeItem):void 
{
	if( item.containBook() > -1 )
		return;
	super.showAchieveAnimation(item);
}
}
}