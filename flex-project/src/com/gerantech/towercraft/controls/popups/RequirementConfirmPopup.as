package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.constants.ResourceType;
	import com.gt.towers.utils.maps.IntIntMap;
	
	import feathers.events.FeathersEventType;
	import feathers.layout.RelativePosition;
	
	import starling.display.Image;
	import starling.events.Event;

	public class RequirementConfirmPopup extends ConfirmPopup
	{
		public var data:Object;
		public var requirements:IntIntMap;
		public var numHards:int;
		
		public function RequirementConfirmPopup(message:String, requirements:IntIntMap)
		{
			this.requirements = requirements;
			numHards =  exchanger.toHard(player.deductions(requirements));
			super(message, numHards.toString(), loc("popup_decline_label"));
			
			this.numHards = numHards;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			acceptButton.iconPosition = RelativePosition.RIGHT;
			acceptButton.iconOffsetX = 24*appModel.scale;
			acceptButton.label = String(numHards);
			
			var upgradeIcon:Image = new Image(Assets.getTexture("res-"+ResourceType.CURRENCY_HARD, "gui"));
			upgradeIcon.width = upgradeIcon.height = appModel.theme.controlSize;
			acceptButton.defaultIcon = upgradeIcon;
		}
		
		override protected function acceptButton_triggeredHandler():void
		{
			if( numHards > player.get_hards() )
				dispatchEventWith(FeathersEventType.ERROR);
			else			
				dispatchEventWith(Event.SELECT);
			close();
		}

	}
}