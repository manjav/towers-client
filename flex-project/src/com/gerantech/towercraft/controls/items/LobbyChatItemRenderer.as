package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	import com.gerantech.towercraft.utils.StrUtils;
	import com.smartfoxserver.v2.entities.data.ISFSArray;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.AutoSizeMode;
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;

	public class LobbyChatItemRenderer extends BaseCustomItemRenderer
	{

		private var senderDisplay:RTLLabel;
		private var roleDisplay:RTLLabel;
		private var messageDisplay:RTLLabel;
		private var dateDisplay:RTLLabel;

		private var meSkin:ImageLoader;
		
		private var senderLayout:AnchorLayoutData;
		private var roleLayout:AnchorLayoutData;
		private var messageLayout:AnchorLayoutData;
		private var dateLayout:AnchorLayoutData;
		private var otherPadding:int;

		private var padding:int;
		private var otherSkin:ImageLoader;
		private var date:Date;
		
		public function LobbyChatItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			autoSizeMode = AutoSizeMode.CONTENT;
			
			date = new Date();
			layout = new AnchorLayout();
			padding = 80 * appModel.scale;
			otherPadding = 180 * appModel.scale;
			
			meSkin = new ImageLoader();
			meSkin.scale9Grid = new Rectangle(22, 17, 4, 4);
			meSkin.visible = false;
			meSkin.source = Assets.getTexture("balloon-me", "skin");
			meSkin.layoutData = new AnchorLayoutData( padding*0.1, padding*0.1, padding*0.1, otherPadding-padding*0.9 );
			addChild(meSkin);
			
			otherSkin = new ImageLoader();
			otherSkin.scale9Grid = new Rectangle(22, 17, 4, 4);
			otherSkin.visible = false;
			otherSkin.source = Assets.getTexture("balloon-other", "skin");
			otherSkin.layoutData = new AnchorLayoutData( padding*0.1, otherPadding-padding*0.9, padding*0.1, padding*0.1 );
			addChild(otherSkin);
			
			senderDisplay = new RTLLabel("", BaseMetalWorksMobileTheme.PRIMARY_BACKGROUND_COLOR, null, null, false, null, 0.8);
			senderLayout = new AnchorLayoutData( padding * 0.5 );
			senderDisplay.layoutData = senderLayout;
			addChild(senderDisplay);
			
			roleDisplay = new RTLLabel("", BaseMetalWorksMobileTheme.PRIMARY_BACKGROUND_COLOR, null, null, false, null, 0.7);
			roleLayout = new AnchorLayoutData( padding * 0.5 );
			roleDisplay.layoutData = roleLayout;
			addChild(roleDisplay);
			
			messageDisplay = new RTLLabel("", BaseMetalWorksMobileTheme.PRIMARY_BACKGROUND_COLOR, "justify", null, true, null, 0.8, "OpenEmoji");
			//messageDisplay.leading = -10*appModel.scale;
			messageLayout = new AnchorLayoutData( padding * 1.3 );
			messageDisplay.layoutData = messageLayout;
			addChild(messageDisplay);
			
			dateDisplay = new RTLLabel("", BaseMetalWorksMobileTheme.DESCRIPTION_TEXT_COLOR, null, null, false, null, 0.7);
			dateLayout = new AnchorLayoutData( NaN, appModel.isLTR?padding:NaN, padding * 0.5, appModel.isLTR?NaN:padding );
			dateDisplay.layoutData = dateLayout;
			addChild(dateDisplay);
		}
		
		
		override protected function commitData():void
		{
			super.commitData();
			if( _data == null )
				return;
			
			var msgPack:ISFSObject = _data as SFSObject;
			var user:ISFSObject = findUser(msgPack.getInt("i"));
			if( user == null )
				return;
			
			var itsMe:Boolean = msgPack.getInt("i") == player.id;
			meSkin.visible = itsMe;
			otherSkin.visible = !itsMe;
			
			senderDisplay.text = user.getText("na");
			senderLayout.right = itsMe ? padding : otherPadding;
			
			roleDisplay.text = loc("lobby_role_" + user.getShort("pr"));
			roleLayout.left = itsMe ? otherPadding : padding;
			
			messageDisplay.text = msgPack.getUtfString("t")+"\n\n";
			messageLayout.right = itsMe ? padding : otherPadding;
			messageLayout.left = itsMe ? otherPadding : padding;

			date.time = msgPack.getInt("u")*1000;
			dateDisplay.text = StrUtils.dateToTime(date);
			dateLayout.left = itsMe ? otherPadding : padding;
			if( height != 0 )
				height = messageLayout.top + messageDisplay.height + padding;
		}
		
		private function findUser(uid:int):ISFSObject
		{
			var all:ISFSArray = SFSConnection.instance.lastJoinedRoom.getVariable("all").getSFSArrayValue();
			var allSize:int = all.size();
			for( var i:int=0; i<allSize; i++ )
			{
				if( all.getSFSObject(i).getInt("id") == uid )
					return all.getSFSObject(i);
			}
			return null;
		}		
		

	}
}