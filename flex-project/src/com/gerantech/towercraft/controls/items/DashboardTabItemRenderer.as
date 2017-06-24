package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.controls.RTLLabel;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.skins.ImageSkin;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.utils.Padding;

	public class DashboardTabItemRenderer extends BaseCustomItemRenderer
	{
		private var itemWidth:Number;
		private var _firstCommit:Boolean = true;
		private var titleDisplay:RTLLabel;
		private var iconDisplay:ImageLoader;
		private var iconLayoutData:AnchorLayoutData;

		private var padding:int;
		public function DashboardTabItemRenderer(width:Number)
		{
			super();
			layout = new AnchorLayout();
			padding = 36 * appModel.scale;
			
			skin = new ImageSkin(appModel.theme.tabUpSkinTexture);
			//skin.selectedTexture = appModel.theme.tabSelectedUpSkinTexture;
			skin.setTextureForState(STATE_NORMAL, appModel.theme.tabUpSkinTexture);
			skin.setTextureForState(STATE_SELECTED, appModel.theme.tabSelectedUpSkinTexture);
			skin.setTextureForState(STATE_DOWN, appModel.theme.tabDownSkinTexture);
			//skin.setTextureForState(ButtonState.DISABLED, appModel.theme.tabDisabledSkinTexture);
			//skin.setTextureForState(STATE_SELECTED, appModel.theme.tabSelectedDisabledSkinTexture);
			skin.scale9Grid = BaseMetalWorksMobileTheme.TAB_SCALE9_GRID;
			backgroundSkin = skin;
			
			iconLayoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
			
			iconDisplay = new ImageLoader();
			iconDisplay.width = iconDisplay.height = width-padding*4
			iconDisplay.layoutData = iconLayoutData;
			addChild(iconDisplay); 
			
			titleDisplay = new RTLLabel("", 1, null, null, false, null, 48*appModel.scale, null, "bold");
			titleDisplay.visible = false;
			titleDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, (width-padding*4)/2, 0);
			addChild(titleDisplay);
			
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
			iconDisplay.source = Assets.getTexture("tab-"+index, "gui");
			titleDisplay.text = loc("tab-"+index) ;
		}
		
		override public function set isSelected(value:Boolean):void
		{
			if(value == super.isSelected)
				return;
			super.isSelected = value;
			Starling.juggler.tween(this, 0.08, {width:itemWidth * (value ? 2 : 1), transition:Transitions.EASE_IN_OUT});
			titleDisplay.visible = value;
			iconLayoutData.horizontalCenter = value ? NaN : 0;
			iconLayoutData.left = value ? padding : NaN;
		}
	}
}