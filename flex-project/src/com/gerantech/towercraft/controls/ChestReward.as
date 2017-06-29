package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.models.Assets;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.LayoutGroup;
	import feathers.controls.text.BitmapFontTextRenderer;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.HorizontalLayoutData;
	import feathers.layout.VerticalAlign;
	import feathers.layout.VerticalLayout;
	import feathers.layout.VerticalLayoutData;
	import feathers.text.BitmapFontTextFormat;
	
	import starling.display.Image;
	
	public class ChestReward extends TowersLayout
	{
		private var type:int;
		private var count:int;
		public var index:int;

		private var detailsContainer:LayoutGroup;

		private var countInsideDisplay:BitmapFontTextRenderer;
		
		public function ChestReward(index:int, reward:ISFSObject)
		{
			super();
			this.index = index;
			type = reward.getInt("t");
			count = reward.getInt("c");
			touchable = touchGroup = false;
			
			width = 800 * appModel.scale;
			height = 400 * appModel.scale;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			var hlayout:HorizontalLayout = new HorizontalLayout();
		//	hlayout.verticalAlign = VerticalAlign.JUSTIFY;
			hlayout.padding = hlayout.gap = 16 *appModel.scale;
			layout = hlayout;
			
			var iconContainer:LayoutGroup = new LayoutGroup ();
			iconContainer.layoutData = new HorizontalLayoutData(40, 100);
			iconContainer.layout = new AnchorLayout();
			iconContainer.backgroundSkin = new Image(Assets.getTexture("building-button", "skin"));
			Image(iconContainer.backgroundSkin).scale9Grid = new Rectangle(10, 10, 56, 37);
			
			var iconDisplay:ImageLoader = new ImageLoader();
			iconDisplay.source = Assets.getTexture("building-"+type, "gui");
			//iconDisplay.maintainAspectRatio = false;
			iconDisplay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
			iconDisplay.horizontalAlign = HorizontalAlign.CENTER;
			iconDisplay.verticalAlign = VerticalAlign.MIDDLE;
			iconContainer.addChild(iconDisplay);
			
			countInsideDisplay = new BitmapFontTextRenderer();
			countInsideDisplay.visible = false;
			countInsideDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 60*appModel.scale, 0xFFFFFF, appModel.align);
			countInsideDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:hlayout.padding, hlayout.padding, appModel.isLTR?hlayout.padding:NaN);
			countInsideDisplay.text = "x " + count; 
			iconContainer.addChild(countInsideDisplay);
			
			detailsContainer = new LayoutGroup ();
			detailsContainer.visible = false;
			detailsContainer.layoutData = new HorizontalLayoutData(60, 100);
			detailsContainer.layout = new VerticalLayout();
			VerticalLayout(detailsContainer.layout).horizontalAlign = HorizontalAlign.JUSTIFY;
			
			addChild(appModel.isLTR ? iconContainer : detailsContainer);
			addChild(appModel.isLTR ? detailsContainer : iconContainer);
			
			var titleDisplay:RTLLabel = new RTLLabel(loc("building_title_"+type), 1, null, null, false, null, 1.1, null, "bold");
			detailsContainer.addChild(titleDisplay);
			
			var countDisplay:BitmapFontTextRenderer = new BitmapFontTextRenderer();
			countDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 74*appModel.scale, 16777215, appModel.align);
			countDisplay.layoutData = new VerticalLayoutData(100);
			countDisplay.text = "x " + count; 
			detailsContainer.addChild(countDisplay);
		}
		
		public function showDetails():void
		{
			detailsContainer.visible = true;
		}		
		public function hideDetails():void
		{
			detailsContainer.visible = false;
			countInsideDisplay.visible = true;
		}		
		
	}
}