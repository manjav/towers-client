package com.gerantech.towercraft.controls.items.exchange
{
import com.gerantech.towercraft.controls.buttons.ExchangeButton;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;
import dragonBones.starling.StarlingArmatureDisplay;
import feathers.layout.AnchorLayoutData;
public class ExchangeBookOfferItemRenderer extends ExchangeBaseItemRenderer
{
private var buttonDisplay:ExchangeButton;
private var bookArmature:StarlingArmatureDisplay;
public function ExchangeBookOfferItemRenderer(){}
override protected function commitData():void
{
	if( index < 0 || _data == null )
		return;
	super.commitData();
	if( firstCommit )
		firstCommit = false;
	if( bookArmature == null )
	{
		bookArmature = OpenBookOverlay.factory.buildArmatureDisplay("book-" + exchange.outcome);
		bookArmature.scale = appModel.scale;
		bookArmature.x = width * 0.5;
		bookArmature.y = height * 0.4;
		bookArmature.animation.gotoAndStopByProgress("fall-closed", 1);
		addChild(bookArmature);
	}
	
	if( buttonDisplay == null )
	{
		buttonDisplay = new ExchangeButton();
		buttonDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding * 2, NaN, 0);
		buttonDisplay.height = 96 * appModel.scale;
		buttonDisplay.count = ExchangeType.getHardRequierement(exchange.outcome);		
		buttonDisplay.type = ResourceType.CURRENCY_HARD;		
		addChild(buttonDisplay);
	}
}
override protected function showAchieveAnimation(item:ExchangeItem):void {}
}
}