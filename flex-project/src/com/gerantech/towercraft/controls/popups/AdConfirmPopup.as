package com.gerantech.towercraft.controls.popups
{
	import com.gt.towers.constants.ExchangeType;
	
	import flash.geom.Rectangle;

	public class AdConfirmPopup extends ConfirmPopup
	{
		private var rewardCount:int;
		
		public function AdConfirmPopup(type:int)
		{
			rewardCount = ExchangeType.getRewardCount(type);
			declineStyle = "danger";
			super(loc("popup_ad_title", [rewardCount]), loc("popup_ad_accept"), loc("popup_decline_label"));
		}
		
		override protected function initialize():void
		{
			super.initialize();
			transitionIn.sourceBound = transitionOut.destinationBound = new Rectangle(stage.stageWidth*0.15, stage.stageHeight*0.40, stage.stageWidth*0.7, stage.stageHeight*0.2);
			transitionOut.sourceBound = transitionIn.destinationBound = new Rectangle(stage.stageWidth*0.15, stage.stageHeight*0.35, stage.stageWidth*0.7, stage.stageHeight*0.3);
			rejustLayoutByTransitionData();
		}
		
		
	}
}