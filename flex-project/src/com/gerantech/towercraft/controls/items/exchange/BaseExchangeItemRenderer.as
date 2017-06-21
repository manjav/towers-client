package com.gerantech.towercraft.controls.items.exchange
{
	import com.gerantech.towercraft.controls.items.BaseCustomItemRenderer;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	import com.gt.towers.exchanges.ExchangeItem;
	
	import feathers.layout.AnchorLayout;
	import feathers.layout.HorizontalLayout;
	import feathers.skins.ImageSkin;

	public class BaseExchangeItemRenderer extends BaseCustomItemRenderer
	{
		protected var firstCommit:Boolean = true;
		protected var exchange:ExchangeItem;
		protected var padding:int;
		
		public function BaseExchangeItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			layout = new AnchorLayout();
			padding = 24 * appModel.scale;

				
			skin = new ImageSkin(appModel.theme.itemRendererUpSkinTexture);
			skin.setTextureForState(STATE_NORMAL, appModel.theme.itemRendererUpSkinTexture);
			skin.setTextureForState(STATE_DOWN, appModel.theme.itemRendererSelectedSkinTexture);
			skin.setTextureForState(STATE_SELECTED, appModel.theme.itemRendererUpSkinTexture);
			skin.setTextureForState(STATE_DISABLED, appModel.theme.itemRendererUpSkinTexture);
			skin.scale9Grid = BaseMetalWorksMobileTheme.ITEM_RENDERER_SCALE9_GRID;
			backgroundSkin = skin;
		}
		override protected function commitData():void
		{
			if(firstCommit)
			{
				width = HorizontalLayout(_owner.layout).typicalItemWidth;
				//height = HorizontalLayout(_owner.layout).typicalItemHeight;
				firstCommit = false;
			}
			exchange = core.get_exchanger().bundlesMap.get(_data as int);
			super.commitData();
		}
		
	}
}