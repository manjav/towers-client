package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.models.vo.TabItemData;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.skins.ImageSkin;
	
	public class SocialTabItemRenderer extends BaseCustomItemRenderer
	{
		private var itemWidth:Number;
		private var _firstCommit:Boolean = true;
		private var titleDisplay:RTLLabel;
		private var iconDisplay:ImageLoader;
		private var iconLayoutData:AnchorLayoutData;
		private var badgeDisplay:ImageLoader;
		
		private var padding:int;
		private var dashboardData:TabItemData;
		public function SocialTabItemRenderer(width:Number)
		{
			super();
			layout = new AnchorLayout();
			padding = 36 * appModel.scale;
			
			skin = new ImageSkin(appModel.theme.tabUpSkinTexture);
			skin.setTextureForState(STATE_NORMAL, appModel.theme.tabUpSkinTexture);
			skin.setTextureForState(STATE_SELECTED, appModel.theme.tabDownSkinTexture);
			skin.setTextureForState(STATE_DOWN, appModel.theme.tabDownSkinTexture);
			skin.scale9Grid = BaseMetalWorksMobileTheme.TAB_SCALE9_GRID;
			backgroundSkin = skin;
			
			titleDisplay = new RTLLabel("", 1, null, null, false, null, 1.2, null, "bold");
			titleDisplay.visible = false;
			titleDisplay.layoutData = new AnchorLayoutData(padding,padding,padding,padding);
			addChild(titleDisplay);
			
			badgeDisplay = new ImageLoader();
			badgeDisplay.width = badgeDisplay.height = padding*1.6;
			badgeDisplay.layoutData = new AnchorLayoutData(padding/2, padding/2);
			
			itemWidth = width;
		}
		
		override protected function commitData():void
		{
			if(_firstCommit)
			{
				width = itemWidth;
				height = _owner.height;
				_firstCommit = false;
			}
			super.commitData();
			dashboardData = _data as TabItemData;
			titleDisplay.text = loc("tab-"+dashboardData.index) ;
			updateBadge();
		}
		
		private function updateBadge():void
		{
			if( dashboardData.badgeNumber+dashboardData.newBadgeNumber <= 0 )
			{
				if(badgeDisplay.parent == this)
					removeChild(badgeDisplay);
			}
			else
			{
				badgeDisplay.source = Assets.getTexture(dashboardData.newBadgeNumber>0 ? "badge-notification-new" : "badge-notification", "skin")
				addChild(badgeDisplay);
			}
		}
		
		override public function set isSelected(value:Boolean):void
		{
			if(value == super.isSelected)
				return;
			super.isSelected = value;
			if(dashboardData != null)
				updateBadge();
		}
	}
}


