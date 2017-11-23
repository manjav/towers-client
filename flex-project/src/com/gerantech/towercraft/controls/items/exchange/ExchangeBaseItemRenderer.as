package com.gerantech.towercraft.controls.items.exchange
{
	import com.gerantech.towercraft.controls.items.AbstractTouchableListItemRenderer;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	import com.gt.towers.exchanges.ExchangeItem;
	
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
			padding = 24 * appModel.scale;
				
			var sk:Image = new Image(appModel.theme.popupBackgroundSkinTexture);
			sk.scale9Grid = BaseMetalWorksMobileTheme.POPUP_SCALE9_GRID;
			backgroundSkin = sk;
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