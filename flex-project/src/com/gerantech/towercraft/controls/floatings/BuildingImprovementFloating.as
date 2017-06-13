package com.gerantech.towercraft.controls.floatings
{
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.views.PlaceView;
	
	import feathers.controls.Button;
	
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
				var impoveType:int = placeDecorator.place.building.get_options().get(i);trace(impoveType)
				
				buttons[i] = new Button();
				buttons[i].name = impoveType.toString();
				buttons[i].alignPivot();
				//buttons[i].defaultSkin = new ImageSkin(Assets.getTexture("button-"+impoveType, "gui")
				buttons[i].y = i * -38;
				buttons[i].width = buttons[i].height = 36;
				//upgradeButton.layoutData = new AnchorLayoutData(-40, 20, NaN, NaN, 0.5, 1);
				buttons[i].isEnabled = placeDecorator.improvable(impoveType);
				
				var icon:Image = new Image(Assets.getTexture("button-"+impoveType, "gui"));//trace("building-"+type+(type>0?"-"+level:""));
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
				buttons[i].isEnabled = placeDecorator.improvable(placeDecorator.place.building.get_options().get(i));
		}
		
		private function buttons_triggeredHandler(event:Event):void
		{
			dispatchEventWith(Event.SELECT, false, {index:placeDecorator.place.index, type:int(Button(event.currentTarget).name)});
			close();
		}
		
		override public function close(dispose:Boolean=true):void
		{
			placeDecorator.removeEventListeners();
			super.close(dispose);
		}
	}
}