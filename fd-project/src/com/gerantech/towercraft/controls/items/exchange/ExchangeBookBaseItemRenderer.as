package com.gerantech.towercraft.controls.items.exchange
{
import com.gerantech.towercraft.controls.buttons.ExchangeButton;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gt.towers.constants.BuildingType;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;
import dragonBones.starling.StarlingArmatureDisplay;
import feathers.layout.AnchorLayoutData;
public class ExchangeBookBaseItemRenderer extends ExchangeBaseItemRenderer
{
protected var buttonDisplay:ExchangeButton;
protected var bookArmature:StarlingArmatureDisplay;

public function ExchangeBookBaseItemRenderer(){}
override protected function commitData():void
{
	if( index < 0 || _data == null )
		return;
	super.commitData();
	bookFactory();
	buttonFactory();
}
protected function bookFactory() : StarlingArmatureDisplay 
{
	if( bookArmature == null )
	{
		bookArmature = OpenBookOverlay.factory.buildArmatureDisplay("book-" + exchange.outcome);
		bookArmature.scale = OpenBookOverlay.getBookScale(exchange.outcome) * appModel.scale;
		bookArmature.x = width * 0.5;
		bookArmature.y = height * 0.4;
	}
	addChild(bookArmature);
	return bookArmature;
}
protected function buttonFactory() : ExchangeButton
{
	if( buttonDisplay == null )
	{
		buttonDisplay = new ExchangeButton();
		buttonDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding * 2, NaN, 0);
		buttonDisplay.height = 96 * appModel.scale;
		buttonDisplay.count = ExchangeType.getHardRequierement(exchange.outcome);		
		buttonDisplay.type = ResourceType.CURRENCY_HARD;		
	}
	addChild(buttonDisplay);
	return buttonDisplay;
}
override protected function showAchieveAnimation(item:ExchangeItem):void {}
}
}