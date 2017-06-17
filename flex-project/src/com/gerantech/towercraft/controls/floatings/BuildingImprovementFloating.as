package com.gerantech.towercraft.controls.floatings
{
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.views.PlaceView;
	import com.gt.towers.buildings.Building;
	
	import feathers.controls.Button;
	import feathers.controls.ButtonState;
	import feathers.skins.ImageSkin;
	
	import starling.display.Image;
	import starling.events.Event;

	public class BuildingImprovementFloating extends BaseFloating
	{
		public var placeDecorator:PlaceView;
		
		private var upgradeButton:Button;
		private var buttons:Vector.<Button>;
		
		override protected function initialize():void
		{
			super.initialize();

			//layout = new AnchorLayout();
			buttons = new Vector.<Button>();
			for (var i:int=0; i < placeDecorator.place.building.get_options().size(); i++) 
			{
				var impoveType:int = placeDecorator.place.building.get_options().get(i);
				
				var skin:ImageSkin = new ImageSkin(Assets.getTexture("improve-button-up", "gui"));
				skin.setTextureForState(ButtonState.DOWN, Assets.getTexture("improve-button-selected", "gui") );
				skin.disabledTexture = Assets.getTexture("improve-button-disabled", "gui");
				
				buttons[i] = new Button();
				buttons[i].defaultSkin = skin;
				buttons[i].name = impoveType.toString();
				buttons[i].alignPivot();
				buttons[i].y = i * -38;
				buttons[i].width = buttons[i].height = 36;
				buttons[i].isEnabled = placeDecorator.place.building.improvable(impoveType);
				
				var icon:Image = new Image(Assets.getTexture("improve-"+impoveType, "gui"));//trace("building-"+type+(type>0?"-"+level:""));
				icon.width = icon.height = 32;
				buttons[i].defaultIcon = icon
				buttons[i].addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
				addChild(buttons[i]);
			}
			placeDecorator.addEventListener(Event.UPDATE, placeDecorator_updateHandler);
		}
		
		private function placeDecorator_updateHandler(event:Event):void
		{
			for (var i:int=0; i < placeDecorator.place.building.get_options().size(); i++) 
			{
				var impoveType:int = placeDecorator.place.building.get_options().get(i);
				buttons[i].isEnabled = placeDecorator.place.building.improvable(impoveType);
				//var b:Building = placeDecorator.place.building;
				//trace(b.equalsCategory(impoveType), b.type, b.getAbstract(impoveType), b._population, b.get_capacity())
				//equalsCategory(type) || this.type == BuildingType.B01_CAMP) && getAbstract(type) != null &&  _population >= get_capacity()
			}
		}
		
		private function buttons_triggeredHandler(event:Event):void
		{
			dispatchEventWith(Event.SELECT, false, {index:placeDecorator.place.index, type:int(Button(event.currentTarget).name)});
			close();
		}
		
		override public function close(dispose:Boolean=true):void
		{
			placeDecorator.removeEventListener(Event.UPDATE, placeDecorator_updateHandler);
			super.close(dispose);
		}
	}
}