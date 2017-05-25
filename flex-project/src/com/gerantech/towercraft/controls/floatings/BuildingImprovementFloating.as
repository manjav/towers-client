package com.gerantech.towercraft.controls.floatings
{
	import com.gerantech.towercraft.views.decorators.PlaceDecorator;
	import com.gt.towers.buildings.Building;
	
	import feathers.controls.Button;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.events.Event;

	public class BuildingImprovementFloating extends BaseFloating
	{
		public var placeDecorator:PlaceDecorator;
		
		private var upgradeButton:Button;
		override protected function initialize():void
		{
			super.initialize();
			//width = height = 40;
			//weapon = player.get_weapons().get(weaponType);
			
			/*var skin:ImageSkin = new ImageSkin(appModel.theme.buttonDisabledSkinTexture);
			skin.scale9Grid = BaseMetalWorksMobileTheme.BUTTON_SCALE9_GRID;
			backgroundSkin = skin;*/
			
			var padding:int = 10;
			layout = new AnchorLayout();

			upgradeButton = new Button();
			upgradeButton.alignPivot();
			upgradeButton.width = upgradeButton.height = 40;
			//upgradeButton.layoutData = new AnchorLayoutData(-40, 20, NaN, NaN, 0.5, 1);
			upgradeButton.isEnabled = placeDecorator.upgradable;
			upgradeButton.label = "^";
			upgradeButton.addEventListener(Event.TRIGGERED, upgradeButton_triggeredHandler);
			addChild(upgradeButton);
			
			placeDecorator.addEventListener(Event.UPDATE, placeDecorator_updateHandler);

		}
		
		private function placeDecorator_updateHandler(event:Event):void
		{
			upgradeButton.isEnabled = placeDecorator.upgradable;
		}
		
		private function upgradeButton_triggeredHandler():void
		{
			dispatchEventWith(Event.SELECT, false, placeDecorator);
			close();
		}
		
		override public function close(dispose:Boolean=true):void
		{
			placeDecorator.removeEventListeners();
			super.close(dispose);
		}
		
		
	}
}