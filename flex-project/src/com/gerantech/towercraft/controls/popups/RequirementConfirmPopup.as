package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.constants.ResourceType;
	import com.gt.towers.utils.maps.IntIntMap;
	
	import feathers.events.FeathersEventType;
	
	import starling.events.Event;

	public class RequirementConfirmPopup extends ConfirmPopup
	{
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

			acceptButton.label = String(numHards);
			acceptButton.icon = Assets.getTexture("res-"+ResourceType.CURRENCY_HARD, "gui");
		}
		
		override protected function acceptButton_triggeredHandler(event:Event):void
		{
			if( numHards > player.get_hards() )
				dispatchEventWith(FeathersEventType.ERROR);
			else			
				dispatchEventWith(Event.SELECT);
			close();
		}

	}
}