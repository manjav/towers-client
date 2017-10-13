	package com.gerantech.towercraft.controls.items.exchange
{
	import com.gerantech.towercraft.controls.buttons.ExchangeButton;
	import com.gerantech.towercraft.controls.overlays.OpenChestOverlay;
	import com.gt.towers.constants.ExchangeType;
	import com.gt.towers.constants.ResourceType;
	
	import dragonBones.starling.StarlingArmatureDisplay;
	
	import feathers.layout.AnchorLayoutData;
	
	public class ExchangeChestOfferItemRenderer extends ExchangeBaseItemRenderer
	{
		private var buttonDisplay:ExchangeButton;
		private var chestArmature:StarlingArmatureDisplay;

		override protected function commitData():void
		{
			if( index < 0 || _data == null )
				return;
			super.commitData();
			if(firstCommit)
				firstCommit = false;
			if( chestArmature == null )
			{
				chestArmature = OpenChestOverlay.factory.buildArmatureDisplay("chest-"+exchange.outcome);
				chestArmature.scale = appModel.scale;
				chestArmature.x = width * 0.5;
				chestArmature.y = height * 0.6;
				chestArmature.animation.gotoAndStopByProgress("fall", 1);
				addChild(chestArmature);
			}
			
			if( buttonDisplay == null )
			{
				buttonDisplay = new ExchangeButton();
				buttonDisplay.layoutData = new AnchorLayoutData(NaN, NaN, padding, NaN, 0);
				buttonDisplay.height = 96 * appModel.scale;
				buttonDisplay.count = ExchangeType.getHardRequierement(exchange.outcome);		
				buttonDisplay.type = ResourceType.CURRENCY_HARD;		
				addChild(buttonDisplay);
			}
		}
	}
}