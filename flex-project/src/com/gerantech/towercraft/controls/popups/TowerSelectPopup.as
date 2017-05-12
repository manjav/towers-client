package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.models.towers.Tower;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.skins.ImageSkin;
	
	import starling.core.Starling;
	import starling.events.Event;

	public class TowerSelectPopup extends BasePopUp
	{
		public var tower:Tower;

		private var increaseButton:Button;
		private var upgradeButton:Button;
		
		override protected function initialize():void
		{
			super.initialize();
			//weapon = player.get_weapons().get(weaponType);
			
			var skin:ImageSkin = new ImageSkin(appModel.theme.buttonDisabledSkinTexture);
			skin.scale9Grid = BaseMetalWorksMobileTheme.BUTTON_SCALE9_GRID;
			backgroundSkin = skin;
			
			var padding:int = 10;
			layout = new AnchorLayout();
			
			var iconDisplay:ImageLoader = new ImageLoader();
			iconDisplay.source = Assets.getTexture("tower-type-"+tower.type);
			iconDisplay.layoutData = new AnchorLayoutData(padding, NaN, NaN, NaN, 0);
			iconDisplay.width = iconDisplay.height = transitionIn.destinationBound.width - padding * 2;
			addChild(iconDisplay);
			
			increaseButton = new Button();
			increaseButton.layoutData = new AnchorLayoutData(transitionIn.destinationBound.width, NaN, NaN, NaN, 0);
			increaseButton.width = transitionIn.destinationBound.width - padding * 2;
			increaseButton.label = "Select";//weapon.get_capacity() + " / " + player.get_resources().get(weapon.get_type());
			increaseButton.visible = false;
			increaseButton.alpha = 0;
			increaseButton.addEventListener(Event.TRIGGERED, selectButton_triggeredHandler);
			addChild(increaseButton);
			
			upgradeButton = new Button();
			upgradeButton.layoutData = new AnchorLayoutData(transitionIn.destinationBound.width + padding*4, NaN, NaN, NaN, 0);
			upgradeButton.width = transitionIn.destinationBound.width - padding * 2;
			upgradeButton.label = "Upgrade";
			upgradeButton.visible = false;
			upgradeButton.alpha = 0;
			upgradeButton.addEventListener(Event.TRIGGERED, upgradeButton_triggeredHandler);
			addChild(upgradeButton);
		}
		
		override protected function transitionInStated():void
		{
			super.transitionInStated();
			increaseButton.visible = true;
			Starling.juggler.tween(increaseButton, 0.1, {alpha:1, delay:0.05});

			upgradeButton.visible = true;
			Starling.juggler.tween(upgradeButton, 0.1, {alpha:1, delay:0.10});
		}
		override protected function transitionOutStated():void
		{
			super.transitionOutStated();
			Starling.juggler.tween(increaseButton, 0.05, {alpha:0, delay:0.05});
			Starling.juggler.tween(upgradeButton , 0.05, {alpha:0});
		}
		
		private function upgradeButton_triggeredHandler():void
		{
			dispatchEventWith(Event.UPDATE, false, tower);
			close();
		}
		
		private function selectButton_triggeredHandler():void
		{
			dispatchEventWith(Event.SELECT, false, tower);
			close();
		}		
	}
}