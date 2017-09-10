package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
	import com.gerantech.towercraft.controls.items.FloatingListItemRenderer;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.skins.ImageSkin;
	
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Event;

	public class SimpleListPopup extends AbstractPopup
	{
		public var buttons:Array;
		public var paddind:int = 24;
		public var buttonsWidth:int = 24;
		public var buttonHeight:int = 24;

		private var list:List;


		public function SimpleListPopup(... buttons)
		{
			super();
			this.buttons = buttons;
		}
		
		override protected function initialize():void
		{
			super.initialize();

			var skin:ImageSkin = new ImageSkin(appModel.theme.popupBackgroundSkinTexture);
			skin.scale9Grid = BaseMetalWorksMobileTheme.POPUP_SCALE9_GRID;
			backgroundSkin = skin;
			layout = new AnchorLayout();
		}
		
		override protected function transitionInCompleted():void
		{
			super.transitionInCompleted();
			list = new List();
			list.layoutData = new AnchorLayoutData( paddind, paddind, paddind, paddind);
			list.itemRendererFactory = function ():IListItemRenderer { return new FloatingListItemRenderer(buttonHeight);};
			list.dataProvider = new ListCollection(buttons);
			list.addEventListener(Event.CHANGE, list_changeHandler);
			addChild(list);
		}
		
		
		private function list_changeHandler(event:Event):void
		{
			dispatchEventWith(Event.SELECT, false, list.selectedItem);
			close();
		}
		
		override protected function defaultOverlayFactory():DisplayObject
		{
			var overlay:SimpleLayoutButton = new SimpleLayoutButton();
			overlay.backgroundSkin = new Quad(1, 1, 0);
			overlay.alpha = 0;
			overlay.width = stage.width * 3;
			overlay.height = stage.height * 3;
			overlay.x = -overlay.width / 2;
			overlay.y = -overlay.height / 2;
			overlay.addEventListener(Event.TRIGGERED, overlay_triggeredHandler);
			return overlay;
		}
		
		private function overlay_triggeredHandler(event:Event):void
		{
			close();
		}		
		
	}
}