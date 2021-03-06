package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;

	public class SimplePopup extends AbstractPopup
	{
		protected var padding:int;
		
		public function SimplePopup()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			layout = new AnchorLayout();
			padding = 36 * appModel.scale;
			
			var skin:ImageLoader = new ImageLoader();
			skin.source = appModel.theme.popupBackgroundSkinTexture;
			skin.scale9Grid = BaseMetalWorksMobileTheme.POPUP_SCALE9_GRID;
			skin.layoutData = new AnchorLayoutData(0,0,0,0);
			skin.touchable = true;
			addChild(skin);
		}
	}
}