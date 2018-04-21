package com.gerantech.towercraft.controls.items.exchange
{
	import com.gerantech.towercraft.controls.items.AbstractTouchableListItemRenderer;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	import com.gt.towers.exchanges.ExchangeItem;
	import feathers.skins.ImageSkin;
	
	import feathers.layout.AnchorLayout;
	import feathers.layout.TiledColumnsLayout;
	
	import starling.display.Image;

	public class ExchangeBaseItemRenderer extends AbstractTouchableListItemRenderer
	{
		protected var firstCommit:Boolean = true;
		protected var exchange:ExchangeItem;
		protected var padding:int;
		
		public function ExchangeBaseItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			layout = new AnchorLayout();
			padding = 12 * appModel.scale;
				
			skin = new ImageSkin(appModel.theme.itemRendererDisabledSkinTexture);
			skin.setTextureForState(STATE_NORMAL, appModel.theme.itemRendererDisabledSkinTexture);
			skin.setTextureForState(STATE_DOWN, appModel.theme.itemRendererSelectedSkinTexture);
			skin.setTextureForState(STATE_SELECTED, appModel.theme.itemRendererSelectedSkinTexture);
			skin.scale9Grid = BaseMetalWorksMobileTheme.ITEM_RENDERER_SCALE9_GRID;
			backgroundSkin = skin;
		}
		override protected function commitData():void
		{
			if(firstCommit)
			{
				width = TiledColumnsLayout(_owner.layout).typicalItemWidth;
				height = TiledColumnsLayout(_owner.layout).typicalItemHeight;
				firstCommit = false;
			}
			exchange = exchanger.items.get(_data as int);
			super.commitData();
		}
		
	}
}