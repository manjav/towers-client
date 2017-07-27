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
	import feathers.layout.VerticalAlign;
	import feathers.layout.VerticalLayout;
	import feathers.layout.VerticalLayoutData;
	import feathers.text.BitmapFontTextFormat;
	
	import starling.display.Image;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	
	public class ChestReward extends TowersLayout
	{
		public var index:int;
		public var state:int = -1;

		private var type:int;
		private var count:int;
		private var detailsContainer:LayoutGroup;
		private var countInsideDisplay:BitmapFontTextRenderer;
		
		public function ChestReward(index:int, reward:ISFSObject)
		{
			super();
			this.index = index;
			type = reward.getInt("t");
			count = reward.getInt("c");
			touchable = touchGroup = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
	
			var padding:int = 16 *appModel.scale;
			width = 800 * appModel.scale;
			height = 400 * appModel.scale;
			
			var iconContainer:LayoutGroup = new LayoutGroup ();
			iconContainer.x = appModel.isLTR ? -width*0.4-padding : padding;
			iconContainer.y = -height * 0.5;
			iconContainer.width = width * 0.4;
			iconContainer.height = height;
			iconContainer.layout = new AnchorLayout();
			iconContainer.backgroundSkin = new Image(Assets.getTexture("building-button", "skin"));
			Image(iconContainer.backgroundSkin).scale9Grid = new Rectangle(10, 10, 56, 37);
			
			var iconDisplay:ImageLoader = new ImageLoader();
			iconDisplay.source = Assets.getTexture("building-"+type, "gui");
			iconDisplay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
			iconDisplay.horizontalAlign = HorizontalAlign.CENTER;
			iconDisplay.verticalAlign = VerticalAlign.MIDDLE;
			iconContainer.addChild(iconDisplay);
			
			countInsideDisplay = new BitmapFontTextRenderer();
			countInsideDisplay.visible = false;
			countInsideDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 96*appModel.scale, 0xFFFFFF, appModel.align);
			countInsideDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding*3, 0, appModel.isLTR?padding*3:NaN);
			countInsideDisplay.text = "x " + count; 
			iconContainer.addChild(countInsideDisplay);
			
			detailsContainer = new LayoutGroup ();
			detailsContainer.visible = false;
			detailsContainer.x = appModel.isLTR ? padding : -width*0.6-padding;
			detailsContainer.y = -height * 0.5;
			detailsContainer.width = width * 0.6;
			detailsContainer.height = height;
			detailsContainer.layout = new VerticalLayout();
			VerticalLayout(detailsContainer.layout).horizontalAlign = HorizontalAlign.JUSTIFY;
			
			addChild(appModel.isLTR ? iconContainer : detailsContainer);
			addChild(appModel.isLTR ? detailsContainer : iconContainer);
			
			var titleDisplay:RTLLabel = new RTLLabel(loc("building_title_"+type), 1, null, null, false, null, 1.1, null, "bold");
			detailsContainer.addChild(titleDisplay);
			
			var countDisplay:BitmapFontTextRenderer = new BitmapFontTextRenderer();
			countDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 96*appModel.scale, 16777215, appModel.align);
			countDisplay.layoutData = new VerticalLayoutData(100);
			countDisplay.text = "x " + count; 
			detailsContainer.addChild(countDisplay);
			state = 0;
		}
		
		public function showDetails():void
		{
			state = 1;
			detailsContainer.visible = true;
		}		
		public function hideDetails():void
		{
			state = 2;
			detailsContainer.visible = false;
			countInsideDisplay.visible = true;
		}		
		
	}
}