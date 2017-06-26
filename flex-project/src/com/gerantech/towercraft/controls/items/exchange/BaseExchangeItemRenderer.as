package com.gerantech.towercraft.controls.items.exchange
{
	import com.gerantech.towercraft.controls.items.BaseCustomItemRenderer;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	import com.gt.towers.exchanges.ExchangeItem;
	
	import feathers.layout.AnchorLayout;
	import feathers.layout.HorizontalLayout;
	import feathers.skins.ImageSkin;
	
	import starling.display.Image;

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

				
			var sk:Image = new Image(appModel.theme.itemRendererUpSkinTexture);
			/*skin.setTextureForState(STATE_NORMAL, appModel.theme.itemRendererUpSkinTexture);
			skin.setTextureForState(STATE_DOWN, appModel.theme.itemRendererUpSkinTexture);
			skin.setTextureForState(STATE_SELECTED, appModel.theme.itemRendererUpSkinTexture);
			skin.setTextureForState(STATE_DISABLED, appModel.theme.itemRendererUpSkinTexture);*/
			sk.scale9Grid = BaseMetalWorksMobileTheme.ITEM_RENDERER_SCALE9_GRID;
			backgroundSkin = sk;
		}
		override protected function commitData():void
		{
			if(firstCommit)
			{
				width = HorizontalLayout(_owner.layout).typicalItemWidth;
				//height = HorizontalLayout(_owner.layout).typicalItemHeight;
				firstCommit = false;
			}
			exchange = exchanger.items.get(_data as int);
			super.commitData();
		}
		
	}
}