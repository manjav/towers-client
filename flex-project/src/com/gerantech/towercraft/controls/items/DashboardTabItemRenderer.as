package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	
	import feathers.controls.ButtonState;
	import feathers.controls.renderers.DefaultListItemRenderer;
	import feathers.skins.ImageSkin;
	
	import starling.animation.Transitions;
	import starling.core.Starling;

	public class DashboardTabItemRenderer extends DefaultListItemRenderer
	{
		private var itemWidth:Number;
		private var _firstCommit:Boolean = true;
		public function DashboardTabItemRenderer(width:Number)
		{
			super();
		/*	skin = new ImageSkin(appModel.theme.tabUpSkinTexture);
			//skin.selectedTexture = appModel.theme.tabSelectedUpSkinTexture;
			skin.setTextureForState(STATE_NORMAL, appModel.theme.tabUpSkinTexture);
			skin.setTextureForState(STATE_SELECTED, appModel.theme.tabSelectedUpSkinTexture);
			skin.setTextureForState(STATE_DOWN, appModel.theme.tabDownSkinTexture);
			//skin.setTextureForState(ButtonState.DISABLED, appModel.theme.tabDisabledSkinTexture);
			//skin.setTextureForState(STATE_SELECTED, appModel.theme.tabSelectedDisabledSkinTexture);
			skin.scale9Grid = BaseMetalWorksMobileTheme.TAB_SCALE9_GRID;
			backgroundSkin = skin;*/
			
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
		}
		
		override public function set isSelected(value:Boolean):void
		{
			Starling.juggler.tween(this, 0.08, {width:itemWidth * (value ? 2 : 1), transition:Transitions.EASE_IN_OUT});
		//	height = itemHeight * (value ? 2 : 1);
			super.isSelected = value;
		}
	
		 
	}
}