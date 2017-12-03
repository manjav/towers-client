package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.constants.ResourceType;
	import com.gt.towers.exchanges.ExchangeItem;
	import com.smartfoxserver.v2.entities.data.ISFSObject;
	
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	
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
	
	public class ChestReward extends TowersLayout
	{
		public var index:int;
		public var state:int = -1;

		private var type:int;
		private var count:int;
		private var detailsContainer:LayoutGroup;
		private var countInsideDisplay:BitmapFontTextRenderer;
		
		public function ChestReward(index:int, type:int, count:int)
		{
			super();
			this.index = index;
			this.type = type;
			this.count = count;
			touchable = false;
		}
		
		override protected function initialize():void
		{
			super.initialize();
	
			var padding:int = 20 *appModel.scale;
			width = 800 * appModel.scale;
			height = 400 * appModel.scale;
			
			var iconContainer:LayoutGroup = new LayoutGroup ();
			iconContainer.x = appModel.isLTR ? -width*0.4-padding : padding;
			iconContainer.y = -height * 0.5;
			iconContainer.width = width * 0.4;
			iconContainer.height = height;
			iconContainer.layout = new AnchorLayout();
			
			if( !ResourceType.isCard(type) )
			{
				var bg:Devider = new Devider(0xFFFFFF);
				bg.layoutData = new AnchorLayoutData(padding, padding, padding, padding);
				iconContainer.addChild(bg);
			}
			
			var iconDisplay:ImageLoader = new ImageLoader();
			iconDisplay.source = Assets.getTexture("cards/"+type, "gui");
			iconDisplay.layoutData = new AnchorLayoutData(padding, padding, padding, padding);
			iconDisplay.horizontalAlign = HorizontalAlign.CENTER;
			iconDisplay.verticalAlign = VerticalAlign.MIDDLE;
			iconContainer.addChild(iconDisplay);
			
			countInsideDisplay = new BitmapFontTextRenderer();
			countInsideDisplay.visible = false;
			countInsideDisplay.textFormat = new BitmapFontTextFormat(Assets.getFont(), 96*appModel.scale, 0xFFFFFF, appModel.align);
			countInsideDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding*2, padding, appModel.isLTR?padding*2:NaN);
			countInsideDisplay.text = "x " + count; 
			iconContainer.addChild(countInsideDisplay);
			
			var coverDisplay:ImageLoader = new ImageLoader();
			coverDisplay.scale = appModel.scale * 2;
			coverDisplay.scale9Grid = new Rectangle(30,34,2,3);
			coverDisplay.source = Assets.getTexture("cards/bevel-card", "gui");
			coverDisplay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
			coverDisplay.height = coverDisplay.width * 1.3
			iconContainer.addChild(coverDisplay);
			
			if( ResourceType.isCard(type) && !player.buildings.exists(type) )
			{
				var newDisplay:ImageLoader = new ImageLoader();
				newDisplay.source = Assets.getTexture("cards/new-badge", "gui");
				newDisplay.layoutData = new AnchorLayoutData(0, NaN, NaN, 0);
				newDisplay.height = newDisplay.width = 200 * appModel.scale;
				iconContainer.addChild(newDisplay);
				player.newBuildings.set(type, 1);
				
				setTimeout(appModel.sounds.addAndPlaySound, 900, "chest-open-new")
			}
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