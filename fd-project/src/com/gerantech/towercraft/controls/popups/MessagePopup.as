package com.gerantech.towercraft.controls.popups
{
	public class MessagePopup extends ConfirmPopup
	{
		public function MessagePopup(message:String, acceptLabel:String=null)
		{
			super(message, acceptLabel, null);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			declineButton.removeFromParent();
			rejustLayoutByTransitionData();
		}
	}
}