package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.Main;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
	import feathers.controls.StackScreenNavigatorItem;
	
	import starling.events.Event;

	public class InvitationPopup extends MessagePopup
	{
		private var responseCode:int;

		private var params:SFSObject;
		public function InvitationPopup(params:SFSObject)
		{
			this.params = params;
			responseCode = params.getInt("responseCode");
			var array:Array = responseCode==0||responseCode==-2 ? [params.getText("inviter")] : null;
			var msg:String = loc("popup_invitation_"+responseCode, array);
			if( params.containsKey("rewardType") )
				msg += "\n" + loc("popup_invitation_reward", [params.getInt("rewardCount"), loc("resource_title_" + params.getInt("rewardType"))]);

			super(msg, acceptLabel);
		}

		override protected function acceptButton_triggeredHandler(event:Event):void
		{
			super.acceptButton_triggeredHandler(event);
			if( responseCode == 0 )
			{
				if( params.containsKey("rewardType") )
				{
					player.resources.increase(params.getInt("rewardType"), params.getInt("rewardCount") );
					var rec:Rectangle = acceptButton.getBounds(stage);
					appModel.navigator.addResourceAnimation(rec.x+rec.width*0.5, rec.y, params.getInt("rewardType"), params.getInt("rewardCount"));
				}

				var f:SFSObject = new SFSObject();
				f.putText("name", params.getText("inviter") );
				f.putInt("count", 120 );
				appModel.loadingManager.serverData.getSFSArray("friends").addSFSObject(f);
				
				if ( player.villageEnabled() )
				{
					var item:StackScreenNavigatorItem = appModel.navigator.getScreen( Main.SOCIAL_SCREEN );
					item.properties.selectedTab = 2;
					setTimeout(appModel.navigator.pushScreen, 800, Main.SOCIAL_SCREEN);
				}
			}
		}
	}
}